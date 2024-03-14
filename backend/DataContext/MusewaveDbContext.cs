using Microsoft.AspNetCore.Identity;
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
        //public DbSet<Playlist> Playlists { get; set; }

        public MusewaveDbContext(DbContextOptions<MusewaveDbContext> options)
            : base(options)
        {
            // Additional configuration or initialization if needed
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            #region Relationship Configuration
            modelBuilder.Entity<Track>()
                .HasOne(t => t.Genre)
                .WithMany()
                .HasForeignKey(t => t.GenreId)
                .OnDelete(DeleteBehavior.NoAction);

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
                .HasMany(u => u.Playlists)
                .WithOne(p => p.User)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasMany(u => u.Likes)
                .WithOne(l => l.User)
                .OnDelete(DeleteBehavior.NoAction);

            #endregion

            modelBuilder.Entity<Track>()
                .Ignore(t => t.SignedUrl);
        }
    }
}
