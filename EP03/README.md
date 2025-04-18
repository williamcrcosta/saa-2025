# EP03 - Queremos operar no Azure como Iniciamos?

## O que vamos fazer?

Na pasta **Code-v0**, você encontrará o código Terraform para fazer deploy da infraestrutura base denominada **ambiente azure**.
Você vai notar que existe um arquivo chamado `powershell-credentials-azure.ps1`. Esse arquivo é o que permitirá que o Terraform consiga criar os recursos no Azure. Ele deve conter as credenciais de acesso à sua conta do Azure.

Dentro da pasta **Code-v0**, você encontrará a pasta **vng**. Dentro dela, você encontrará o código Terraform para fazer deploy dos recursos necessários para fechar um tunel de vpn site-site.