unit ProjetoConsulta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Datasnap.DBClient,
  System.Net.HttpClient, System.Net.URLClient, System.JSON,
  UEnderecoRepository,
  Data.DB, Vcl.DBGrids;

type
  TfrmPrincipal = class(TForm)
    FPanelPrincipal: TPanel;
    edtCEP: TEdit;
    lbCEP: TLabel;
    btnBuscar: TButton;
    gbResultados: TGroupBox;
    gridConsulta: TDBGrid;
    gbEnderecoCompleto: TGroupBox;
    edtEstado: TEdit;
    edtCidade: TEdit;
    edtEndereco: TEdit;
    lbEstado: TLabel;
    lbCidade: TLabel;
    lbEndereco: TLabel;
    rgResultado: TRadioGroup;
    btnBuscarCompleto: TButton;
    procedure btnBuscarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBuscarCompletoClick(Sender: TObject);
  private
    { Private declarations }
    procedure ValidarBusca;
    procedure ValidarBuscaCompleta;
    procedure ParseEndereco(const ID:Integer; Atipo: string; isUpdate: Boolean);
    function GetEndereco:string;
    function GetEnderecoCompleto(AFullAddress: string): string;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses UdmConsulta, UEnderecoRepositoryImpl, UAppTypes;

procedure TfrmPrincipal.btnBuscarClick(Sender: TObject);
var
  InfoEndereco: string;
begin
  try
    ValidarBusca;
    InfoEndereco := GetEndereco;
    if InfoEndereco.StartsWith('Erro') then
    begin
      ShowMessage(InfoEndereco);
      Exit;
    end;

    if (rgResultado.ItemIndex = 0) and InfoEndereco.Contains('"erro": true') then
    begin
      ShowMessage('O CEP informado não foi encontrado.');
      Exit;
    end;

    if (rgResultado.ItemIndex = 1) and (InfoEndereco.Contains('<erro>true</erro>') or InfoEndereco.Contains('<enderecos/>')) then
    begin
      ShowMessage('O CEP informado não foi encontrado.');
      Exit;
    end;

    if not DmConsulta.EnderecoRepo.VerificarSeNaoExisteCEPNaBase(edtCEP.Text) then
    begin
      case MessageDlg('Endereço já cadastrado. Deseja visualizar o endereço existente (sim) ou atualizar com novas informações (não)?',
                      mtConfirmation, [mbYes, mbNo], 0) of
        mrYes:
          DmConsulta.LoadData;
        mrNo:
          begin
            ParseEndereco(0, InfoEndereco, True);
            DmConsulta.SaveChanges;
            ShowMessage('O registro foi atualizado com sucesso. Carregando informações');
            DmConsulta.LoadData;
          end;
      end;
    end
    else
    begin
      ParseEndereco(DmConsulta.GetUltimoCodigo, InfoEndereco, False);
      DmConsulta.SaveChanges;
      ShowMessage('Novo CEP adicionado com sucesso.');
      DmConsulta.LoadData;
    end;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TfrmPrincipal.btnBuscarCompletoClick(Sender: TObject);
var
  FullAddress, InfoEndereco: string;
  UserChoice: Integer;
begin
  try
    ValidarBuscaCompleta;
    FullAddress := Trim(edtEstado.Text) + ', ' + Trim(edtCidade.Text) + ', ' + Trim(edtEndereco.Text);

    InfoEndereco := GetEnderecoCompleto(FullAddress);
    if InfoEndereco.StartsWith('Erro') then
    begin
      ShowMessage(InfoEndereco);
      Exit;
    end;

    if (rgResultado.ItemIndex = 0) and InfoEndereco.Contains('"erro": true') then
    begin
      ShowMessage('O Endereço Completo informado não foi encontrado.');
      Exit;
    end;

    if (rgResultado.ItemIndex = 1) and (InfoEndereco.Contains('<erro>true</erro>') or InfoEndereco.Contains('<enderecos/>')) then
    begin
      ShowMessage('O Endereço Completo informado não foi encontrado.');
      Exit;
    end;

    if DmConsulta.EnderecoRepo.VerificarSeEnderecoExisteNaBase(FullAddress) then
    begin
      UserChoice := MessageDlg('Endereço já cadastrado. Deseja visualizar o endereço existente (sim) ou atualizar com novas informações (não)?',
                               mtConfirmation, [mbYes, mbNo], 0);
      case UserChoice of
        mrYes:
          DmConsulta.LoadData;
        mrNo:
          begin
            ParseEndereco(0, InfoEndereco, True);
            DmConsulta.SaveChanges;
            ShowMessage('O registro foi atualizado com sucesso. Carregando informações');
            DmConsulta.LoadData;
          end;
      end;
    end
    else
    begin
      ParseEndereco(DmConsulta.GetUltimoCodigo, InfoEndereco, False);
      DmConsulta.SaveChanges;
      ShowMessage('Novo endereço adicionado com sucesso.');
      DmConsulta.LoadData;
    end;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  DmConsulta.LoadData;
end;

function TfrmPrincipal.GetEndereco: string;
begin
  case rgResultado.ItemIndex of
    0: Result := DmConsulta.EnderecoRepo.GetEnderecoPor(edtCEP.Text, frJSON);
    1: Result := DmConsulta.EnderecoRepo.GetEnderecoPor(edtCEP.Text, frXML);
  end;
end;

function TfrmPrincipal.GetEnderecoCompleto(AFullAddress: string): string;
begin
  case rgResultado.ItemIndex of
    0: Result := DmConsulta.EnderecoRepo.GetEnderecoCompleto(AFullAddress, frJSON);
    1: Result := DmConsulta.EnderecoRepo.GetEnderecoCompleto(AFullAddress, frXML);
  end;
end;

procedure TfrmPrincipal.ParseEndereco(const ID:Integer; Atipo: string; isUpdate: Boolean);
begin
  case rgResultado.ItemIndex of
    0: DmConsulta.EnderecoRepo.ParseEnderecoJSON(ID, Atipo, isUpdate);
    1: DmConsulta.EnderecoRepo.ParseEnderecoXML(ID, Atipo, isUpdate);
  end;
end;

procedure TfrmPrincipal.ValidarBusca;
begin
  if (edtCEP.Text = '') then
    raise Exception.Create('Por favor, informe um CEP ou endereço.');
end;

procedure TfrmPrincipal.ValidarBuscaCompleta;
begin
  if Length(edtEstado.Text) < 2 then
    raise Exception.Create('Estado informado incorretamente. O campo deve ter pelo menos 3 caracteres.');

  if Length(edtCidade.Text) < 3 then
    raise Exception.Create('Cidade informada incorretamente. O campo deve ter pelo menos 3 caracteres.');

  if Length(edtEndereco.Text) < 3 then
    raise Exception.Create('Endereço informado incorretamente. O campo deve ter pelo menos 3 caracteres.');
end;

end.
