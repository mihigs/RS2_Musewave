using Microsoft.Extensions.Hosting;
using Services.Interfaces;

namespace Services.Implementations
{
    public class RabbitMqListener : BackgroundService
    {
        private readonly IRabbitMqService _rabbitMqService;

        public RabbitMqListener(IRabbitMqService rabbitMqService)
        {
            _rabbitMqService = rabbitMqService;
        }

        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            stoppingToken.ThrowIfCancellationRequested();

            _rabbitMqService.Receive();

            return Task.CompletedTask;
        }
    }

}
