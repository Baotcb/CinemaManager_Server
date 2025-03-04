using System;
using System.Collections.Generic;

namespace Repo.Entities;

public partial class Movie
{
    public int MovieId { get; set; }

    public string Title { get; set; } = null!;

    public string? Description { get; set; }

    public int Duration { get; set; }

    public DateOnly? ReleaseDate { get; set; }

    public DateOnly? EndDate { get; set; }

    public string? Genre { get; set; }

    public string? Director { get; set; }

    public string? Cast { get; set; }

    public string? PosterUrl { get; set; }

    public string? TrailerUrl { get; set; }

    public string? Language { get; set; }

    public string? Subtitle { get; set; }

    public decimal? Rating { get; set; }

    public string? AgeRestriction { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual ICollection<Showtime> Showtimes { get; set; } = new List<Showtime>();
}
