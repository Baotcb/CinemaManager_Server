using Microsoft.AspNetCore.Mvc;
using Repo.Service;

namespace Cinema_Manager_Serve.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SeatController : ControllerBase
    {
        private SeatService _seatService = new SeatService();
        [HttpGet("GetAvailableSeats/{movieId}/{cinemaName}/{showDate}/{startTimeBegin}/{startTimeEnd}")]
        public IActionResult GetAvailableSeats(int movieId,string cinemaName , DateTime showDate, TimeSpan startTimeBegin, TimeSpan startTimeEnd)
        {
            var seats = _seatService.GetAvailableSeats(movieId, cinemaName, showDate, startTimeBegin, startTimeEnd);
            return Ok(seats);
        }
    }
}
