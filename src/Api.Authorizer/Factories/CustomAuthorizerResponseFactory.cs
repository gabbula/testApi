using Amazon.Lambda.APIGatewayEvents;
using IntelliScript.Scoring.Api.Authorizer.Interfaces;
using IntelliScript.Scoring.Api.Authorizer.Models;
using IntelliScript.Scoring.Api.Authorizer.Models.Okta;
using Microsoft.Extensions.Options;

namespace IntelliScript.Scoring.Api.Authorizer.Factories;

/// <inheritdoc/>
public class CustomAuthorizerResponseFactory : ICustomAuthorizerResponseFactory
{
    private readonly IPolicyDocumentFactory _policyDocumentFactory;
    private readonly IAuthorizerContextOutputFactory _authorizerContextOutputFactory;

    public CustomAuthorizerResponseFactory(
        IPolicyDocumentFactory policyDocumentFactory,
        IAuthorizerContextOutputFactory authorizerContextOutputFactory)
    {
        _policyDocumentFactory = policyDocumentFactory ?? throw new ArgumentNullException(nameof(policyDocumentFactory));
        _authorizerContextOutputFactory = authorizerContextOutputFactory ?? throw new ArgumentNullException(nameof(authorizerContextOutputFactory));
    }
    
    /// <inheritdoc/>
    public APIGatewayCustomAuthorizerResponse BuildAuthorizerResponse(
        AuthenticationResult<IntrospectResponse?, OktaErrorResponse?> authenticationResult)
    {
        return new APIGatewayCustomAuthorizerResponse
        {
            PrincipalID = authenticationResult?.Response?.ClientId,
            PolicyDocument = _policyDocumentFactory.BuildPolicy(authenticationResult),
            Context = _authorizerContextOutputFactory.BuildAuthorizerContextOutput(authenticationResult),
        };
    }
}