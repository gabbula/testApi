provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = module.base_tags.tags
  }
}

provider "okta" {
  org_name    = var.OKTA_ORG_NAME
  base_url    = var.OKTA_BASE_URL
  client_id   = var.OKTA_CLIENT_ID
  private_key = base64decode(var.OKTA_PRIVATE_KEY) #file("${path.module}/okta_private_key.pem")
  scopes      = ["okta.apps.manage", "okta.policies.read", "okta.authorizationServers.manage", "okta.groups.manage"]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86.0"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 4.10.0"
    }
  }

  backend "s3" {
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
    bucket         = "mi-tfstate-data-science-development" 
    key            = "intelliscript/intelliscript-scoring/api-authorizer/dev"
  }
}
