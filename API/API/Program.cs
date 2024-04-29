using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Services;
using DataContext;
using Microsoft.OpenApi.Models;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Services.Implementations;
using Microsoft.Extensions.Options;
using DataContext.Seeder;
using TagLib.Ape;

var MyAllowSpecificOrigins = "_myAllowSpecificOrigins";
var builder = WebApplication.CreateBuilder(args);

// Set database configuration
var configuration = builder.Configuration;
configuration.AddEnvironmentVariables();
var dbConnectionString = configuration["ConnectionString"];
if(string.IsNullOrEmpty(dbConnectionString))
{
    throw new ArgumentNullException("ConnectionString", "API: Connection string is required.");
}
// Set Redis configuration
var redisHost = configuration["Redis:Host"];
var redisPort = configuration["Redis:Port"];
var redisAbortOnConnectFail = configuration["Redis:AbortOnConnectFail"];
if (string.IsNullOrEmpty(redisHost) || string.IsNullOrEmpty(redisPort))
{
    throw new ArgumentNullException("Redis:ConnectionString", "Redis host and port are required.");
}
var redisConnectionString = $"{redisHost}:{redisPort}";
if (redisAbortOnConnectFail == "false")
{
    redisConnectionString += ",abortConnect=false";
}
Console.WriteLine("Redis connection string: " + redisConnectionString);

var services = builder.Services;

// Log the configuration entries
Console.WriteLine("API: Logging environment variables");
foreach (var item in configuration.AsEnumerable())
{
    Console.Write(item.Key + ":");
    Console.WriteLine(item.Value);
}

Console.WriteLine("Connection string: " + dbConnectionString);
// Check if the connection string is set
if (string.IsNullOrEmpty(dbConnectionString))
{
    throw new ArgumentNullException("ConnectionString", "Connection string is required.");
}

// Add RabbitMQ services
services.AddRabbitMqServices();

// Add SignalR
services.AddSignalR();

// Enable CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: MyAllowSpecificOrigins,
        builder =>
        {
            builder.AllowAnyOrigin() // Allow requests from any origin
                   .AllowAnyHeader()
                   .AllowAnyMethod();
        });
});

// Add controllers with newtonsoft json
services.AddControllers().AddNewtonsoftJson(options =>
    {
        options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
        options.SerializerSettings.Converters.Add(new Newtonsoft.Json.Converters.StringEnumConverter());
    }
);

// Swagger
services.AddEndpointsApiExplorer();
services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "API", Version = "v1" });
    // Define the BearerAuth scheme
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer"
    });

    // Apply the BearerAuth scheme globally to all API operations
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// Add all Services defined in the Services project
services.RegisterDbContext(dbConnectionString)
    .AddRedisServices(redisConnectionString)
    .AddRepositories()
    .RegisterIdentity()
    .AddApplicationServices()
    .AddBackgroundServices();

// Authentication and authorization
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        Console.WriteLine("API: Authentication > Logging environment variables");
        foreach (var item in configuration.AsEnumerable())
        {
            Console.WriteLine(item.Key);
            Console.WriteLine(item.Value);
        }
        var key = Encoding.UTF8.GetBytes(configuration["Jwt:Key"]);
        options.RequireHttpsMetadata = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = false, // change to true
            ValidateAudience = false, // change to true
            ValidateLifetime = false, // change to true
            ValidateIssuerSigningKey = false, // change to true
            ValidIssuer = configuration["Jwt:Issuer"],
            ValidAudience = configuration["Jwt:Issuer"],
            IssuerSigningKey = new SymmetricSecurityKey(key)
        };

        // Configure SignalR to accept JWT token
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];

                // Only accept tokens from the query string for SignalR requests
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) &&
                    path.StartsWithSegments("/notificationHub"))
                {
                    context.Token = accessToken;
                }
                return Task.CompletedTask;
            },
        };
    });

services.AddAuthorization(options =>
{
    options.AddPolicy("Admin", policy => policy.RequireRole("Admin"));
    options.AddPolicy("User", policy => policy.RequireRole("User"));
});

// Seeder
services.AddTransient<MusewaveDbSeeder>();

// Migrations Runner
services.AddTransient<MigrationsRunner>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors(MyAllowSpecificOrigins);

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.MapHub<NotificationHub>("/notificationHub");

// Apply migrations and seed the database
using (var scope = app.Services.CreateScope())
{
    var runner = scope.ServiceProvider.GetRequiredService<MigrationsRunner>();
    await runner.RunMigrations();
    await runner.RunSeeder();
}

app.Run();
