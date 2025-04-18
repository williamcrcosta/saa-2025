# Tags padrões para os recursos criados pelo Terraform
locals {
  tags = {
    # Ambiente em que o recurso esta sendo criado
    Environment = "saa"
    # Ferramenta que esta gerenciando o recurso
    Managedby = "Terraform"
  }
}