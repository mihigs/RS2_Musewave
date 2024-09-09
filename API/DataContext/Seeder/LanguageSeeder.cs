using DataContext.Repositories.Interfaces;
using Microsoft.AspNetCore.Identity;
using Models.Entities;

namespace DataContext.Seeder
{
    internal class LanguageSeeder
    {
        private readonly ILanguageRepository _languageRepository;

        public LanguageSeeder(ILanguageRepository languageRepository)
        {
            _languageRepository = languageRepository;
        }

        public async Task<bool> Seed()
        {
            try
            {
                // Check if there are any languages in the database
                var existingLanguages = _languageRepository.GetAll().Result.Any();

                if (existingLanguages)
                {
                    return false;
                }

                // Create a list of languages
                List<Language> languages = new List<Language>
                {
                    new Language { Name = "English", Code = "en" },
                    new Language { Name = "Spanish", Code = "es" },
                    new Language { Name = "French", Code = "fr" },
                    new Language { Name = "German", Code = "de" },
                    new Language { Name = "Bosnian", Code = "bs" },

                };

                // Add the languages to the database
                await _languageRepository.AddRange(languages);

                return true;
            }
            catch (Exception ex)
            {
                // Log error
                Console.WriteLine($"LanguageSeeder failed: {ex.Message}");
                throw ex;
            }
        }
    }
}
