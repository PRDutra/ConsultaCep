unit UdmConsulta;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.SqlExpr, Datasnap.DBClient,
  UEnderecoRepository, UEnderecoRepositoryImpl,
  Data.FMTBcd, DbxDevartOracle, Datasnap.Provider, Data.DBXPool;

type
  TDmConsulta = class(TDataModule)
    ConnectionTabela: TSQLConnection;
    cdsTabela: TClientDataSet;
    dsTabela: TDataSource;
    dspTabela: TDataSetProvider;
    qry: TSQLQuery;
    qryTabela: TSQLQuery;
  private
    { Private declarations }
    FEnderecoRepo: IEnderecoRepository;
  public
    { Public declarations }
    procedure SaveChanges;
    procedure LoadData;
    procedure InitializeClientDataSet;
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
  ConnectionTabela.Connected := True;
  InitializeClientDataSet;
  FEnderecoRepo := TEnderecoRepository.Create(qry, cdsTabela);
end;

destructor TDmConsulta.Destroy;
begin
  if cdsTabela.Active then
    cdsTabela.Close;
  if qry.Active then
    qry.Close;

  FEnderecoRepo := nil;
  ConnectionTabela.Connected := False;
  inherited Destroy;
end;

function TDmConsulta.GetUltimoCodigo: Integer;
var
  SQL: string;
begin
  SQL := 'SELECT MAX(CODIGO) AS ULTIMOCODIGO FROM CONSULTAENDERECO';
  qry.Close;
  qry.SQL.Clear;
  qry.SQL.Text := SQL;
  qry.Open;
  Result := qry.FieldByName('ULTIMOCODIGO').AsInteger + 1;
  qry.Close;
end;

procedure TDmConsulta.InitializeClientDataSet;
begin
  if cdsTabela.FieldDefs.Count = 0 then
  begin
    cdsTabela.FieldDefs.Add('CODIGO', ftInteger, 0);
    cdsTabela.FieldDefs.Add('CEP', ftString, 10);
    cdsTabela.FieldDefs.Add('Logradouro', ftString, 255);
    cdsTabela.FieldDefs.Add('Complemento', ftString, 255);
    cdsTabela.FieldDefs.Add('Bairro', ftString, 100);
    cdsTabela.FieldDefs.Add('Localidade', ftString, 100);
    cdsTabela.FieldDefs.Add('UF', ftString, 2);
    cdsTabela.CreateDataSet;
  end;
  if not cdsTabela.Active then cdsTabela.Open;
end;

procedure TDmConsulta.SaveChanges;
begin
  if cdsTabela.ChangeCount > 0 then
  begin
    try
      cdsTabela.ApplyUpdates(0);
    except
      on E: Exception do
      begin
        raise Exception.Create('Erro ao salvar alterações: ' + E.Message);
      end;
    end;
  end;
end;

procedure TDmConsulta.LoadData;
begin
  cdsTabela.Close;
  qryTabela.Close;
  qryTabela.Open;
  cdsTabela.Open;
end;

end.
