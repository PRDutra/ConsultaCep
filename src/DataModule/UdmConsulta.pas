unit UdmConsulta;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.SqlExpr, Datasnap.DBClient,
  InterfaceEnderecoRepository, UEnderecoRepositoryImpl, Data.FMTBcd, Datasnap.Provider, Data.DBXPool, Data.DBXOracle, Data.DBXMySQL,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDmConsulta = class(TDataModule)
    ConexaoBanco: TFDConnection;
    qryConsultarEndereco: TFDQuery;
    qryConsultas: TFDQuery;
  private
    { Private declarations }
    FEnderecoRepo: IEnderecoRepository;
  public
    { Public declarations }
    procedure LoadData;
    procedure SalvarAlteracoes;
    function GetUltimoCodigo: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property EnderecoRepo: IEnderecoRepository read FEnderecoRepo write FEnderecoRepo;
  end;

var
  DmConsulta: TDmConsulta;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

constructor TDmConsulta.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConexaoBanco.Params.Values['Database' ] := 'Lavanderia';
  ConexaoBanco.Params.Values['User_Name'] := 'root';
  ConexaoBanco.Params.Values['Password' ] := 'x4nd3';
  ConexaoBanco.Params.Values['Server'   ] := 'localhost';
  ConexaoBanco.Params.Values['DriverID' ] := 'MySQL';
  ConexaoBanco.Connected := True;
  FEnderecoRepo := TEnderecoRepository.Create(qryConsultas);
end;

destructor TDmConsulta.Destroy;
begin
  if qryConsultarEndereco.Active then
    qryConsultarEndereco.Close;

  FEnderecoRepo := nil;
  ConexaoBanco.Connected := False;
  inherited Destroy;
end;

function TDmConsulta.GetUltimoCodigo: Integer;
var
  qryConsultaCodigo: TFDQuery;
begin
  qryConsultaCodigo := TFDQuery.Create(nil);
  try
    qryConsultaCodigo.Connection := ConexaoBanco;
    qryConsultaCodigo.SQL.Add('SELECT MAX(CODIGO) AS ULTIMOCODIGO FROM CONSULTAENDERECO');
    qryConsultaCodigo.Open;
    Result := qryConsultaCodigo.FieldByName('ULTIMOCODIGO').AsInteger + 1;
    qryConsultaCodigo.Close;
  finally
    FreeAndNil(qryConsultaCodigo);
  end;
end;

procedure TDmConsulta.LoadData;
begin
  qryConsultarEndereco.Close;
  qryConsultarEndereco.Open;
  TEnderecoRepository(EnderecoRepo).CarregarDados(qryConsultarEndereco);
end;

procedure TDmConsulta.SalvarAlteracoes;
var
  dadosEndereco: IFDDataSetReference;
  qryEndereco: TFDMemTable;
  recCampos: Integer;
  ocampoOrig: TField;
  ocampoDest: TField;
begin
  if not (EnderecoRepo is TEnderecoRepository) then
    Exit;

  TEnderecoRepository(EnderecoRepo).RetornarDados(dadosEndereco);

  qryEndereco := TFDMemTable.Create(nil);
  try
    qryEndereco.Data := dadosEndereco;
    qryEndereco.First;
    while not qryEndereco.Eof do
    begin
      if qryConsultarEndereco.Locate('CEP', qryEndereco.FieldByName('CEP').AsString, []) then
        qryConsultarEndereco.Edit
      else
        qryConsultarEndereco.Append;

      for recCampos := 0 to qryEndereco.FieldCount - 1 do
      begin
        ocampoOrig := qryEndereco.Fields[recCampos];
        ocampoDest := qryConsultarEndereco.FindField(ocampoOrig.FieldName);
        if Assigned(ocampoDest) then
          ocampoDest.Value := ocampoOrig.Value;
      end;

      qryConsultarEndereco.Post;
      qryEndereco.Next;
    end;
  finally
    FreeAndNil(qryEndereco);
  end;
end;

end.
