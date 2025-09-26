############
## Locals ##
############

locals {
  application      = "scoring"
  account          = "${var.ACCOUNT_PREFIX}-ds"
  environment      = var.ENVIRONMENT
  line_of_business = "ds"
  resource_prefix  = "${local.line_of_business}-${local.application}-${local.environment}"
  role             = "api"
  state_bucket_map = {
    dev  = "mi-tfstate-data-science-development"
    qa   = "mi-tfstate-data-science-testing"
    test = "mi-tfstate-data-science-testing"
    prod = "mi-tfstate-data-science-production"
  }
  vpc_name         = "${local.environment}-${local.line_of_business}-vpc"
  parent_domain    = "${local.environment}-${local.line_of_business}.acs.millimanintelliscript.com"
}

###############
## Variables ##
###############

variable "ENVIRONMENT" {
  description = "The environment level (e.g. 'dev', 'qa', 'test', or 'prod')"
  type        = string
  default     = "dev"
}
variable "ACCOUNT_PREFIX" {
  description = "The AWS Account Prefix (Development, Testing, or Production)"
  type        = string
  default     = "development"
}

variable "API_RESTRICT_TO_MILLIMAN_IPS" {
  description = "Should the API be restricted to Milliman IP addresses? (true = restricted, false = available to internet)"
  type        = bool
  default     = true
}

variable "API_RATE_LIMIT_PER_IP_PER_MINUTE" {
  description = "API rate limit per IP per minute"
  type        = number
  default     = 3000 #50 requests per second
}

variable "API_ALLOWED_COUNTRY_CODES" {
  description = "Array of two-character country codes, for example, [ \"US\", \"CN\" ], allowed by WAF geographic restrictions"
  type        = set(string)
  default     = ["CA","IE","IN","MX","PR","GB","US"] 
}

####################
## Shared Modules ##
####################

module "base_tags" {
  source           = "millimanintelliscript.jfrog.io/terraform-modules__terraform/base-tags/aws"
  version          = "v1"

  application      = local.application
  account          = local.account
  environment      = local.environment
  line_of_business = local.line_of_business
  lifespan         = "permanent"
  owner_email      = "intelliscript-scoringdevs@milliman.com"
}

##################
## Data Sources ##
##################

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Type = "private"
  }
}

data "aws_security_group" "default_security_group" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}
###############
##  TF State ##
###############



###############
##  Outputs  ##
###############

output "gateway_execution_arn" {
  value = module.api_gateway_maas_risk_score_api.gateway_execution_arn
}

output "rest_api_id" {
  value = module.api_gateway_maas_risk_score_api.rest_api_id
}

output "root_resource_id" {
  value = module.api_gateway_maas_risk_score_api.root_resource_id
}

output "jwt_authorizer_id" {
  value = module.api_gateway_maas_risk_score_api.jwt_authorizer_id
}

output "rest_api_validator_id" {
  value = aws_api_gateway_request_validator.api_gateway.id
}

output "live_certificate_domain" {
  value = module.api_gateway_maas_risk_score_api.live_certificate_domain
}

output "stage_certificate_domain" {
  value = module.api_gateway_maas_risk_score_api.stage_certificate_domain
}

output "io_bucket_arn" {
  value = module.io_bucket.s3_bucket_arn
}

output "io_bucket_name" {
  value = module.io_bucket.s3_bucket_name
}


output "model_definitions_table_arn" {
  value = aws_dynamodb_table.model_definitions.arn
}

output "model_definitions_table_name" {
  value = aws_dynamodb_table.model_definitions.name
}

output "model_execution_requests_table_arn" {
  value = aws_dynamodb_table.model_execution_requests.arn
}

output "model_execution_requests_table_name" {
  value = aws_dynamodb_table.model_execution_requests.name
}

