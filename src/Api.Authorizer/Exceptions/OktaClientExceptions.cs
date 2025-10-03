namespace IntelliScript.Scoring.Api.Authorizer.Exceptions;

/// <summary>
/// Exception thrown by <see cref="OktaClient"/>
/// </summary>
public class OktaClientException : Exception
{
    public OktaClientException(Exception e, string message) : base(message, e) {}
}