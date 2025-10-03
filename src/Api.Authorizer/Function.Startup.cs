using IntelliScript.Scoring.Api.Authorizer.Factories;
using IntelliScript.Scoring.Api.Authorizer.Interfaces;
using IntelliScript.Scoring.Api.Authorizer.Models;
using IntelliScript.Scoring.Api.Authorizer.Models.Okta;
using IntelliScript.Scoring.Api.Authorizer.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Serilog;
using Serilog.Formatting.Json;
using System.Diagnostics.CodeAnalysis;

namespace IntelliScript.Scoring.Api.Authorizer;

public partial class Function
{
    private static IConfiguration? _configuration;
    private static IServiceProvider? _serviceProvider;

    [ExcludeFromCodeCoverage]
    private static IConfiguration GetConfiguration()
    {
        if (_configuration != null)
        {
            return _configuration;
        }

        var configurationBuilder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddInMemoryCollection(new Dictionary<string, string>
            {
                {"OktaConfiguration:ClientSecret",  _oktaClientSecret!}
            }!)
            .AddJsonFile("./data/resources/resources.json", false, true)
            .AddEnvironmentVariables();

        var configuration = configurationBuilder.Build();

        Log.Logger = new LoggerConfiguration()
            .ReadFrom.Configuration(configuration)
            .WriteTo.Console(new JsonFormatter(renderMessage: true))
            .CreateLogger();

        _configuration = configuration;

        return _configuration;
    }

    [ExcludeFromCodeCoverage]
    private static IServiceProvider GetServiceProvider(IConfiguration configuration) 
    {
        if (_serviceProvider != null)
        {
            return _serviceProvider;
        }

        var services = new ServiceCollection();

        services.Configure<OktaConfiguration>(configuration.GetSection(OktaConfiguration.Section));
        services.Configure<AwsConfiguration>(configuration.GetSection(AwsConfiguration.Section));

        services.AddSingleton<ILogger>(Log.Logger);
        services.AddHttpClient<OktaClient>();

        services.AddSingleton<IAuthenticationService, AuthenticationService>();
        services.AddSingleton<IOktaService, OktaService>();
        services.AddSingleton<IOktaClient, OktaClient>();
        services.AddSingleton<ICustomAuthorizerResponseFactory, CustomAuthorizerResponseFactory>();
        services.AddSingleton<IPolicyDocumentFactory, PolicyDocumentFactory>();
        services.AddSingleton<IAuthorizerContextOutputFactory, AuthorizerContextOutputFactory>();
        services.AddSingleton<IContextResponseFactory, ContextResponseFactory>();

        _serviceProvider = services.BuildServiceProvider();
        return _serviceProvider;
    }
}