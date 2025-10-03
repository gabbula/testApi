using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using Amazon.Lambda.RuntimeSupport;
using Amazon.Lambda.Serialization.SystemTextJson;
using IntelliScript.Scoring.Api.Authorizer.Interfaces;
using IntelliScript.Scoring.Api.Authorizer.Models;
using IntelliScript.Scoring.Api.Authorizer.Models.Okta;
using IntelliScript.Scoring.Api.Authorizer.Services;
using Microsoft.Extensions.DependencyInjection;
using Serilog;
using System.Diagnostics.CodeAnalysis;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(DefaultLambdaJsonSerializer))]

namespace IntelliScript.Scoring.Api.Authorizer;

public partial class Function
{
    private readonly IAuthenticationService _authenticationService;
    private readonly ICustomAuthorizerResponseFactory _customAuthorizerResponseFactory;
    private readonly ILogger _logger;
    private static string? _oktaClientSecret;

    /// <summary>
    /// The main entry point for the custom runtime.
    /// </summary>
    [ExcludeFromCodeCoverage]
    private static async Task Main()
    {
        var secretsManager = new SecretsManagerClient();
        _oktaClientSecret = await secretsManager.GetSecret(Environment.GetEnvironmentVariable(Constants.Constants.OKTA_SECRET_NAME));

        Function function = new Function();

        var handler = function.AuthorizerHandler;
        await LambdaBootstrapBuilder.Create(handler, new SourceGeneratorLambdaJsonSerializer<CustomJsonSerializerContext>(options => {
            options.PropertyNameCaseInsensitive = true;
        }))
            .Build()
            .RunAsync();
    }

    [ExcludeFromCodeCoverage]
    private Function()
    {
        var configuration = GetConfiguration();
        var serviceProvider = GetServiceProvider(configuration);

        _authenticationService = serviceProvider.GetRequiredService<IAuthenticationService>();
        _customAuthorizerResponseFactory = serviceProvider.GetRequiredService<ICustomAuthorizerResponseFactory>();
        _logger = serviceProvider.GetRequiredService<ILogger>();
    }

    public Function(IServiceProvider serviceProvider)
    {
        _authenticationService = serviceProvider.GetRequiredService<IAuthenticationService>();
        _customAuthorizerResponseFactory = serviceProvider.GetRequiredService<ICustomAuthorizerResponseFactory>();
        _logger = serviceProvider.GetRequiredService<ILogger>();
    }

    public async Task<APIGatewayCustomAuthorizerResponse> AuthorizerHandler(
        APIGatewayCustomAuthorizerRequest authorizerRequest,
        ILambdaContext context)
    {
        try
        {
            _logger.Information("Application starting...");

            _logger.Debug("Token authentication beginning...");
            var authenticationResult = await _authenticationService.AuthenticateTokenAsync(authorizerRequest);
            if(!authenticationResult.Authenticated)
            {
                _logger.Information("Auth request failed with Message}", authenticationResult.Response);
            }
            
            _logger.Debug("Token authentication complete. Authentication result: {Result}", authenticationResult.Authenticated);

            _logger.Debug("Authorizer response build beginning...");
            var apiGatewayResponse = _customAuthorizerResponseFactory.BuildAuthorizerResponse(authenticationResult);
            _logger.Debug("{AuthorizerResponse}", System.Text.Json.JsonSerializer.Serialize(apiGatewayResponse));
            _logger.Debug("Authorizer response build complete...");
            
            _logger.Information("Application ending...");

            return apiGatewayResponse;
        }
        catch (Exception e)
        {
            _logger.Error(e, e.Message);

            return _customAuthorizerResponseFactory.BuildAuthorizerResponse(
                new AuthenticationResult<IntrospectResponse?, OktaErrorResponse?> { Authenticated = false });
        }
    }
}