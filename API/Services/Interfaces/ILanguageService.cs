using Models.DTOs;
using Models.Entities;

namespace Services.Interfaces
{
    public interface ILanguageService
    {
        public Task<List<Language>> GetAllLanguages();
        public Task<Language> GetLanguageById(int languageId);
    }
}
