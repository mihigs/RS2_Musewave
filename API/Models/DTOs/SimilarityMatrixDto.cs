using Models.Entities;

namespace Models.DTOs
{
    public class SimilarityMatrixDto
    {
        public List<Genre> Genres { get; set; }
        public List<List<double>> SimilarityScores { get; set; }
    }
}
