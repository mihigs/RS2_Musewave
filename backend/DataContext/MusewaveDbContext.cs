using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Models;

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
            modelBuilder.Entity<Artist>()
                .HasOne(a => a.User)
                .WithOne()
                .HasForeignKey<Artist>(a => a.ArtistId);

            modelBuilder.Entity<Artist>()
                .HasMany(a => a.Albums)
                .WithOne(b => b.Artist)
                .HasForeignKey(b => b.ArtistId);

            modelBuilder.Entity<Album>()
                .HasMany(b => b.Tracks)
                .WithOne(t => t.Album)
                .HasForeignKey(t => t.AlbumId);
            modelBuilder.Entity<Playlist>()
                .HasOne(p => p.User)
                .WithMany(u => u.Playlists)
                .HasForeignKey(p => p.UserId);
            modelBuilder.Entity<Track>(entity =>
            {
                entity.HasOne(t => t.Album)
                    .WithMany(a => a.Tracks)
                    .HasForeignKey(t => t.AlbumId);

                entity.HasMany(t => t.PlaylistTracks)
                    .WithOne(pt => pt.Track)
                    .HasForeignKey(pt => pt.TrackId);

                entity.HasMany(t => t.Likes)
                    .WithOne(l => l.Track)
                    .HasForeignKey(l => l.TrackId);
            });
            modelBuilder.Entity<PlaylistTrack>()
                .HasKey(pt => new { pt.PlaylistId, pt.TrackId });

            modelBuilder.Entity<PlaylistTrack>()
                .HasOne(pt => pt.Playlist)
                .WithMany(p => p.PlaylistTracks)
                .HasForeignKey(pt => pt.PlaylistId);

            modelBuilder.Entity<PlaylistTrack>()
                .HasOne(pt => pt.Track)
                .WithMany(t => t.PlaylistTracks)
                .HasForeignKey(pt => pt.TrackId);
            modelBuilder.Entity<Like>()
                .HasKey(l => new { l.UserId, l.TrackId });

            modelBuilder.Entity<Like>()
                .HasOne(l => l.User)
                .WithMany(u => u.Likes)
                .HasForeignKey(l => l.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Like>()
                .HasOne(l => l.Track)
                .WithMany(t => t.Likes)
                .HasForeignKey(l => l.TrackId)
                .OnDelete(DeleteBehavior.Restrict);
            #endregion
        }
    }
}
