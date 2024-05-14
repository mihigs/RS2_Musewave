using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Services.Interfaces;

namespace Services.Implementations.BackgroundServices
{
    public class GenreSimilarityTracker : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly IServiceScopeFactory _serviceScopeFactory;
        public GenreSimilarityTracker(IServiceProvider serviceProvider, IServiceScopeFactory serviceScopeFactory)
        {
            _serviceProvider = serviceProvider;
            _serviceScopeFactory = serviceScopeFactory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {

            while (!stoppingToken.IsCancellationRequested)
            {
                _serviceProvider.GetRequiredService<ServiceRunControl>().WaitJamendoServiceDone(stoppingToken);  // Wait for JamendoBackgroundService to finish

                using (var scope = _serviceScopeFactory.CreateScope())
                {
                    var genreSimilarityTrackerService = scope.ServiceProvider.GetRequiredService<IGenreSimilarityTrackerService>();
                    await genreSimilarityTrackerService.CalculateAndStoreGenreSimilarities();
                }

                _serviceProvider.GetRequiredService<ServiceRunControl>().NotifyGenreSimilarityTrackerDone();

                await Task.Delay(TimeSpan.FromDays(1), stoppingToken); // Every day
            }

        }


    }

}
