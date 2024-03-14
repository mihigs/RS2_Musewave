using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using Services.Interfaces;
using System.Text;
using System.Threading.Channels;
using DataContext.Repositories.Interfaces;
using System.Text.Json;
using Models.DTOs;
using Models.Entities;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using DataContext;

namespace Services.Implementations
{
    public class RabbitMqService : IRabbitMqService
    {
        private readonly IModel _channel;
        private readonly IServiceScopeFactory _serviceProvider;

        public RabbitMqService(IServiceScopeFactory serviceProvider)
        {
            var factory = new ConnectionFactory() { HostName = "localhost" };
            var connection = factory.CreateConnection();
            _channel = connection.CreateModel();
            _channel.QueueDeclare(queue: "Listener",
                                 durable: false,
                                 exclusive: false,
                                 autoDelete: false,
                                 arguments: null);
            _serviceProvider = serviceProvider;
        }

        public void Receive()
        {
                _channel.QueueDeclare(queue: "Listener",
                     durable: false,
                     exclusive: false,
                     autoDelete: false,
                     arguments: null);
                var consumer = new EventingBasicConsumer(_channel);

                consumer.Received += (model, ea) =>
                {
                    var body = ea.Body.ToArray();
                    var message = Encoding.UTF8.GetString(body);

                    // Access message properties
                    var properties = ea.BasicProperties;
                    var contentType = properties.ContentType;
                    var contentEncoding = properties.ContentEncoding;
                    var messageId = properties.MessageId;
                    var timestamp = properties.Timestamp;
                    var type = properties.Type;
                    var headers = properties.Headers;

                    Console.WriteLine($"Received: {message}");
                    Console.WriteLine($"Content Type: {contentType}");
                    Console.WriteLine($"Content Encoding: {contentEncoding}");
                    Console.WriteLine($"Message ID: {messageId}");
                    Console.WriteLine($"Timestamp: {timestamp}");
                    Console.WriteLine($"Type: {type}");
                    Console.WriteLine("Headers:");
                    foreach (var header in headers)
                    {
                        Console.WriteLine($"  {header.Key}: {header.Value}");
                    }


                    // Deserialize the message from JSON
                    var messageObject = JsonSerializer.Deserialize<RabbitMqMessage>(message);

                    // Process the message
                    if (type == "ListenerDoneProcessing")
                    {
                        HandleListenerDoneProcessing(messageObject);
                    }
                };

                _channel.BasicConsume(queue: "Listener",
                                     autoAck: true,
                                     consumer: consumer);
        }

        private async void HandleListenerDoneProcessing(RabbitMqMessage messageObject)
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<MusewaveDbContext>();
                var trackId = int.Parse(messageObject.TrackId);
                var track = await dbContext.Tracks.FindAsync(trackId);
                track.FilePath = messageObject.Payload;
                
                var result = dbContext.Update(track);
                await dbContext.SaveChangesAsync();
            }
        }
    }
}
