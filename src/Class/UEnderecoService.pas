unit UEnderecoService;

interface

uses
  UEnderecoRepository, SysUtils, Datasnap.DBClient,
  Data.DB, Data.SqlExpr,
  Data.FMTBcd, DbxDevartOracle, Datasnap.Provider, Data.DBXPool;

type
  TEnderecoService = class
  private
    FRepository: IEnderecoRepository;
  public
    constructor Create(ARepository: IEnderecoRepository);

  end;

implementation

constructor TEnderecoService.Create(ARepository: IEnderecoRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;



end.
