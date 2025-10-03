resource "aws_api_gateway_resource" "v1" {
  rest_api_id = var.api_gateway_rest_api_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "clientid" {
  rest_api_id = var.api_gateway_rest_api_id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "clientid"
}

resource "aws_api_gateway_resource" "clientid_param" {
  rest_api_id = var.api_gateway_rest_api_id
  parent_id   = aws_api_gateway_resource.clientid.id
  path_part   = "{clientId}"
}

# Model Executions Resource
resource "aws_api_gateway_resource" "model_executions" {
  rest_api_id = data.terraform_remote_state.infrastructure.outputs.rest_api_id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "model-executions"
}

# Risk Score Resource
resource "aws_api_gateway_resource" "risk_score" {
  rest_api_id = data.terraform_remote_state.infrastructure.outputs.rest_api_id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "risk-score"
}

# Model Executions POST Method
resource "aws_api_gateway_method" "model_executions_post" {
  rest_api_id   = data.terraform_remote_state.infrastructure.outputs.rest_api_id
  resource_id   = aws_api_gateway_resource.model_executions.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = data.terraform_remote_state.infrastructure.outputs.jwt_authorizer_id
  request_models = {
    "application/json" = aws_api_gateway_model.execution_request_post_handler_request.name
  }
}

# Model Executions Integration
resource "aws_api_gateway_integration" "model_executions_post" {
  rest_api_id = data.terraform_remote_state.infrastructure.outputs.rest_api_id
  resource_id = aws_api_gateway_resource.model_executions.id
  http_method = aws_api_gateway_method.model_executions_post.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.execution_request_post_handler.invoke_arn
}

# Model Executions Method Response
resource "aws_api_gateway_method_response" "model_executions_post" {
  rest_api_id = data.terraform_remote_state.infrastructure.outputs.rest_api_id
  resource_id = aws_api_gateway_resource.model_executions.id
  http_method = aws_api_gateway_method.model_executions_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.execution_request_post_handler_response.name
  }
}

# Lambda Permission for Model Executions
resource "aws_lambda_permission" "model_executions_invoke" {
  statement_id  = "AllowAPIGatewayInvokeModelExecutions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.execution_request_post_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.terraform_remote_state.infrastructure.outputs.gateway_execution_arn}/*/POST/v1/model-executions"
}

# Risk Score POST Method (placeholder - commented out until lambda is available)
# resource "aws_api_gateway_method" "risk_score_post" {
#   rest_api_id   = data.terraform_remote_state.infrastructure.outputs.rest_api_id
#   resource_id   = aws_api_gateway_resource.risk_score.id
#   http_method   = "POST"
#   authorization = "CUSTOM"
#   authorizer_id = data.terraform_remote_state.infrastructure.outputs.jwt_authorizer_id
# }

# Commented out - missing dependencies
# resource "aws_api_gateway_integration" "execution_request_post_handler" {
#   depends_on = [aws_api_gateway_method.execution_request_post_handler]
#
#   http_method             = aws_api_gateway_method.execution_request_post_handler.http_method
#   resource_id             = aws_api_gateway_resource.risk_score.id
#   rest_api_id             = data.terraform_remote_state.infrastructure.outputs.rest_api_id
#   uri                     = aws_lambda_function.risk_score_router_lambda.invoke_arn
#   integration_http_method = "POST" # This is always POST for Lambda integrations
#   type                    = "AWS_PROXY"
# }
#
# resource "aws_lambda_permission" "allow_apigw_invoke" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.risk_score_router_lambda.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${data.terraform_remote_state.infrastructure.outputs.gateway_execution_arn}*/POST/v1/risk-score"
# }
#
# resource "aws_api_gateway_method" "execution_request_post_handler" {
#   rest_api_id   = data.terraform_remote_state.infrastructure.outputs.rest_api_id
#   resource_id   = aws_api_gateway_resource.risk_score.id
#   request_validator_id = data.terraform_remote_state.infrastructure.outputs.rest_api_validator_id
#   http_method   = "POST"
#   authorization = "CUSTOM"
#   authorizer_id = data.terraform_remote_state.infrastructure.outputs.jwt_authorizer_id
#   request_models = {
#     "application/json" = aws_api_gateway_model.execution_request_post_handler_request.name
#   }
# }

