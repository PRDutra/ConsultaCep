unit UEnderecoRepositoryImpl;

interface

uses
  InterfaceEnderecoRepository, DB, SysUtils, Datasnap.DBClient, Data.SqlExpr,
  System.Net.URLClient, System.Net.HttpClientComponent, System.NetEncoding,
  uFormatoResposta, Xml.XMLIntf, Xml.xmldom, Xml.XMLDoc,
  System.Net.HttpClient, System.JSON, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet;

type
  TEnderecoRepository = class(TInterfacedObject, IEnderecoRepository)
  private
    FQuery : TFDQuery;
    FDadosEndereco: TFDMemTable;
    procedure ProcessEnderecoNode(AEnderecoNode: IXMLNode; const AId: Integer; const AIsUpdate: Boolean);
    function BuscarTextoNode(Node: IXMLNode; const AtagName: string; const AValorPadrao: string = ''): string;
    function ValidarDadosCep(const AcepNaoFormatado: string): Boolean;
    procedure ConfigurarDadosEndereco(pDadosEndereco: TFDMemTable);
  public
    constructor Create(AQuery: TFDQuery);
    destructor Destroy; override;
    function ExtrairNumeros(const ATexto: string): string;
    procedure ParseEnderecoJSON(const AID: Integer; JSONStr: string; AIsUpdate: Boolean);
    procedure ParseEnderecoXML(const AID: Integer; XMLStr: string; AIsUpdate: Boolean);
    function VerificarSeNaoExisteCEPNaBase(const ACEP: string): Boolean;
    function VerificarSeEnderecoExisteNaBase(const FullAddress: string): Boolean;
    function GetEnderecoCompleto(const FullAddress: string; Formato: TFormatoResposta): string;
    function GetEnderecoPor(const ACep: string; const AFormato: TFormatoResposta): string;
    procedure RetornarDados(var ADadosEndereco: IFDDataSetReference);
    procedure CarregarDados(const ADadosEndereco: TDataSet);
    property DadosEndereco: TFDMemTable read FDadosEndereco;
  end;

implementation

uses System.Variants, uBuscarCep;

procedure TEnderecoRepository.CarregarDados(const ADadosEndereco: TDataSet);
begin
  FDadosEndereco.Close;
  FDadosEndereco.Open;
  FDadosEndereco.CopyDataSet(ADadosEndereco);
end;

procedure TEnderecoRepository.ConfigurarDadosEndereco(pDadosEndereco: TFDMemTable);
begin
  if pDadosEndereco.FieldDefs.Count = 0 then
  begin
    pDadosEndereco.FieldDefs.Add('Codigo', ftInteger, 0);
    pDadosEndereco.FieldDefs.Add('Cep', ftString, 10);
    pDadosEndereco.FieldDefs.Add('Logradouro', ftString, 255);
    pDadosEndereco.FieldDefs.Add('Complemento', ftString, 255);
    pDadosEndereco.FieldDefs.Add('Bairro', ftString, 100);
    pDadosEndereco.FieldDefs.Add('Localidade', ftString, 100);
    pDadosEndereco.FieldDefs.Add('UF', ftString, 2);
    pDadosEndereco.CreateDataSet;
  end;
end;

constructor TEnderecoRepository.Create(AQuery: TFDQuery);
begin
  inherited Create;
  FQuery := AQuery;
  FDadosEndereco := TFDMemTable.Create(nil);
  ConfigurarDadosEndereco(FDadosEndereco);
end;

function TEnderecoRepository.VerificarSeNaoExisteCEPNaBase(const ACEP: string): Boolean;
var
  SQL: string;
begin
  SQL := 'SELECT CE.CEP FROM CONSULTAENDERECO CE WHERE CE.CEP = :CEP';
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Text := SQL;
  FQuery.ParamByName('CEP').AsString := ExtrairNumeros(ACEP);
  FQuery.Open;
  Result := FQuery.IsEmpty;
  FQuery.Close;
end;

function TEnderecoRepository.GetEnderecoPor(const ACep: string; const AFormato: TFormatoResposta): string;
var
  cepNaoFormatado: string;
begin
  try
    cepNaoFormatado := ExtrairNumeros(ACep);

    if not ValidarDadosCep(cepNaoFormatado) then
      Exit('Erro: CEP inválido.');

    Result := TBuscarCep.RetornarDados(cepNaoFormatado, AFormato);
  except
    Result := 'Erro ao retornar CEP';
  end;
end;

