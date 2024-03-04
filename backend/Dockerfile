#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081
# ENV ASPNETCORE_URLS=https://+:8081;http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Development
ENV ASPNETCORE_HTTPS_PORTS=8081
ENV ASPNETCORE_HTTP_PORTS=8080
ENV AzureAd:Instance=https://login.microsoftonline.com/
ENV AzureAd:Domain=edu.fit.ba
ENV AzureAd:TenantId=ad67980b-eef9-43c8-8204-a44911390130
ENV AzureAd:ClientId=cb0d01f9-b3fa-4e12-a4ab-eaea7f7e30d2
ENV AzureAd:CallbackPath=/signin-oidc
ENV AzureAd:Scopes=access_as_user
ENV Logging:LogLevel:Default=Information
ENV Logging:LogLevel:Microsoft.AspNetCore=Warning
ENV ConnectionStrings:DefaultConnection=Server=localhost;Database=MusewaveDbDev;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True
ENV Jwt:Key=Efc5yLrV5QUntZef6PsdJuzfEnLGv+HVYhtBHEyo00A=
ENV Jwt:Issuer=http://localhost:8080
ENV Jwt:Audience=http://localhost:8080
ENV Jwt:AccessExpirationSeconds=999999
ENV AllowedHosts=*

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Docker
WORKDIR /src
COPY ["API/API.csproj", "API/"]
COPY ["Services/Services.csproj", "Services/"]
COPY ["DataContext/DataContext.csproj", "DataContext/"]
COPY ["Models/Models.csproj", "Models/"]
RUN dotnet restore "./API/API.csproj"
COPY . .
WORKDIR "/src/API"
RUN dotnet build "./API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Docker
RUN dotnet publish "./API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
RUN dotnet dev-certs https --trust
ENTRYPOINT ["dotnet", "API.dll"]
