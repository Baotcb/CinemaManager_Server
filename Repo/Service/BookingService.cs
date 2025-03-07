using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Repo.Entities;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;

namespace Repo.Service
{
    public class BookingService
    {
        private CinemaManagerContext cinemaManagerContext = new CinemaManagerContext();

        /// <summary>
        /// Books tickets for a showtime using the stored procedure
        /// </summary>
        /// <param name="userId">The user ID</param>
        /// <param name="showtimeId">The showtime ID</param>
        /// <param name="seatIds">List of seat IDs to book</param>
        /// <param name="ticketTypes">List of ticket types corresponding to each seat</param>
        /// <param name="paymentMethod">Payment method used</param>
        /// <returns>Booking result with ID, transaction ID and status</returns>
        public BookingResult BookTickets(
    int userId,
    int showtimeId,
    List<int> seatIds,
    List<string> ticketTypes,
    string paymentMethod)
        {
            // Validate inputs
            if (seatIds == null || ticketTypes == null || seatIds.Count == 0 || seatIds.Count != ticketTypes.Count)
            {
                throw new ArgumentException("Invalid seat IDs or ticket types");
            }

            // Convert lists to comma-separated strings for stored procedure
            string seatIdsString = string.Join(",", seatIds);
            string ticketTypesString = string.Join(",", ticketTypes);

            try
            {
                BookingProcResult result = null;

                // Use connection directly to avoid EF Core's limitations with stored procedures
                using (var connection = new SqlConnection(cinemaManagerContext.Database.GetConnectionString()))
                {
                    connection.Open();

                    using (var command = connection.CreateCommand())
                    {
                        command.CommandText = "BookTickets";
                        command.CommandType = CommandType.StoredProcedure;

                        // Add parameters
                        command.Parameters.Add(new SqlParameter("@user_id", SqlDbType.Int) { Value = userId });
                        command.Parameters.Add(new SqlParameter("@showtime_id", SqlDbType.Int) { Value = showtimeId });
                        command.Parameters.Add(new SqlParameter("@seat_ids", SqlDbType.NVarChar) { Value = seatIdsString });
                        command.Parameters.Add(new SqlParameter("@ticket_types", SqlDbType.NVarChar) { Value = ticketTypesString });
                        command.Parameters.Add(new SqlParameter("@payment_method", SqlDbType.NVarChar, 50) { Value = paymentMethod });

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Check for error message first (your stored procedure returns this when there's an error)
                                if (reader.FieldCount > 1 && !reader.IsDBNull(1) && reader.GetName(1) == "error_message")
                                {
                                    string errorMessage = reader.GetString(1);
                                    return new BookingResult
                                    {
                                        Success = false,
                                        ErrorMessage = errorMessage
                                    };
                                }

                                // Otherwise, it's a successful result
                                result = new BookingProcResult
                                {
                                    BookingId = reader.GetInt32(reader.GetOrdinal("booking_id")),
                                    TransactionId = reader.IsDBNull(reader.GetOrdinal("transaction_id")) ? null :
                                                  reader.GetString(reader.GetOrdinal("transaction_id")),
                                    TotalAmount = reader.GetDecimal(reader.GetOrdinal("total_amount")),
                                    PaymentMethod = reader.GetString(reader.GetOrdinal("payment_method")),
                                    Status = reader.GetString(reader.GetOrdinal("status"))
                                };
                            }
                        }
                    }
                }

                if (result?.BookingId > 0)
                {
                    return new BookingResult
                    {
                        Success = true,
                        BookingId = result.BookingId,
                        TransactionId = result.TransactionId,
                        TotalAmount = result.TotalAmount,
                        PaymentMethod = result.PaymentMethod,
                        Status = result.Status,
                        ErrorMessage = null
                    };
                }
                else
                {
                    return new BookingResult
                    {
                        Success = false,
                        ErrorMessage = "Failed to create booking"
                    };
                }
            }
            catch (Exception ex)
            {
                return new BookingResult
                {
                    Success = false,
                    ErrorMessage = ex.Message
                };
            }
        }


