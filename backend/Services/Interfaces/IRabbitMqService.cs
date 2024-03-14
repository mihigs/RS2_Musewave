using Models.Entities;

namespace Services.Interfaces
{
    public interface IRabbitMqService
    {
        void Receive();
    }
}
