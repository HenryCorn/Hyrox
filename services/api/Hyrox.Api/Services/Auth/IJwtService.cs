using Hyrox.Api.Models;

namespace Hyrox.Api.Services.Auth;

public interface IJwtService
{
    string Issue(AppUser user);
    Guid? ValidateAndGetUserId(string token);
}
