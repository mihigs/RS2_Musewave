using Listener.Models.DTOs;
using Listener.Services;
using Microsoft.AspNetCore.Connections;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;

public class RabbitMqService : IRabbitMqService
{
    private readonly IModel _channel;

    public RabbitMqService()
    {
        var factory = new ConnectionFactory() { HostName = "localhost" };
        var connection = factory.CreateConnection();
        _channel = connection.CreateModel();
        _channel.QueueDeclare(queue: "Listener",
                             durable: false,
                             exclusive: false,
                             autoDelete: false,
                             arguments: null);
    }

    public void SendMessage(RabbitMqMessage rabbitMqMessage)
    {
        var properties = _channel.CreateBasicProperties();
        properties.Persistent = true;

        // Set metadata
        properties.ContentType = "text/plain";
        properties.ContentEncoding = "UTF-8";
        properties.MessageId = Guid.NewGuid().ToString();
        properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());
        properties.Type = "ListenerDoneProcessing";
        properties.Headers = new Dictionary<string, object>
    {
        { "origin", "Listener" },
    };
        // convert the rabbitMqMessage to json, without using newtonsoft.json
        var rabbitMqMessageParsed = JsonSerializer.Serialize(rabbitMqMessage);
        var body = Encoding.UTF8.GetBytes(rabbitMqMessageParsed);

        _channel.BasicPublish(exchange: "",
                                routingKey: "Listener",
                                basicProperties: properties,
                                body: body);

        Console.WriteLine(" [x] Sent {0}", rabbitMqMessageParsed);
    }
}
