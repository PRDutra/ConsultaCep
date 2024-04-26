# ConsultaCep

Arquitetura e Padrões Utilizados
=

Interface de Repositório: A unidade InterfaceEnderecoRepository define uma interface de repositório, que é uma prática central em padrões de design como Repositório e Injeção de Dependência. Este padrão promove o desacoplamento entre a lógica de acesso a dados e as camadas superiores da aplicação, como a lógica de negócios ou a interface de usuário.

Princípio da Segregação de Interface: A interface IEnderecoRepository é um exemplo do Princípio da Segregação de Interface (ISP) do SOLID, que preconiza que uma classe não deve ser forçada a implementar interfaces que não utiliza. Neste caso, a interface é especializada em operações relacionadas a endereços.

MVC (Model-View-Controller): Embora não explícito, o formulário TfrmPrincipal atua como a camada de visualização em um padrão MVC, onde a lógica de negócios é tratada pelo repositório e as mudanças de estado são propagadas de volta ao formulário, que apenas exibe os dados.

Repositório: Utilização do padrão de repositório para abstrair e encapsular toda a lógica de acesso a dados relacionados a endereços. Isso permite que o formulário interaja com os dados de endereço sem precisar conhecer os detalhes de implementação do acesso ao banco de dados.

Injeção de Dependência: A injeção do repositório de endereços no formulário minimiza o acoplamento entre a interface de usuário e a lógica de negócios.

Data Module: É uma unidade especializada para encapsular o acesso a dados e a lógica de negócios.

Padrão de Serviço: UEnderecoService implementa um padrão de serviço para encapsular a lógica de negócios e operações relacionadas a endereços.

=================================================================================================================================================================================================================================================================
Conexões
=

As configurações de conexão com o banco de dados devem ser realizadas no componente ConexaoBanco, localizado na unidade UdmConsulta. Dependendo do banco de dados utilizado, ajustes adicionais podem ser necessários para garantir a correta comunicação e funcionalidade. 





