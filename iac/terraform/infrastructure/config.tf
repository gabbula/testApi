provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = module.base_tags.tags
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.10.0"
    }
  }

  backend "s3" {
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
    bucket         = "mi-tfstate-data-science-development" 
    key            = "intelliscript/intelliscript-scoring/infrastructure/dev"
  }
}
