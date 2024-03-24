namespace DataContext.Repositories
{
    public interface IRepository<T> where T : class
    {
        abstract Task<IEnumerable<T>> GetAll();
        abstract Task<T> GetById(int id);
        abstract Task<T> Add(T entity);
        abstract Task<T> Update(T entity);
        abstract Task<T> Remove(int id);
        abstract Task<IEnumerable<T>> AddRange(IEnumerable<T> entities);
        abstract Task<IEnumerable<T>> UpdateRange(IEnumerable<T> entities);
        abstract Task<IEnumerable<T>> RemoveRange(IEnumerable<T> entities);
        abstract Task<IEnumerable<T>> GetAllIncluding(string[] includes);
    }
}
