using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext
{
    public class MusewaveDbContext : IdentityDbContext<User>
    {
        public DbSet<Track> Tracks { get; set; }
        public DbSet<Album> Albums { get; set; }
        public DbSet<Artist> Artists { get; set; }
        public override DbSet<User> Users { get; set; }
        public DbSet<Genre> Genres { get; set; }
        public DbSet<TrackGenre> TrackGenres { get; set; }
        public DbSet<LoginActivity> LoginActivity { get; set; }
        public DbSet<JamendoAPIActivity> JamendoAPIActivity { get; set; }
        public DbSet<Comment> Comment { get; set; }
        public DbSet<SearchHistory> SearchHistory { get; set; }
        public MusewaveDbContext(DbContextOptions<MusewaveDbContext> options)
            : base(options)
        {
            // Additional configuration or initialization if needed
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Apply a global query filter for Track entity, to exclude tracks that have not been uploaded yet
            //modelBuilder.Entity<Track>().HasQueryFilter(t => t.FilePath != null);
            modelBuilder.Entity<Track>().HasQueryFilter(t => t.SignedUrl != "");

            #region Relationship Configuration
            modelBuilder.Entity<TrackGenre>()
                .HasKey(tg => new { tg.TrackId, tg.GenreId });

            modelBuilder.Entity<TrackGenre>()
                .HasOne(tg => tg.Track)
                .WithMany(b => b.TrackGenres)
                .HasForeignKey(tg => tg.TrackId);

            modelBuilder.Entity<Artist>()
                .HasOne(a => a.User)
                .WithOne(u => u.Artist)
                .HasForeignKey<Artist>(a => a.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<PlaylistTrack>()
                .HasKey(pt => new { pt.PlaylistId, pt.TrackId });

            modelBuilder.Entity<Like>()
                .HasOne(l => l.User)
                .WithMany(u => u.Likes)
                .HasForeignKey(l => l.UserId);

            modelBuilder.Entity<Like>()
                .HasOne(l => l.Track)
                .WithMany(t => t.Likes)
                .HasForeignKey(l => l.TrackId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasMany(u => u.Likes)
                .WithOne(l => l.User)
                .OnDelete(DeleteBehavior.NoAction);

            #endregion

            modelBuilder.Entity<Track>()
                .Ignore(t => t.IsLiked);
        }
    }
}