        /// <summary>
        /// Gets booking details by booking ID
        /// </summary>
        /// <param name="bookingId">Booking ID</param>
        /// <returns>Booking with details</returns>
        public Booking GetBookingById(int bookingId)
        {
            return cinemaManagerContext.Bookings
                .Include(b => b.User)
                .Include(b => b.BookingDetails)
                    .ThenInclude(bd => bd.Seat)
                .Include(b => b.BookingDetails)
                    .ThenInclude(bd => bd.Showtime)
                        .ThenInclude(s => s.Movie)
                .FirstOrDefault(b => b.BookingId == bookingId);
        }

        /// <summary>
        /// Gets all bookings for a user
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <returns>List of bookings</returns>
        public List<BookingDto> GetBookingsByUser(int userId)
        {
            var bookings = cinemaManagerContext.Bookings
                .Include(b => b.BookingDetails)
                    .ThenInclude(bd => bd.Showtime)
                        .ThenInclude(s => s.Movie)
                .Include(b => b.BookingDetails)
                    .ThenInclude(bd => bd.Seat)
                .Where(b => b.UserId == userId)
                .OrderByDescending(b => b.BookingDate)
                .ToList();

            // Map to DTOs to break circular references
            return bookings.Select(b => new BookingDto
            {
                BookingId = b.BookingId,
                UserId = b.UserId,
                BookingDate = b.BookingDate,
                TotalAmount = b.TotalAmount,
                DiscountAmount = b.DiscountAmount,
                DiscountCode = b.DiscountCode,
                AdditionalPurchases = b.AdditionalPurchases,
                PaymentMethod = b.PaymentMethod,
                TransactionId = b.TransactionId,
                BookingStatus = b.BookingStatus,
                PaymentStatus = b.PaymentStatus,
                PaymentDate = b.PaymentDate,
                CreatedAt = b.CreatedAt,
                UpdatedAt = b.UpdatedAt,
                BookingDetails = b.BookingDetails.Select(bd => new BookingDetailDto
                {
                    BookingDetailId = bd.BookingDetailId,
                    BookingId = bd.BookingId,
                    ShowtimeId = bd.ShowtimeId,
                    SeatId = bd.SeatId,
                    Price = bd.Price,
                    TicketType = bd.TicketType,
                    // Include showtime info
                    ShowtimeInfo = new ShowtimeDto
                    {
                        ShowtimeId = bd.Showtime.ShowtimeId,
                        MovieId = bd.Showtime.MovieId,
                        RoomId = bd.Showtime.RoomId,
                        StartTime = bd.Showtime.StartTime,
                        EndTime = bd.Showtime.EndTime,
                        BasePrice = bd.Showtime.BasePrice,
                        // Include movie info
                        MovieInfo = new MovieInfoDto
                        {
                            MovieId = bd.Showtime.Movie.MovieId,
                            Title = bd.Showtime.Movie.Title,
                            PosterUrl = bd.Showtime.Movie.PosterUrl,
                            Duration = bd.Showtime.Movie.Duration
                        }
                    },
                    // Include seat info
                    SeatInfo = new SeatInfoDto
                    {
                        SeatId = bd.Seat.SeatId,
                        SeatRow = bd.Seat.SeatRow,
                        SeatNumber = bd.Seat.SeatNumber,
                        SeatType = bd.Seat.SeatType
                    }
                }).ToList()
            }).ToList();
        }

