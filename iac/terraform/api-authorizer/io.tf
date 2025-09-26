############
## Locals ##
############

locals {
  application      = "scoring"
  account          = "${var.ACCOUNT_PREFIX}-Data-Science"
  environment      = var.ENVIRONMENT
  line_of_business = "ds"
  resource_prefix  = "${local.line_of_business}-${local.application}-${local.environment}"
  role             = "api"
  authorizer_environment_variables = [
    { name = "Environment", value = var.ENVIRONMENT },
    { name = "Serilog__MinimumLevel", value = var.SERILOG_MINIMUM_LEVEL },
    { name = "Okta_Secret_Name", value = aws_secretsmanager_secret.okta-secret.name },
    { name = "OktaConfiguration__Issuer", value = module.authorization_server.auth_server_id},
    { name = "OktaConfiguration__Audience", value = local.audience},
    { name = "OktaConfiguration__RequestTimeoutSeconds", value = var.OKTA_REQUEST_TIMEOUT_SECONDS},
  ]
  authorizer_lambda_root = "../../../src/IntelliScript.Scoring.Api.Authorizer"
  build_output_path      = "${local.authorizer_lambda_root}/bin/publish"
  publish_zip_path       = "${local.authorizer_lambda_root}/bin/publish/ApiAuthorizer.zip"
  authorizer_lambda_name = "${local.resource_prefix}-authorizer"
  lambda_dir_name = "IntelliScript.Scoring.Api.Authorizer"
  vpc_name         = "${local.environment}-ds-vpc"
  parent_domain    = "${local.environment}-ds.acs.millimanintelliscript.com"
  audience = "api://${local.application}-${local.environment}.${local.parent_domain}"
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

variable "OKTA_CLIENT_ID" {
  type        = string
  description = "The Okta client id needed for the OAuth access to the Okta API"
  default = "0oafhv80gbZ1vVq3o1d7"
}


variable "OKTA_BASE_URL" {
  type        = string
  description = "The base URL of the Okta organization"
  default     = "oktapreview.com"
}

variable "OKTA_ORG_NAME" {
  type        = string
  description = "The name of the Okta organization"
  default     = "intelliscriptaccess"
}

variable "OKTA_REQUEST_TIMEOUT_SECONDS" {
  type        = number
  description = "The number of seconds before okta requests timeout"
  default     = 60
}

variable "AUTHORIZER_CLOUDWATCH_LOG_RETENTION_IN_DAYS" {
  type    = number
  description = "The number of days to keep authorizer lambda cloudwatch logs"
  default = 30
}

variable "SERILOG_MINIMUM_LEVEL" {
  type    = string
  default = "Information"
}

####################
## Shared Modules ##
####################

module "base_tags" {
  source = "millimanintelliscript.jfrog.io/mi-terraform-virtual__terraform/base-tags/aws"

  application      = local.application
  account          = local.account
  environment      = local.environment
  line_of_business = local.line_of_business
  lifespan         = "permanent"
  owner_email      = "intelliscript-scoringdevs@milliman.com"
  map_migrated = "exclude"
}

###############
##  Outputs  ##
###############

output "api_authorizer_lambda_name" {
  value = aws_lambda_function.authorizer_lambda.function_name
}

output "okta_auth_server_id" {
  value = module.authorization_server.auth_server_id
}

output "okta_client_id" {
  value = module.okta_client.client_id
}
