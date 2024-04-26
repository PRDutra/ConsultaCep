unit uBuscarCep;

interface

uses
  uFormatoResposta;

type
  TBuscarCep = class
  private
  public
    class function RetornarDados(const pcepNaoFormatado: string; const pFormato: TFormatoResposta): string;
  end;

implementation

{ TBuscarCep }

uses
  sysUtils, System.Net.HttpClient;

class function TBuscarCep.RetornarDados(const pcepNaoFormatado: string; const pFormato: TFormatoResposta): string;
var
  httpCliente: THTTPClient;
  respostaCliente: IHTTPResponse;
  urlViaCep: string;
begin
  httpCliente := ThttpClient.Create;
  try
    try
      case pFormato of
        frJSON: urlViaCep := Format('https://viacep.com.br/ws/%s/json/', [pcepNaoFormatado]);
        frXML: urlViaCep := Format('https://viacep.com.br/ws/%s/xml/', [pcepNaoFormatado]);
      end;

      respostaCliente := httpCliente.Get(urlViaCep);

      if respostaCliente.StatusCode = 200 then
        Result := respostaCliente.ContentAsString
      else
        Result := Format('Erro: %d - %s', [respostaCliente.StatusCode, respostaCliente.StatusText]);
    except
      on E: Exception do
        Result := Format('Erro ao realizar a requisição: %s', [E.Message]);
    end;
  finally
    FreeAndNil(httpCliente);
  end;
end;

end.
