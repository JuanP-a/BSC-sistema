using BSC.Business.Common;
using BSC.Business.Interfaces;

namespace BSC.Business.Security;

public class PasswordHasher : IPasswordHasher
{
    private const int MinLength = 8;
    private const int WorkFactor = 11;

    public Result ValidarReglas(string plain)
    {
        if (string.IsNullOrWhiteSpace(plain))
            return Result.Failure("La contrasena es requerida.", "PasswordEmpty");

        if (plain.Length < MinLength)
            return Result.Failure($"La contrasena debe tener al menos {MinLength} caracteres.", "PasswordTooShort");

        if (!plain.Any(char.IsLetter))
            return Result.Failure("La contrasena debe contener al menos una letra.", "PasswordNoLetter");

        if (!plain.Any(char.IsDigit))
            return Result.Failure("La contrasena debe contener al menos un numero.", "PasswordNoDigit");

        return Result.Success();
    }

    public string Hash(string plain) =>
        BCrypt.Net.BCrypt.HashPassword(plain, WorkFactor);

    public bool Verify(string plain, string hash)
    {
        if (string.IsNullOrEmpty(plain) || string.IsNullOrEmpty(hash))
            return false;

        try
        {
            return BCrypt.Net.BCrypt.Verify(plain, hash);
        }
        catch
        {
            return false;
        }
    }
}
