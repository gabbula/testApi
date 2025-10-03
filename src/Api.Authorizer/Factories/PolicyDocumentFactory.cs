using Amazon.Lambda.APIGatewayEvents;
using IntelliScript.Scoring.Api.Authorizer.Constants;
using IntelliScript.Scoring.Api.Authorizer.Interfaces;
using IntelliScript.Scoring.Api.Authorizer.Models;
using IntelliScript.Scoring.Api.Authorizer.Models.Okta;
using Microsoft.Extensions.Options;
using Serilog;

namespace IntelliScript.Scoring.Api.Authorizer.Factories;

/// <inheritdoc/>
public class PolicyDocumentFactory : IPolicyDocumentFactory
{
    private readonly AwsConfiguration _awsConfiguration;
    private readonly ILogger _logger;

    public PolicyDocumentFactory(IOptions<AwsConfiguration> awsConfiguration, ILogger logger)
    {
        _awsConfiguration = awsConfiguration.Value ?? throw new ArgumentNullException(nameof(awsConfiguration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <inheritdoc/>
    public APIGatewayCustomAuthorizerPolicy BuildPolicy(
        AuthenticationResult<IntrospectResponse?, OktaErrorResponse?>? authenticationResult)
    {
        _logger.Debug("Building policy for client {ClientId} with scopes {Scopes}", authenticationResult?.Response?.ClientId, authenticationResult?.Response?.Scope);


        var statements = new List<APIGatewayCustomAuthorizerPolicy.IAMPolicyStatement>();
        if (authenticationResult?.Authenticated == true)
        {
            var clientScopes = authenticationResult.Response?.ScopeList ?? [];
            var allowedResources = new HashSet<string>();

            foreach(var resource in _awsConfiguration.Resources!)
            {
                if (resource.RequireOneOfScopes == null || resource.RequireOneOfScopes.Intersect(clientScopes).Any())
                {
                    allowedResources.Add(resource.Resource);
                }
            }

            if (allowedResources.Any())
            {
                statements.Add(new APIGatewayCustomAuthorizerPolicy.IAMPolicyStatement
                {
                    Effect = Effects.Allow,
                    Action = new HashSet<string>([Actions.ExecuteApiInvokeAction]),
                    Resource = allowedResources
                });
            }
        }

        if (!statements.Any())
        {
            statements.Add(new APIGatewayCustomAuthorizerPolicy.IAMPolicyStatement
            {
                Effect = Effects.Deny,
                Action = new HashSet<string>([Actions.ExecuteApiInvokeAction]),
                Resource = new HashSet<string>(["*"])
            });
        }
        
        return new APIGatewayCustomAuthorizerPolicy { Statement = statements };
    }
}