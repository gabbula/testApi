# okta-secret:
resource "aws_secretsmanager_secret" "api_access" {
  name = "${local.resource_prefix}-api-access"
  description = "${local.resource_prefix} Api Access"
  recovery_window_in_days = 0

  tags = {
    Name = "${local.resource_prefix}-api-access"
  }
}

resource "aws_secretsmanager_secret_version" "api_access" {
  depends_on = [ module.api_gateway_maas_risk_score_api ]
  secret_id     = aws_secretsmanager_secret.api_access.id
  secret_string = <<EOT
{
  "AuthBaseUrl": "placeholder",
  "AuthorizationServerId": "placeholder",
  "AuthClientId":"placeholder",
  "AuthClientSecret":"placeholder",
  "APILiveDomain": "${module.api_gateway_maas_risk_score_api.live_certificate_domain}",
  "APIStageDomain": "${module.api_gateway_maas_risk_score_api.stage_certificate_domain}"
}
  EOT
}
