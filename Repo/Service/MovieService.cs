using Cinema_Manager_Serve.Dto;
using Microsoft.EntityFrameworkCore;
using Repo.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repo.Service
{
    public class MovieService
    {
        private CinemaManagerContext _context = new CinemaManagerContext();
        public List<Movie> GetAllMovie()
        {
            return _context.Movies.ToList();
        }
        public List<MovieShowing> GetShowingMovie()
        {
            var today = DateOnly.FromDateTime(DateTime.Now);
            return _context.Movies
                .Include(x => x.Showtimes)
                .Where(x => x.ReleaseDate <= today && x.EndDate >= today)
                .AsEnumerable() 
                .Select(x => new MovieShowing
                {
                    MovieId = x.MovieId,
                    Title = x.Title,
          
                    Showtimes = x.Showtimes
                        .OrderBy(s => s.StartTime.TimeOfDay)
                        .Select(s => s.StartTime.ToString("HH:mm"))
                        .ToList(),
                    Description = x.Description,
                    Duration = x.Duration,
                    ReleaseDate = x.ReleaseDate,
                    EndDate = x.EndDate,
                    Genre = x.Genre,
                    Director = x.Director,
                    Cast = x.Cast,
                    PosterUrl = x.PosterUrl,
                    TrailerUrl = x.TrailerUrl,
                    Language = x.Language,
                    Subtitle = x.Subtitle,
                    Rating = x.Rating,
                    AgeRestriction = x.AgeRestriction
                })
                .ToList();
        }


        public List<Movie> GetUpComingMovies()
        {
            var today = DateOnly.FromDateTime(DateTime.Now);
            return _context.Movies
                .Where(x => x.ReleaseDate > today)
                .ToList();
        }
        public MovieShowing GetMovieById(int id)
        {
           
            var movie = _context.Movies
                .Include(x => x.Showtimes)
                    .ThenInclude(s => s.Room)
                        .ThenInclude(r => r.Cinema)
                .FirstOrDefault(x => x.MovieId == id);

            if (movie == null)
            {
                return null;
            }

           
            var showtimes = movie.Showtimes
                .OrderBy(s => s.StartTime)
                .Select(s => $"{s.Room.Cinema.Name} - {s.StartTime}")
                .ToList();

            return new MovieShowing
            {
                MovieId = movie.MovieId,
                Title = movie.Title,
                Showtimes = showtimes,
                Description = movie.Description,
                Duration = movie.Duration,
                ReleaseDate = movie.ReleaseDate,
                EndDate = movie.EndDate,
                Genre = movie.Genre,
                Director = movie.Director,
                Cast = movie.Cast,
                PosterUrl = movie.PosterUrl,
                TrailerUrl = movie.TrailerUrl,
                Language = movie.Language,
                Subtitle = movie.Subtitle,
                Rating = movie.Rating,
                AgeRestriction = movie.AgeRestriction
            };
        }


        public bool AddMovie(Movie movie)
        {
            var check = _context.Movies.FirstOrDefault(x => x.Title == movie.Title);
            if (check != null)
            {
                return false;
            }
            _context.Movies.Add(movie);
            _context.SaveChanges();
            return true;
        }
        public bool DeleteMovie(int id)
        {
            var movie = _context.Movies.FirstOrDefault(x => x.MovieId == id);
            if (movie == null)
            {
                return false;
            }
            _context.Movies.Remove(movie);
            _context.SaveChanges();
            return true;
        }
    }
}
