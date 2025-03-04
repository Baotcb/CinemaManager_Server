using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Repo.Service;

namespace Cinema_Manager_Serve.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MovieController : ControllerBase
    {
        private readonly ILogger<MovieController> _logger;
        private readonly MovieService _movieService = new MovieService();
        public MovieController(ILogger<MovieController> logger)
        {
            _logger = logger;
        }
        [HttpGet("GetAllMovies")]
        public IActionResult GetAllMovies()
        {
            var movies = _movieService.GetAllMovie();
            return Ok(movies);
        }
        [HttpGet("GetShowingMovies")]
        public IActionResult GetShowingMovies()
        {
            var movies = _movieService.GetShowingMovie();
            return Ok(movies);
        }
        [HttpGet("GetUpComingMovies")]
        public IActionResult GetUpComingMovies()
        {
            var movies = _movieService.GetUpComingMovies();
            return Ok(movies);
        }
        [HttpGet("GetMovieById/{id}")]
        public IActionResult GetMovieById(int id)
        {
            var movie = _movieService.GetMovieById(id);
            return Ok(movie);
        }
    }
}
