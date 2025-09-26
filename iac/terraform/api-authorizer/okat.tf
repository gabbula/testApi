
module "okta_client" {
  source           = "millimanintelliscript.jfrog.io/mi-terraform-virtual__terraform/client-credential-okta-oauth-client/aws"
  version          = "v4"

  application      = local.application
  environment      = local.environment
  line_of_business = local.line_of_business
}

module "authorization_server" {
  source           = "millimanintelliscript.jfrog.io/mi-terraform-virtual__terraform/client-credential-okta-authorization-server/aws"
  version          = "v4"

  application      = local.application
  environment      = local.environment
  line_of_business = local.line_of_business
  audience         = "api://${local.application}-${local.environment}.millimanintelliscript.com"
  scopes = {
    "admin"     = "The Admin role",
    "readwrite" = "The read/write role",
    "readonly"  = "The read only role"
  }
  policies = {
    "admin" = {
      client_whitelist = [module.okta_client.client_id]
      description      = "Admin policy"
      priority         = 1
      rules = [{
        access_token_lifetime_minutes = 60
        name                          = "admin rule"
        priority                      = 1
        scope_whitelist               = ["admin"]
        },
        {
          access_token_lifetime_minutes = 60
          name                          = "readwrite rule"
          priority                      = 2
          scope_whitelist               = ["readwrite"]
      }]
    },
    "readonly" = {
      client_whitelist = [module.okta_client.client_id]
      description      = "Readonly policy"
      priority         = 2
      rules = [{
        access_token_lifetime_minutes = 60
        name                          = "readonly rule"
        priority                      = 1
        scope_whitelist               = ["readonly"]
      }]
    }
  }
}