# EP02 - Vamos testar uma aplicação rodando no Azure?

## O que vamos fazer?

Na pasta **Code-v0**, você encontrará o código Terraform para fazer deploy da infraestrutura base denominada **ambiente local**.
Você vai notar que existe um arquivo chamado `powershell-credentials-azure.ps1`. Esse arquivo é o que permitirá que o Terraform consiga criar os recursos no Azure. Ele deve conter as credenciais de acesso à sua conta do Azure.

É importante ter um **SPN (Service Principal)** criado. Nesse link, você encontrará um passo a passo de como criar o SPN e gerar as credenciais:
[Autenticar no Azure com Service Principal](https://learn.microsoft.com/pt-br/azure/developer/terraform/authenticate-to-azure-with-service-principle?tabs=bash)
Ou você pode validar esse procedimento no meu blog:
[Service Principal Terraform - Cloud Insights](https://cloudinsights.com.br/posts/Service-Principal-Terraform/).

Na pasta **Scripts**, você encontrará os arquivos para instalar e configurar o **IIS** para receber a aplicação criada para o evento.

1. Primeiro, execute o arquivo `IIS-Configure.ps1` para instalar o IIS e algumas dependências. A máquina será reiniciada.
2. Depois que conectar na máquina novamente, execute o arquivo `IIS-ConfigureWebSites.ps1` para baixar o conteúdo, configurar os websites e receber as aplicações.