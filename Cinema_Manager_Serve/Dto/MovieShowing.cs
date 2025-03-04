namespace Cinema_Manager_Serve.Dto
{
    public class MovieShowing
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
    }
}
