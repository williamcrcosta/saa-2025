# EP04 - Ok. Vamos implementar Cloud com o Azure

## O que vamos fazer?

Na pasta **Code-v0**, você encontrará o código Terraform para fazer deploy da infraestrutura base denominada **ambiente local fw**.
Você vai notar que existe um arquivo chamado `powershell-credentials-azure.ps1`. Esse arquivo é o que permitirá que o Terraform consiga criar os recursos no Azure. Ele deve conter as credenciais de acesso à sua conta do Azure.

Na pasta **Code-v1-migrate**, você encontrará o código Terraform para fazer deploy da infraestrutura base denominada **ambiente azure**.

Dentro da pasta **Code-v1-migrate**, você encontrará as pastas para fazer deploy de alguns recursos utilizados no SAA 2025.