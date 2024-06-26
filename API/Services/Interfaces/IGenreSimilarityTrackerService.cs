﻿using Models.DTOs;
using Models.Entities;

namespace Services.Interfaces
{
    public interface IGenreSimilarityTrackerService
    {
        public Task<SimilarityMatrixDto> CalculateAndStoreGenreSimilarities();

        public Dictionary<string, int> CalculateCoOccurrenceMatrix(List<TrackGenre> trackGenres);

        public Dictionary<string, double> CalculateSimilarityMatrix(Dictionary<string, int> coOccurrenceMatrix, List<TrackGenre> trackGenres);

        public Task<Dictionary<string, double>?> GetSimilarityMatrixAsync();
        public Task<SimilarityMatrixDto> GetSimilarityMatrixDtoAsync();
    }
}