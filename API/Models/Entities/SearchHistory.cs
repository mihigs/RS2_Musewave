using Models.Base;

namespace Models.Entities
{
    public class SearchHistory : BaseEntity
    {
        public string SearchTerm { get; set; }
        public DateTime SearchDate { get; set; }
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public bool IsDeleted { get; set; }
    }
}
