unit InterfaceEnderecoRepository;

interface

uses
  System.Classes, SysUtils, DB, Datasnap.DBClient,Data.SqlExpr, uFormatoResposta;

type
  IEnderecoRepository = interface
  ['{ACFFC645-2BF9-402B-83B9-7EE8204B86FC}']
    function ExtrairNumeros(const Texto: string): string;

    procedure ParseEnderecoJSON(const AID: Integer; JSONStr: string; IsUpdate: Boolean);
    procedure ParseEnderecoXML(const AID: Integer; XMLStr: string; IsUpdate: Boolean);
    function VerificarSeNaoExisteCEPNaBase(const CEP: string): Boolean;

    function VerificarSeEnderecoExisteNaBase(const FullAddress: string): Boolean;
    function GetEnderecoCompleto(const FullAddress: string; Formato: TFormatoResposta): string;
    function GetEnderecoPor(const pCep: string; const pFormato: TFormatoResposta): string;
  end;

implementation

end.
