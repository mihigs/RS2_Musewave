using Microsoft.AspNetCore.Identity;
using Models.Enums;

namespace DataContext.Seeder
{
    internal class RoleSeeder
    {
        private readonly RoleManager<IdentityRole> _roleManager;

        public RoleSeeder(RoleManager<IdentityRole> roleManager)
        {
            _roleManager = roleManager;
        }

        public async Task<bool> Seed()
        {
            try
            {
                foreach (var role in Enum.GetValues(typeof(Roles)))
                {
                    if (!await _roleManager.RoleExistsAsync(role.ToString()))
                    {
                        await _roleManager.CreateAsync(new IdentityRole(role.ToString()));
                    }
                }


                return true;
            }
            catch (Exception ex)
            {
                // Log error
                Console.WriteLine($"RoleSeeder failed: {ex.Message}");
                throw ex;
            }
        }
    }
}
