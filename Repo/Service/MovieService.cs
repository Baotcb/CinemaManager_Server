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
        public Movie GetMovieById(int id)
        {
            return _context.Movies.FirstOrDefault(x => x.MovieId == id);
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
