terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket         = "wellcomecollection-workflow-infra"
    key            = "terraform/workflow.tfstate"
    dynamodb_table = "terraform-locktable"

    assume_role = {
      role_arn = "arn:aws:iam::299497370133:role/workflow-developer"
    }
    
    region = "eu-west-1"
  }
}

resource "aws_dynamodb_table" "terraform-locktable" {
  name           = "terraform-locktable"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

