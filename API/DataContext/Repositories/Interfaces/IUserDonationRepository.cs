﻿using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories;
public interface IUserDonationRepository : IRepository<UserDonation>
{
}