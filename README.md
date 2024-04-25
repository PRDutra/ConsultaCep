# ConsultaCep

Instruções de Uso:
Para garantir o funcionamento correto do software, siga as etapas abaixo:

DLL Requerida:
Certifique-se de que a DLL dbexpoda40.dll esteja localizada na mesma pasta que o arquivo executável .exe. Esta DLL é essencial para a conexão com o banco de dados.
Configuração do Componente de Conexão:
Configure o componente ConnectionTabela do tipo TSQLConnection com os parâmetros apropriados para o seu banco de dados. Embora neste exemplo tenha sido utilizado o Oracle, a configuração pode variar conforme o sistema de gerenciamento de banco de dados que você estiver utilizando.
==============================================================================================================================================================================================================================================================


Unit ProjetoConsulta

Arquitetura e Design

MVC (Model-View-Controller):

Model:  Aqui UdmConsulta e o UEnderecoRepositoryImpl  fazem a lógica de negócios e o acesso aos dados, funcionando como o Model.

View: Seus componentes visuais como "Buttons", "Panel", servem como a View.

Controller: Os métodos dentro de TfrmPrincipal, que gerenciam as informações passadas pelo usuário, validação, e chamam o modelo para buscar dados, teriam uma atuação de Controller.


Separation of Concerns:
Fiz uma forma de separar a lógica de negocios dos eventos do usuário para que o design ficasse mais limpo.


Factory Method:
O uso de métodos como GetEndereco e GetEnderecoCompleto que encapsulam a criação de objetos ou chamadas de funções, dependendo do formato de resposta selecionado pelo usuário (JSON ou XML), é uma aplicação do padrão Factory Method. Esses métodos facilitam a expansão e a modificação do comportamento da aplicação sem alterar os clientes que dependem desses métodos.

Patterns de Design Aplicados
Strategy Pattern:

A implementação de GetEndereco e GetEnderecoCompleto utilizando rgResultado.ItemIndex para escolher entre JSON e XML é um exemplo do padrão Strategy. Isso permite que a estratégia de formatação da resposta seja selecionada em tempo de execução, tornando o sistema flexível e extensível.

Template Method:
Os métodos ValidarBusca e ValidarBuscaCompleta podem ser vistos como pequenas implementações do padrão Template Method, onde a estrutura de uma operação (validação) é definida num método, mas a execução exata de algumas partes é deixada para ser especificada por outros métodos.

=============================================================================================================================================================================================================================================================
unit UdmConsulta 

Arquitetura e Padrões de Design
Data Module:
Propósito: TDmConsulta é um TDataModule, que é um contêiner não-visual em Delphi usado para encapsular funcionalidades de acesso a dados e lógica de negócios. Ele centraliza o acesso a dados, tornando o código mais organizado e fácil de manter.

Repository Pattern:
Implementação: A propriedade EnderecoRepo é uma instância de IEnderecoRepository, o que indica o uso do Repository Pattern. Este padrão abstrai a camada de acesso a dados do restante da aplicação, permitindo que a lógica de negócios interaja com o modelo de dados de forma mais limpa e organizada.

Dependency Injection:
Aplicação: FEnderecoRepo é instanciado no construtor com TEnderecoRepository.Create(qry, cdsTabela), demonstrando uma forma de injeção de dependência, onde o módulo de dados é responsável por criar e configurar as dependências necessárias para o repositório operar.

Factory Method:
Uso: O método InitializeClientDataSet configura o ClientDataSet de forma programática, o que é um exemplo do padrão Factory Method, responsável por preparar e configurar objetos complexos.

Técnicas Específicas

Manipulação de Erros: O método SaveChanges encapsula operações de atualização em um bloco try-except, capturando e relançando exceções com mensagens personalizadas. Isso melhora a robustez e a capacidade de depuração do código.
Gerenciamento de Transações: Embora não explicitamente mostrado neste código, a gestão da transação pode ser inferida pelo uso de ApplyUpdates(0) dentro de SaveChanges, indicando um controle de transações implícito pelo ClientDataSet.

