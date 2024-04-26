program ProjectConsulta;

uses
  Vcl.Forms,
  ProjetoConsulta in 'Forms\ProjetoConsulta.pas' {frmPrincipal},
  UdmConsulta in 'DataModule\UdmConsulta.pas' {DmConsulta: TDataModule},
  InterfaceEnderecoRepository in 'Interfaces\InterfaceEnderecoRepository.pas',
  UEnderecoRepositoryImpl in 'Class\UEnderecoRepositoryImpl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TDmConsulta, DmConsulta);
  Application.Run;
end.
