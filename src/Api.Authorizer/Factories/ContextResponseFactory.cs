using IntelliScript.Scoring.Api.Authorizer.Interfaces;
using IntelliScript.Scoring.Api.Authorizer.Models;
using IntelliScript.Scoring.Api.Authorizer.Models.Okta;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace IntelliScript.Scoring.Api.Authorizer.Factories;

/// <inheritdoc/>
public class ContextResponseFactory : IContextResponseFactory
{
    private readonly ILogger<ContextResponseFactory> _logger;

    public ContextResponseFactory(
        ILogger<ContextResponseFactory> logger)
    {
        _logger = logger;
    }

    /// <inheritdoc/>
    public ContextResponse BuildContextResponse(
        AuthenticationResult<IntrospectResponse?, OktaErrorResponse?>? authenticationResult)
    {
        var errorList = new List<object>();

        if (authenticationResult is null)
        {
            errorList.Add("Auth result is empty");

            return new ContextResponse
            {
                ClientId = string.Empty,
                Active = false,
                Errors = [errorList]
            };
        }

        var errorResponse = authenticationResult.ErrorResponse;

        if (errorResponse?.ErrorDescription is not null || errorResponse?.ErrorSummary is not null)
        {
            errorList.Add(
                (errorResponse.ErrorDescription ?? errorResponse.ErrorSummary) ?? string.Empty);
            _logger.LogDebug(
                """Error encountered authenticating request. Error Code: "{ErrorCode}" Error Description: "{ErrorDescription}" Error Summary: "{ErrorSummary}""",
                errorResponse.ErrorCode,
                errorResponse.ErrorDescription,
                errorResponse.ErrorSummary);
        }

        if (errorResponse?.ErrorCauses is not null)
        {
            errorList.AddRange(errorResponse.ErrorCauses);
        }
            
        var formattedErrors = errorList.Any() ? errorList.ToArray() : [];

        return new ContextResponse
        {
            ClientId = authenticationResult.Response?.ClientId ?? string.Empty,
            Active = authenticationResult.Response?.Active ?? false,
            Errors = formattedErrors
        };
    }
}