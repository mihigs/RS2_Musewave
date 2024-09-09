using DataContext.Repositories.Interfaces;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class LanguageService : ILanguageService
    {
        private readonly ILanguageRepository _languageRepository;

        public LanguageService(ILanguageRepository languageRepository)
        {
            _languageRepository = languageRepository ?? throw new ArgumentNullException(nameof(languageRepository));
        }

        public async Task<List<Language>> GetAllLanguages()
        {
            return _languageRepository.GetAll().Result.ToList();
        }

        public async Task<Language> GetLanguageById(int languageId)
        {
            return _languageRepository.GetById(languageId).Result;
        }
    }
}