        /// <summary>
        /// Cancels a booking
        /// </summary>
        /// <param name="bookingId">Booking ID</param>
        /// <returns>True if cancellation was successful</returns>
        public CancelBookingResult CancelBooking(int bookingId, int userId)
        {
            try
            {
                CancelBookingProcResult result = null;

                // Use connection directly to call the stored procedure
                using (var connection = new SqlConnection(cinemaManagerContext.Database.GetConnectionString()))
                {
                    connection.Open();

                    using (var command = connection.CreateCommand())
                    {
                        command.CommandText = "CancelBooking";
                        command.CommandType = CommandType.StoredProcedure;

                        // Add parameters
                        command.Parameters.Add(new SqlParameter("@booking_id", SqlDbType.Int) { Value = bookingId });
                        command.Parameters.Add(new SqlParameter("@user_id", SqlDbType.Int) { Value = userId });

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Check if there's an error message
                                if (reader.FieldCount > 1 && reader.GetName(1) == "error_message" && !reader.IsDBNull(1))
                                {
                                    string errorMessage = reader.GetString(1);
                                    return new CancelBookingResult
                                    {
                                        Success = false,
                                        ErrorMessage = errorMessage
                                    };
                                }

                                // Read successful result
                                result = new CancelBookingProcResult
                                {
                                    BookingId = reader.GetInt32(reader.GetOrdinal("booking_id")),
                                    BookingStatus = reader.GetString(reader.GetOrdinal("booking_status")),
                                    PaymentStatus = reader.GetString(reader.GetOrdinal("payment_status")),
                                    Message = reader.GetString(reader.GetOrdinal("message"))
                                };
                            }
                        }
                    }
                }

                if (result?.BookingId > 0)
                {
                    return new CancelBookingResult
                    {
                        Success = true,
                        BookingId = result.BookingId,
                        BookingStatus = result.BookingStatus,
                        PaymentStatus = result.PaymentStatus,
                        Message = result.Message
                    };
                }
                else
                {
                    return new CancelBookingResult
                    {
                        Success = false,
                        ErrorMessage = "Failed to cancel booking"
                    };
                }
            }
            catch (Exception ex)
            {
                return new CancelBookingResult
                {
                    Success = false,
                    ErrorMessage = ex.Message
                };
            }
        }
    }

    
    public class BookingProcResult
    {
        public int BookingId { get; set; }
        public string TransactionId { get; set; }
        public decimal TotalAmount { get; set; }
        public string PaymentMethod { get; set; }
        public string Status { get; set; }
        public string ErrorMessage { get; set; }
    }

   
    public class BookingResult
    {
        public bool Success { get; set; }
        public int BookingId { get; set; }
        public string TransactionId { get; set; }
        public decimal TotalAmount { get; set; }
        public string PaymentMethod { get; set; }
        public string Status { get; set; }
        public string ErrorMessage { get; set; }
    }
    public class BookingDto
    {
        public int BookingId { get; set; }
        public int UserId { get; set; }
        public DateTime? BookingDate { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal? DiscountAmount { get; set; }
        public string? DiscountCode { get; set; }
        public decimal? AdditionalPurchases { get; set; }
        public string? PaymentMethod { get; set; }
        public string? TransactionId { get; set; }
        public string BookingStatus { get; set; }
        public string PaymentStatus { get; set; }
        public DateTime? PaymentDate { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public List<BookingDetailDto> BookingDetails { get; set; } = new();
    }

    public class BookingDetailDto
    {
        public int BookingDetailId { get; set; }
        public int BookingId { get; set; }
        public int ShowtimeId { get; set; }
        public int SeatId { get; set; }
        public decimal Price { get; set; }
        public string? TicketType { get; set; }
        public ShowtimeDto ShowtimeInfo { get; set; }
        public SeatInfoDto SeatInfo { get; set; }
    }

    public class ShowtimeDto
    {
        public int ShowtimeId { get; set; }
        public int MovieId { get; set; }
        public int RoomId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal BasePrice { get; set; }
        public MovieInfoDto MovieInfo { get; set; }
    }

    public class MovieInfoDto
    {
        public int MovieId { get; set; }
        public string Title { get; set; }
        public string? PosterUrl { get; set; }
        public int Duration { get; set; }
    }

    public class SeatInfoDto
    {
        public int SeatId { get; set; }
        public string SeatRow { get; set; }
        public int SeatNumber { get; set; }
        public string SeatType { get; set; }
    }
    public class CancelBookingProcResult
    {
        public int BookingId { get; set; }
        public string BookingStatus { get; set; }
        public string PaymentStatus { get; set; }
        public string Message { get; set; }
    }

    public class CancelBookingResult
    {
        public bool Success { get; set; }
        public int BookingId { get; set; }
        public string BookingStatus { get; set; }
        public string PaymentStatus { get; set; }
        public string Message { get; set; }
        public string ErrorMessage { get; set; }
    }
}
