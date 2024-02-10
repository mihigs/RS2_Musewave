using DataContext;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Web;
using Services;

var MyAllowSpecificOrigins = "_myAllowSpecificOrigins";
var builder = WebApplication.CreateBuilder(args);
var configuration = builder.Configuration;
var services = builder.Services;

// Enable CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: MyAllowSpecificOrigins,
        builder =>
        {
            builder.WithOrigins("https://localhost:7074")
            .AllowAnyHeader()
            .AllowAnyMethod();
        });
});

// Add controllers
services.AddControllers();

// Swagger
services.AddEndpointsApiExplorer();
services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "API", Version = "v1" });
});

//// Add microsoft identity
//services.AddIdentity<User, IdentityRole>(options =>
//{
//    options.User.RequireUniqueEmail = false;
//})
//    .AddEntityFrameworkStores<MusewaveDbContext>()
//    .AddDefaultTokenProviders();

// Add application services
services.AddDbContext<MusewaveDbContext>(options => options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")))
    .AddRepositories()
    .AddApplicationServices()
    .RegisterIdentity();

// Authentication and authorization
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(configuration.GetSection("AzureAd"));

services.AddAuthorization(options =>
{
    options.AddPolicy("Admin", policy => policy.RequireRole("Admin"));
    options.AddPolicy("User", policy => policy.RequireRole("User"));
});

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

app.Run();
