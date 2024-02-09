namespace Models.DTOs
{
    public class PaginationResponseDto
    {
        public List<dynamic> Rows { get; set; } = new List<dynamic>();
        public int TotalCount { get; set; } = 0;
    }
}
