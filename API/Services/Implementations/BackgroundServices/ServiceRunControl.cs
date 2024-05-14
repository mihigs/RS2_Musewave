namespace Services.Implementations.BackgroundServices
{
    public class ServiceRunControl
    {
        private SemaphoreSlim _jamendoServiceDone = new SemaphoreSlim(0, 1);
        private SemaphoreSlim _genreSimilarityTrackerDone = new SemaphoreSlim(0, 1);

        public void NotifyJamendoServiceDone() => _jamendoServiceDone.Release();
        public void WaitJamendoServiceDone(CancellationToken cancellationToken = default) => _jamendoServiceDone.Wait(cancellationToken);

        public void NotifyGenreSimilarityTrackerDone() => _genreSimilarityTrackerDone.Release();
        public void WaitGenreSimilarityTrackerDone(CancellationToken cancellationToken = default) => _genreSimilarityTrackerDone.Wait(cancellationToken);
    }

}