procedure TEnderecoRepository.ParseEnderecoJSON(const AID: Integer; JSONStr: string; AIsUpdate: Boolean);
var
  JSONValue, TempJSON: TJSONValue;
  JSONObject: TJSONObject;
  CEPNumeros: string;
begin
  JSONValue := TJSONObject.ParseJSONValue(JSONStr);
  try
    if JSONValue is TJSONObject then
    begin
      JSONObject := JSONValue as TJSONObject;
    end
    else if JSONValue is TJSONArray then
    begin
      TempJSON := (JSONValue as TJSONArray).Items[0];
      if TempJSON is TJSONObject then
        JSONObject := TempJSON as TJSONObject
      else
        raise Exception.Create('O primeiro item do array JSON não é um objeto.');
    end
    else
      raise Exception.Create('Formato JSON não reconhecido ou inválido.');

    if Assigned(JSONObject) then
    begin
      CEPNumeros := ExtrairNumeros(JSONObject.GetValue<string>('cep'));
      if AIsUpdate then
      begin
        // Garanta que o Locate está funcionando corretamente, verificando a extração dos números
        if not FDadosEndereco.Locate('CEP', CEPNumeros, []) then
          raise Exception.Create('Registro não encontrado para atualização: ' + CEPNumeros);
        FDadosEndereco.Edit;
      end
      else
      begin
        FDadosEndereco.Append;
        FDadosEndereco.FieldByName('CODIGO').AsInteger := AID;
      end;

      FDadosEndereco.FieldByName('CEP').AsString := CEPNumeros;
      FDadosEndereco.FieldByName('Logradouro').AsString := JSONObject.GetValue<string>('logradouro');
      FDadosEndereco.FieldByName('Complemento').AsString := JSONObject.GetValue<string>('complemento', '');
      FDadosEndereco.FieldByName('Bairro').AsString := JSONObject.GetValue<string>('bairro');
      FDadosEndereco.FieldByName('Localidade').AsString := JSONObject.GetValue<string>('localidade');
      FDadosEndereco.FieldByName('UF').AsString := JSONObject.GetValue<string>('uf');
      FDadosEndereco.Post;
    end;
  finally
    JSONValue.Free;
  end;
end;

procedure TEnderecoRepository.ParseEnderecoXML(const AID: Integer; XMLStr: string; AIsUpdate: Boolean);
var
  XMLDocument: IXMLDocument;
  RootNode, EnderecosNode, EnderecoNode: IXMLNode;
  i: Integer;
begin
  if Trim(XMLStr) = '' then
    raise Exception.Create('XML vazio recebido, nenhuma operação realizada.');

  XMLDocument := TXMLDocument.Create(nil);
  try
    XMLDocument.LoadFromXML(XMLStr);
    RootNode := XMLDocument.DocumentElement;
    EnderecosNode := RootNode.ChildNodes.FindNode('enderecos');
    if Assigned(EnderecosNode) then
    begin
      for i := 0 to EnderecosNode.ChildNodes.Count - 1 do
      begin
        EnderecoNode := EnderecosNode.ChildNodes[i];
        ProcessEnderecoNode(EnderecoNode, AID, AIsUpdate);
      end;
    end
    else
      ProcessEnderecoNode(RootNode, AID, AIsUpdate);
  finally
    XMLDocument := nil;
  end;
end;

procedure TEnderecoRepository.ProcessEnderecoNode(AEnderecoNode: IXMLNode; const AId: Integer; const AIsUpdate: Boolean);
begin
  if Assigned(AEnderecoNode) then
  begin
    if AIsUpdate then
    begin
      if not FDadosEndereco.Locate('CEP', ExtrairNumeros(BuscarTextoNode(AEnderecoNode, 'cep')), []) then
        raise Exception.Create('Registro não encontrado para atualização');
      FDadosEndereco.Edit;
    end
    else
    begin
      FDadosEndereco.Append;
      FDadosEndereco.FieldByName('CODIGO').AsInteger := AId;
    end;
    FDadosEndereco.FieldByName('CEP').AsString := ExtrairNumeros(BuscarTextoNode(AEnderecoNode, 'cep'));
    FDadosEndereco.FieldByName('Logradouro').AsString := BuscarTextoNode(AEnderecoNode, 'logradouro');
    FDadosEndereco.FieldByName('Complemento').AsString := BuscarTextoNode(AEnderecoNode, 'complemento');
    FDadosEndereco.FieldByName('Bairro').AsString := BuscarTextoNode(AEnderecoNode, 'bairro');
    FDadosEndereco.FieldByName('Localidade').AsString := BuscarTextoNode(AEnderecoNode, 'localidade');
    FDadosEndereco.FieldByName('UF').AsString := BuscarTextoNode(AEnderecoNode, 'uf');
    FDadosEndereco.Post;
  end;
