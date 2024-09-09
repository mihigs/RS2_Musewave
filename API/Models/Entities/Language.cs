using Models.Base;
using Models.Enums;

namespace Models.Entities
{
    public class Language : BaseEntity
    {
        public string Name { get; set; }
        public string Code { get; set; }
    }
}
