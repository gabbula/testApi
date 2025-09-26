# okta-secret:
resource "aws_secretsmanager_secret" "okta-secret" {
  name = "${local.resource_prefix}-okta-client-secret"
  description = "${local.resource_prefix} Okta Authorizer Secret"
  recovery_window_in_days = 0

  tags = {
    Name = "${local.resource_prefix}-okta-client-secret"
  }
}

resource "aws_secretsmanager_secret_version" "okta-secret" {
  secret_id     = aws_secretsmanager_secret.okta-secret.id
  secret_string = <<EOT
{
  "OktaConfiguration": {
    "ClientId": "${module.okta_client.client_id}",
    "ClientSecret": "${module.okta_client.client_secret}",
    "BaseUrl": "https://${var.OKTA_ORG_NAME}.${var.OKTA_BASE_URL}",
    "Issuer": "${module.authorization_server.auth_server_id}",
    "RequestTimeoutSeconds":"${var.OKTA_REQUEST_TIMEOUT_SECONDS}",
    "IntrospectPath": "${var.OKTA_INTROSPECT_PATH}"
  }
}
  EOT
}