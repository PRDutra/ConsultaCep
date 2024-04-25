unit UEnderecoRepositoryImpl;

interface

uses
  UEnderecoRepository, DB, SysUtils, Datasnap.DBClient, Data.SqlExpr,
  UAppTypes, System.Net.URLClient, System.Net.HttpClientComponent, System.NetEncoding,
  Xml.XMLIntf, Xml.xmldom, Xml.XMLDoc,
  System.Net.HttpClient, System.JSON;

type
  TEnderecoRepository = class(TInterfacedObject, IEnderecoRepository)

  private
    FQuery : TSQLQuery;
    FClientDataSet: TClientDataSet;
    procedure ProcessEnderecoNode(EnderecoNode: IXMLNode; AID: Integer; IsUpdate: Boolean);
    function GetNodeText(Node: IXMLNode; const TagName: string; const Default: string = ''): string;
  public
    constructor Create(AQuery: TSQLQuery; AClientDataSet: TClientDataSet);
    function ExtrairNumeros(const Texto: string): string;

    procedure ParseEnderecoJSON(const AID: Integer; JSONStr: string; IsUpdate: Boolean);
    procedure ParseEnderecoXML(const AID: Integer; XMLStr: string; IsUpdate: Boolean);
    function VerificarSeNaoExisteCEPNaBase(const CEP: string): Boolean;

    function VerificarSeEnderecoExisteNaBase(const FullAddress: string): Boolean;
    function GetEnderecoCompleto(const FullAddress: string; Formato: TFormatoResposta): string;
    function GetEnderecoPor(const CEP: string; Formato: TFormatoResposta): string;
  end;

implementation

uses System.Variants;

constructor TEnderecoRepository.Create(AQuery: TSQLQuery;
  AClientDataSet: TClientDataSet);
begin
  inherited Create;
  FQuery := AQuery;
  FClientDataSet := AClientDataSet;
end;

function TEnderecoRepository.VerificarSeNaoExisteCEPNaBase(const CEP: string): Boolean;
var
  SQL: string;
begin
  SQL := 'SELECT CE.CEP FROM CONSULTAENDERECO CE WHERE CE.CEP = :CEP';
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Text := SQL;
  FQuery.ParamByName('CEP').AsString := ExtrairNumeros(CEP);
  FQuery.Open;
  Result :=FQuery.IsEmpty;
  FQuery.Close;
end;

function TEnderecoRepository.GetEnderecoPor(const CEP: string; Formato: TFormatoResposta): string;
var
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
  URL, FormattedCEP: string;
begin
  Result := '';
  FormattedCEP := ExtrairNumeros(CEP);
  if Length(FormattedCEP) <> 8 then
  begin
    Result := 'Erro: CEP inválido.';
    Exit;
  end;

  HttpClient := THTTPClient.Create;
  try
    try
      case Formato of
        frJSON: URL := Format('https://viacep.com.br/ws/%s/json/', [FormattedCEP]);
        frXML: URL := Format('https://viacep.com.br/ws/%s/xml/', [FormattedCEP]);
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


procedure TEnderecoRepository.ParseEnderecoJSON(const AID: Integer; JSONStr: string; IsUpdate: Boolean);
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
      TempJSON := (JSONValue as TJSONArray).Get(0);
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
      if IsUpdate then
      begin
        // Garanta que o Locate está funcionando corretamente, verificando a extração dos números
        if not FClientDataSet.Locate('CEP', CEPNumeros, []) then
          raise Exception.Create('Registro não encontrado para atualização: ' + CEPNumeros);
        FClientDataSet.Edit;
      end
      else
      begin
        FClientDataSet.Append;
        FClientDataSet.FieldByName('CODIGO').AsInteger := AID;
      end;

      FClientDataSet.FieldByName('CEP').AsString := CEPNumeros;
      FClientDataSet.FieldByName('Logradouro').AsString := JSONObject.GetValue<string>('logradouro');
      FClientDataSet.FieldByName('Complemento').AsString := JSONObject.GetValue<string>('complemento', '');
      FClientDataSet.FieldByName('Bairro').AsString := JSONObject.GetValue<string>('bairro');
      FClientDataSet.FieldByName('Localidade').AsString := JSONObject.GetValue<string>('localidade');
      FClientDataSet.FieldByName('UF').AsString := JSONObject.GetValue<string>('uf');
      FClientDataSet.Post;
    end;
  finally
    JSONValue.Free;
  end;
end;

procedure TEnderecoRepository.ParseEnderecoXML(const AID: Integer; XMLStr: string; IsUpdate: Boolean);
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
        ProcessEnderecoNode(EnderecoNode, AID, IsUpdate);
      end;
    end
    else
      ProcessEnderecoNode(RootNode, AID, IsUpdate);
  finally
    XMLDocument := nil;
  end;
end;

procedure TEnderecoRepository.ProcessEnderecoNode(EnderecoNode: IXMLNode; AID: Integer; IsUpdate: Boolean);
begin
  if Assigned(EnderecoNode) then
  begin
    if IsUpdate then
    begin
      if not FClientDataSet.Locate('CEP', ExtrairNumeros(GetNodeText(EnderecoNode, 'cep')), []) then
        raise Exception.Create('Registro não encontrado para atualização');
      FClientDataSet.Edit;
    end
    else
    begin
      FClientDataSet.Append;
      FClientDataSet.FieldByName('CODIGO').AsInteger := AID;
    end;
    FClientDataSet.FieldByName('CEP').AsString := ExtrairNumeros(GetNodeText(EnderecoNode, 'cep'));
    FClientDataSet.FieldByName('Logradouro').AsString := GetNodeText(EnderecoNode, 'logradouro');
    FClientDataSet.FieldByName('Complemento').AsString := GetNodeText(EnderecoNode, 'complemento');
    FClientDataSet.FieldByName('Bairro').AsString := GetNodeText(EnderecoNode, 'bairro');
    FClientDataSet.FieldByName('Localidade').AsString := GetNodeText(EnderecoNode, 'localidade');
    FClientDataSet.FieldByName('UF').AsString := GetNodeText(EnderecoNode, 'uf');
    FClientDataSet.Post;
  end;
end;

function TEnderecoRepository.GetNodeText(Node: IXMLNode; const TagName: string; const Default: string = ''): string;
var
  ChildNode: IXMLNode;
begin
  ChildNode := Node.ChildNodes.FindNode(TagName);
  if Assigned(ChildNode) and not VarIsNull(ChildNode.NodeValue) then
    Result := ChildNode.Text
  else
    Result := Default;
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

function TEnderecoRepository.ExtrairNumeros(const Texto: string): string;
var
  i: Integer;
  Caractere: Char;
begin
  Result := '';
  for i := 1 to Length(Texto) do
  begin
    Caractere := Texto[i];
    if CharInSet(Caractere, ['0'..'9']) then
      Result := Result + Caractere;
  end;
end;

end.
