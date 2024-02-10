using DataContext.Repositories;

namespace DataContext.Seeder
{
    abstract class BaseSeeder
    {
        protected IUnitOfWork UnitOfWork { get; }
        public BaseSeeder(IUnitOfWork unitOfWork)
        {
            UnitOfWork = unitOfWork;
        }
    }
}
