using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Repo.Entities;
using Repo.Service;
using System.Collections.Generic;

namespace Cinema_Manager_Serve.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookingController : ControllerBase
    {
        private readonly BookingService _bookingService;
        private readonly ILogger<BookingController> _logger;

        public BookingController(ILogger<BookingController> logger)
        {
            _bookingService = new BookingService();
            _logger = logger;
        }

        /// <summary>
        /// Books tickets for a showtime
        /// </summary>
        /// <param name="request">Booking request containing user, showtime, seats, and payment info</param>
        /// <returns>Booking result</returns>
        [HttpPost("BookTickets")]
        public IActionResult BookTickets([FromBody] BookTicketRequest request)
        {
            try
            {
                if (request == null || request.SeatIds == null || request.TicketTypes == null ||
                    request.SeatIds.Count == 0 || request.SeatIds.Count != request.TicketTypes.Count)
                {
                    return BadRequest(new { message = "Invalid booking data" });
                }

                var result = _bookingService.BookTickets(
                    request.UserId,
                    request.ShowtimeId,
                    request.SeatIds,
                    request.TicketTypes,
                    request.PaymentMethod);

                if (result.Success)
                {
                    return Ok(result);
                }
                else
                {
                    return BadRequest(new { message = result.ErrorMessage });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error booking tickets");
                return StatusCode(500, new { message = "An error occurred while booking tickets" });
            }
        }

        /// <summary>
        /// Gets booking details by ID
        /// </summary>
        /// <param name="id">Booking ID</param>
        /// <returns>Booking details</returns>
        [HttpGet("{id}")]
        public IActionResult GetBooking(int id)
        {
            try
            {
                var booking = _bookingService.GetBookingById(id);

                if (booking == null)
                {
                    return NotFound(new { message = "Booking not found" });
                }

                return Ok(booking);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting booking {BookingId}", id);
                return StatusCode(500, new { message = "An error occurred while retrieving the booking" });
            }
        }

        /// <summary>
        /// Gets all bookings for a user
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <returns>List of user's bookings</returns>
        [HttpGet("User/{userId}")]
        public IActionResult GetBookingsByUser(int userId)
        {
            try
            {
                var bookings = _bookingService.GetBookingsByUser(userId);
                return Ok(bookings);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting bookings for user {UserId}", userId);
                return StatusCode(500, new { message = "An error occurred while retrieving bookings" });
            }
        }

        /// <summary>
        /// Cancels a booking
        /// </summary>
        /// <param name="id">Booking ID</param>
        /// <returns>Result of cancellation</returns>
        [HttpPost("Cancel/{id}")]
        public IActionResult CancelBooking(int id)
        {
            try
            {
                var success = _bookingService.CancelBooking(id);

                if (success)
                {
                    return Ok(new { message = "Booking cancelled successfully" });
                }
                else
                {
                    return BadRequest(new { message = "Unable to cancel booking" });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cancelling booking {BookingId}", id);
                return StatusCode(500, new { message = "An error occurred while cancelling the booking" });
            }
        }
    }

    /// <summary>
    /// Model for booking ticket request
    /// </summary>
    public class BookTicketRequest
    {
        public int UserId { get; set; }
        public int ShowtimeId { get; set; }
        public List<int> SeatIds { get; set; } = new List<int>();
        public List<string> TicketTypes { get; set; } = new List<string>();
        public string PaymentMethod { get; set; } = "Credit Card";
    }
}
