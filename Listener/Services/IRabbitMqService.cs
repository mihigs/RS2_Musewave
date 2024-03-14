using Listener.Models.DTOs;

namespace Listener.Services
{
    public interface IRabbitMqService
    {
        void SendMessage(RabbitMqMessage rabbitMqMessage);
    }
}
