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
        public DbSet<Activity> Activity { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<SearchHistory> SearchHistory { get; set; }
        public DbSet<UserDonation> UserDonations { get; set; }
        public DbSet<Language> Languages { get; set; }
        public DbSet<Playlist> Playlists { get; set; }
        public DbSet<Report> Reports { get; set; }

        public DbSet<MoodTracker> MoodTrackers { get; set; }

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
            modelBuilder.Entity<Track>().HasQueryFilter(t => t.SignedUrl != "" && !t.IsDeleted);
            modelBuilder.Entity<Playlist>().HasQueryFilter(p => !p.IsDeleted);

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

            #region Table Name Configuration

            modelBuilder.Entity<Language>().ToTable("Languages");

            #endregion
        }
    }
}