==============================================================================================================================================================================================================================================================

unit UEnderecoRepository 

Padrões de Design e Arquitetura
Interface Segregation Principle (ISP):
Propósito: A interface IEnderecoRepository é um exemplo do princípio de segregação de interface, um dos princípios SOLID. Ela define um contrato específico para operações relacionadas a endereços, garantindo que os consumidores da interface não dependam de métodos que não usam.

Repository Pattern:
Implementação: Esta interface adota o Repository Pattern, que ajuda a separar a lógica que recupera os dados e mapeia esses dados ao modelo de domínio da lógica de negócios que atua sobre o modelo. Isso permite uma maior abstração e independência entre as camadas de persistência de dados e a lógica de negócios da aplicação.

Single Responsibility Principle (SRP):
Enfoque: Cada método na interface IEnderecoRepository tem uma única responsabilidade, seja ela extrair números de uma string, analisar dados JSON/XML, verificar a existência de um CEP ou endereço no banco de dados, ou recuperar endereços completos. Isso está alinhado ao princípio da única responsabilidade, também um dos princípios SOLID.

Métodos e Suas Responsabilidades
ExtrairNumeros: Extrai e retorna apenas os números de uma string fornecida, útil para processar dados formatados como CEPs.

ParseEnderecoJSON e ParseEnderecoXML: Métodos para analisar strings JSON e XML, respectivamente, e atualizar ou inserir registros no sistema com base nos dados analisados. O parâmetro IsUpdate indica se a operação é para atualizar um registro existente ou inserir um novo.

VerificarSeNaoExisteCEPNaBase e VerificarSeEnderecoExisteNaBase: Verificam a existência de um CEP ou de um endereço completo no banco de dados, respectivamente, retornando um booleano.
GetEnderecoCompleto e GetEnderecoPor: Recuperam dados de endereço, o primeiro para endereços completos e o segundo para CEPs, suportando formatos JSON e XML indicados pelo enum TFormatoResposta.

===============================================================================================================================================================================================================================================================

unit UEnderecoRepositoryImpl 

Padrões de Design e Arquitetura
Dependency Injection:
Implementação: O construtor Create aceita TSQLQuery e TClientDataSet como parâmetros, que são usados internamente nos métodos. Isso demonstra o uso do padrão de Injeção de Dependência, permitindo que o repositório seja menos acoplado à criação desses objetos e mais fácil de testar.

Adapter Pattern:
Propósito: A implementação dos métodos ParseEnderecoJSON e ParseEnderecoXML adapta os dados de JSON/XML para a estrutura interna usada pela aplicação (através do TClientDataSet). Esse padrão permite que a aplicação interaja de forma uniforme com dados que podem vir em formatos diferentes.

Strategy Pattern:
Funcionalidade: A função GetEnderecoPor e GetEnderecoCompleto utilizam o Strategy Pattern ao aceitar um parâmetro TFormatoResposta que determina se a saída será JSON ou XML. Isso encapsula o comportamento variável das chamadas de API em função do formato de resposta desejado.

Métodos e Responsabilidades
GetEnderecoPor e GetEnderecoCompleto: Executam chamadas HTTP para a API ViaCEP e retornam os dados em formato JSON ou XML, dependendo do valor de TFormatoResposta.

ParseEnderecoJSON e ParseEnderecoXML: Estes métodos convertem a string JSON ou XML para dados utilizáveis dentro do sistema, atualizando ou inserindo dados em TClientDataSet baseado na flag IsUpdate.

ExtrairNumeros: Este utilitário extrai números de strings, útil para processamento de CEPs e outros campos numéricos.

VerificarSeNaoExisteCEPNaBase e VerificarSeEnderecoExisteNaBase: Checam a existência de um CEP ou de um endereço completo no banco de dados.

Uso de Tecnologias Externas
HTTPClient para chamadas de API, mostrando a integração com serviços web externos.

XML and JSON Parsing: Demonstrando capacidade de lidar com diferentes formatos de dados, essencial para sistemas modernos que interagem com várias fontes de dados.

==============================================================================================================================================================================================================================================================









