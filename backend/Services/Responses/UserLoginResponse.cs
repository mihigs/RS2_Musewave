﻿namespace Services.Responses
{
    public class UserLoginResponse
    {
        public string? Token { get; set; }
        public LoginError? Error { get; set; }
    }

    public enum LoginError
    {
        UserDoesNotExist,
        InvalidLoginCredentials
    }
}
