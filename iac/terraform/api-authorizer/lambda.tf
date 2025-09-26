resource "aws_lambda_function" "authorizer_lambda" {

  function_name    = local.authorizer_lambda_name
  filename         = "publish/${local.lambda_dir_name}.zip"
  source_code_hash = filebase64("publish/${local.lambda_dir_name}.hash.zip")
  architectures    = ["arm64"]
  handler          = "bootstrap"
  runtime          = "dotnet8"
  description      = "Data Source Integration Authorizer"
  memory_size      = 256
  timeout          = 30
  role             = aws_iam_role.auth_lambda_service_role.arn

  environment {
    variables = { for env in local.authorizer_environment_variables : env.name => env.value }
  }

  vpc_config {
    security_group_ids = [data.aws_security_group.default_security_group.id]
    subnet_ids         = data.aws_subnets.private_subnets.ids
  }
}


resource "aws_iam_role" "auth_lambda_service_role" {

  name = "${local.authorizer_lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect : "Allow"
        Principal : {
          Service : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "auth_lambda_policy" {
  name = "${local.authorizer_lambda_name}-policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Resource": [
          "${aws_secretsmanager_secret.okta-secret.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "data_lambda_service_custom_attachment" {
  policy_arn = aws_iam_policy.auth_lambda_policy.arn
  role       = aws_iam_role.auth_lambda_service_role.name
}

resource "aws_iam_role_policy_attachment" "authorizer_lambda_service_role_basic_execution_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.auth_lambda_service_role.name
}

resource "aws_iam_role_policy_attachment" "authorizer_lambda_service_vpc_access_execution_role" {
  role       = aws_iam_role.auth_lambda_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
