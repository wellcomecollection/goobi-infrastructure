provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::299497370133:role/workflow-admin"
  }

  region = var.region


  default_tags {
    tags = {
      TerraformConfigurationURL = "https://github.com/wellcomecollection/goobi-infrastructure/tree/master/infrastructure/staging"
      Environment               = "Staging"
      Department                = "Digital Production"
      Division                  = "Culture and Society"
      Use                       = "Goobi"
    }
  }
}