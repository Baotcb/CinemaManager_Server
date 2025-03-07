using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Repo.Service;

namespace Cinema_Manager_Serve.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CinemaController : ControllerBase
    {
        private readonly ILogger<CinemaController> _logger;

        public CinemaController(ILogger<CinemaController> logger)
        {
            _logger = logger;
        }

        private CinemaService _cinemaService = new CinemaService();
        [HttpGet("GetAllCinemas")]
        public IActionResult GetAllCinemas()
        {
            var cinemas = _cinemaService.GetAllCinema();
            return Ok(cinemas);
        }
    }
}
