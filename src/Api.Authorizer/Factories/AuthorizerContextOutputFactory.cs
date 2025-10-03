using Amazon.Lambda.APIGatewayEvents;
using IntelliScript.Scoring.Api.Authorizer.Interfaces;
using IntelliScript.Scoring.Api.Authorizer.Models;
using IntelliScript.Scoring.Api.Authorizer.Models.Okta;

namespace IntelliScript.Scoring.Api.Authorizer.Factories;

/// <inheritdoc/>
public class AuthorizerContextOutputFactory : IAuthorizerContextOutputFactory
{
    private readonly IContextResponseFactory _contextResponseFactory;

    public AuthorizerContextOutputFactory(IContextResponseFactory contextResponseFactory)
    {
        _contextResponseFactory =
            contextResponseFactory ?? throw new ArgumentNullException(nameof(contextResponseFactory));
    }

    /// <inheritdoc/>
    public APIGatewayCustomAuthorizerContextOutput BuildAuthorizerContextOutput(
        AuthenticationResult<IntrospectResponse?, OktaErrorResponse?>? authenticationResult)
    {
        var contextResponse = _contextResponseFactory.BuildContextResponse(authenticationResult);
        var errors = string.Join(',', contextResponse.Errors);

        return new APIGatewayCustomAuthorizerContextOutput
        {
            { "ClientId", contextResponse.ClientId },
            { "Active", contextResponse.Active },
            { "Errors", errors }
        };
    }
}