resource "aws_api_gateway_model" "execution_request_post_handler_request" {
  rest_api_id  = data.terraform_remote_state.infrastructure.outputs.rest_api_id
  name         = "RiskScorePostRequest"
  content_type = "application/json"
  schema       = file("${path.module}/../schemas/model-executions/ModelExecutionsPostRequest.json")
  #iac\terraform\lambda\schemas\risk-score3\RiskScorePostRequest.json
}

resource "aws_api_gateway_model" "execution_request_post_handler_response" {
  rest_api_id  = data.terraform_remote_state.infrastructure.outputs.rest_api_id
  name         = "RiskScoreResponse"
  content_type = "application/json"
  schema       = file("${path.module}/../schemas/model-executions/ModelExecutionsResponse.json")
}

# Commented out - missing dependencies
# resource "aws_api_gateway_method_response" "execution_request_post_handler" {
#   rest_api_id = data.terraform_remote_state.infrastructure.outputs.rest_api_id
#   http_method = aws_api_gateway_method.execution_request_post_handler.http_method
#   resource_id = aws_api_gateway_resource.risk_score.id
#   status_code = "200"
#   response_models = {
#     "application/json" = aws_api_gateway_model.execution_request_post_handler_response.name
#   }
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin" = true
#   }
# }

# Commented out - missing dependencies
# resource "aws_lambda_function" "risk_score_router_lambda" {
#   function_name = "${local.resource_prefix}-risk-score-router-lambda"
#   handler       = "risk_score_router_lambda.lambda_handler"
#   runtime       = "python3.11"
#   filename      = "${path.module}/risk_score_router_lambda.zip"
#   source_code_hash = filebase64sha256("${path.module}/risk_score_router_lambda.zip")
#   role          = aws_iam_role.iden_risk_score_lambda_role.arn
#   memory_size   = 512
#   timeout       = 30
#   environment {
#     variables = {
#       RISK_SCORE3_LAMBDA_ARN = aws_lambda_function.iden_risk_score_v3_00_lambda.arn
#       RISK_SCORE4_LAMBDA_ARN = data.terraform_remote_state.lambdas.outputs.risk_score_L_V4_RxDx_lambda_arn
#       // Add more model versions as needed
#     }
#   }
#   tracing_config {
#     mode = "Active"
#   }
#   tags = {
#     Name = "${local.resource_prefix}-risk-score-router-lambda"
#   }
# }

# Commented out - missing dependencies
# // Allow router lambda to invoke model lambdas
# resource "aws_iam_role_policy" "allow_invoke_risk_score3" {
#   name = "AllowInvokeRiskScore3"
#   role = aws_iam_role.iden_risk_score_lambda_role.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "lambda:InvokeFunction"
#         Resource = aws_lambda_function.iden_risk_score_v3_00_lambda.arn
#       }
#     ]
#   })
# }
#
# resource "aws_iam_role_policy" "allow_invoke_risk_score4" {
#   name = "AllowInvokeRiskScore4"
#   role = aws_iam_role.iden_risk_score_lambda_role.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "lambda:InvokeFunction"
#         Resource = data.terraform_remote_state.lambdas.outputs.risk_score_L_V4_RxDx_lambda_arn
#       }
#     ]
#   })
# }

# Commented out - missing dependencies
# Create CloudWatch log group for the router lambda
# resource "aws_cloudwatch_log_group" "risk_score_router_lambda_log_group" {
#   name              = "${local.resource_prefix}-risk-score-router-lambda"
#   retention_in_days = 30
# }