namespace DataContext.Repositories
{
    public interface IRepository<T> where T : class
    {
        Task<IEnumerable<T>> GetAll();
        Task<T> GetById(int id);
        Task<T> Add(T entity);
        Task<T> Update(T entity);
        Task<T> Remove(int id);
        Task<IEnumerable<T>> AddRange(IEnumerable<T> entities);
        Task<IEnumerable<T>> UpdateRange(IEnumerable<T> entities);
        Task<IEnumerable<T>> RemoveRange(IEnumerable<T> entities);
    }
}
