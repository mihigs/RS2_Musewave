using DataContext;

namespace Services.Implementations
{
    public class ActivityService
    {

        public ActivityService()
        {
        }

        //public bool AddLoginActivity(LoginActivity activity)
        //{
        //    try
        //    {
        //        // Add activity to database
        //        _dbContext.LoginActivities.Add(activity);
        //        _dbContext.SaveChanges();
        //        return true;
        //    }
        //    catch (Exception ex)
        //    {
        //        // Log error
        //        throw;
        //    }
        //}

        //public List<LoginActivity> GetAllLoginActivities()
        //{
        //    try
        //    {
        //        var activities = _dbContext.LoginActivities.ToList();
        //        return activities;
        //    }
        //    catch (Exception ex)
        //    {
        //        // Log error
        //        throw;
        //    }
        //}

        //public async Task<PaginationResponseDto> FilterActivities(FilterActivitiesDto model)
        //{
        //    var query = _dbContext.LoginActivities.AsQueryable();

        //    if (!string.IsNullOrEmpty(model.Email))
        //    {
        //        query = query.Where(u => u.Email.Contains(model.Email));
        //    }

        //    if (!string.IsNullOrEmpty(model.SortBy))
        //    {
        //        var sortBy = model.SortBy;
        //        query = sortBy switch
        //        {
        //            "Email" => model.SortDescending.Value ? query.OrderByDescending(u => u.Email) : query.OrderBy(u => u.Email),
        //            "Success" => model.SortDescending.Value ? query.OrderByDescending(u => u.Success) : query.OrderBy(u => u.Success),
        //            "Timestamp" => model.SortDescending.Value ? query.OrderByDescending(u => u.Timestamp) : query.OrderBy(u => u.Timestamp),
        //            _ => query // Default case
        //        };
        //    }

        //    var totalCount = await query.CountAsync();

        //    if (model.PageNumber != null && model.PageSize != null)
        //    {
        //        query = query.Skip((model.PageNumber.Value) * model.PageSize.Value).Take(model.PageSize.Value);
        //    }

        //    var activities = await query.ToListAsync();
        //    var rows = new List<dynamic>(activities);

        //    return new PaginationResponseDto
        //    {
        //        Rows = rows,
        //        TotalCount = totalCount
        //    };
        //}
    }
}