end;

procedure TEnderecoRepository.RetornarDados(var ADadosEndereco: IFDDataSetReference);
begin
  ADadosEndereco := FDadosEndereco.Data;
end;

function TEnderecoRepository.BuscarTextoNode(Node: IXMLNode; const AtagName: string; const AValorPadrao: string = ''): string;
var
  ChildNode: IXMLNode;
begin
  ChildNode := Node.ChildNodes.FindNode(AtagName);
  if Assigned(ChildNode) and not VarIsNull(ChildNode.NodeValue) then
    Result := ChildNode.Text
  else
    Result := AValorPadrao;
end;

function TEnderecoRepository.ValidarDadosCep(const AcepNaoFormatado: string): Boolean;
begin
  Result := Length(AcepNaoFormatado) = 8;
end;

function TEnderecoRepository.VerificarSeEnderecoExisteNaBase(const FullAddress: string): Boolean;
var
  Parts: TArray<string>;
  SQL: string;
begin
  Parts := FullAddress.Split([',']);
  if Length(Parts) < 3 then
    raise Exception.Create('Endereço completo deve incluir estado, cidade e endereço.');

  Parts[0] := Trim(Parts[0]);
  Parts[1] := Trim(Parts[1]);
  Parts[2] := Trim(Parts[2]);

  SQL := 'SELECT CE.UF, CE.LOCALIDADE, CE.LOGRADOURO ' +
         'FROM CONSULTAENDERECO CE ' +
         'WHERE ' +
         'UPPER(CE.UF) = UPPER(:UF) ' +
         'AND UPPER(CE.LOCALIDADE) = UPPER(:LOCALIDADE) ' +
         'AND UPPER(CE.LOGRADOURO) = UPPER(:LOGRADOURO)';

  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Text := SQL;
  FQuery.ParamByName('UF').AsString := Parts[0];
  FQuery.ParamByName('LOCALIDADE').AsString := Parts[1];
  FQuery.ParamByName('LOGRADOURO').AsString := Parts[2];
  FQuery.Open;
  Result := not FQuery.IsEmpty;
  FQuery.Close;
end;

function TEnderecoRepository.GetEnderecoCompleto(const FullAddress: string; Formato: TFormatoResposta): string;
var
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
  URL: string;
  Parts: TArray<string>;
begin
  Result := '';
  Parts := FullAddress.Split([',']);
  if Length(Parts) < 3 then
    raise Exception.Create('Endereço completo deve conter Estado, Cidade e Logradouro.');

  Parts[0] := TNetEncoding.URL.Encode(Trim(Parts[0])).Replace('+', '%20'); 
  Parts[1] := TNetEncoding.URL.Encode(Trim(Parts[1])).Replace('+', '%20'); 
  Parts[2] := TNetEncoding.URL.Encode(Trim(Parts[2])).Replace('+', '%20'); 

  HttpClient := THTTPClient.Create;
  try
    try
    
      case Formato of
        frJSON: URL := Format('https://viacep.com.br/ws/%s/%s/%s/json/', [Parts[0], Parts[1], Parts[2]]);
        frXML: URL := Format('https://viacep.com.br/ws/%s/%s/%s/xml/', [Parts[0], Parts[1], Parts[2]]);
      end;

      Response := HttpClient.Get(URL);
      if Response.StatusCode = 200 then
        Result := Response.ContentAsString
      else
        Result := Format('Erro: %d - %s', [Response.StatusCode, Response.StatusText]);
    except
      on E: Exception do
        Result := Format('Erro ao realizar a requisição: %s', [E.Message]);
    end;
  finally
    HttpClient.Free;
  end;
end;

destructor TEnderecoRepository.Destroy;
begin
  FreeAndNil(FDadosEndereco);
  inherited;
end;

function TEnderecoRepository.ExtrairNumeros(const ATexto: string): string;
var
  i: Integer;
  Caractere: Char;
begin
  Result := '';
  for i := 1 to Length(ATexto) do
  begin
    Caractere := ATexto[i];
    if CharInSet(Caractere, ['0'..'9']) then
      Result := Result + Caractere;
  end;
end;

end.
