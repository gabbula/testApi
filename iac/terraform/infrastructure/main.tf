module "api_gateway_maas_risk_score_api" {
  source = "millimanintelliscript.jfrog.io/mi-terraform-virtual__terraform/api-gateway/aws"
  version = "v5"

  application            = local.application
  environment            = local.environment
  role                   = "api"
  line_of_business       = local.line_of_business
  domain                 = "${local.environment}-${local.line_of_business}.acs.millimanintelliscript.com"
  subdomain              = local.application
  description            = "Data Source Integration APIs"
  vpc_name               = "${local.environment}-${local.line_of_business}-vpc"
  endpoint_configuration = "PRIVATE"

  xray_tracing_enabled   = true

  stage_stage_cache = {
    enabled = false
  }
  live_stage_cache = {
    enabled = false
  }
}

resource "aws_api_gateway_request_validator" "api_gateway" {
  name                        = "${local.resource_prefix}-validator"
  rest_api_id                 = module.api_gateway_maas_risk_score_api.rest_api_id
  validate_request_body       = true
  validate_request_parameters = true
}

module "io_bucket" {
  source = "millimanintelliscript.jfrog.io/mi-terraform-virtual__terraform/s3-bucket/aws"
  version = "5.0.0"

  application      = local.application
  environment      = local.environment
  line_of_business = local.line_of_business
  purpose          = "io"
}

resource "aws_dynamodb_table" "model_definitions" {
  name           = "${local.resource_prefix}-model-definitions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = module.base_tags.tags
}

resource "aws_dynamodb_table" "model_execution_requests" {
  name           = "${local.resource_prefix}-model-execution-requests"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = module.base_tags.tags
}
