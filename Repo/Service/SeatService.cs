using Microsoft.EntityFrameworkCore;
using Repo.Dto;
using Repo.Entities;

namespace Repo.Service
{
    public class SeatService
    {
        private readonly CinemaManagerContext _context=new CinemaManagerContext();

        //  public List<AvailableSeatDTO> GetAvailableSeats(
        //int movieId,
        //string cinemaName,
        //DateTime showDate,
        //TimeSpan startTimeBegin,
        //TimeSpan? startTimeEnd = null)
        //  {
        //      var startTimePart = startTimeBegin.ToString(@"hh\:mm\:ss");
        //      var endTimePart = startTimeEnd?.ToString(@"hh\:mm\:ss");
        //      var datePart = showDate.ToString("yyyy-MM-dd");

        //      var query = $"EXEC GetAvailableSeats @movieId = {movieId}, " +
        //                  $"@cinemaName = '{cinemaName}', " +
        //                  $"@showDate = '{datePart}', " +
        //                  $"@startTimeBegin = '{startTimePart}'";

        //      if (startTimeEnd.HasValue)
        //      {
        //          query += $", @startTimeEnd = '{endTimePart}'";
        //      }

        //      var results = new List<AvailableSeatDTO>();

        //      try
        //      {
        //          using (var command = _context.Database.GetDbConnection().CreateCommand())
        //          {
        //              command.CommandText = query;

        //              if (command.Connection.State != System.Data.ConnectionState.Open)
        //                  command.Connection.Open();

        //              using var reader = command.ExecuteReader();
        //              while (reader.Read())
        //              {
        //                  results.Add(new AvailableSeatDTO
        //                  {
        //                      SeatId = reader.GetInt32(reader.GetOrdinal("seat_id")),
        //                      SeatRow = reader.GetString(reader.GetOrdinal("seat_row")),
        //                      SeatNumber = reader.GetInt32(reader.GetOrdinal("seat_number")),
        //                      SeatType = reader.GetString(reader.GetOrdinal("seat_type")),
        //                      PriceModifier = reader.GetDecimal(reader.GetOrdinal("price_modifier")),
        //                      RoomName = reader.GetString(reader.GetOrdinal("room_name")),
        //                      RoomType = reader.GetString(reader.GetOrdinal("room_type")),
        //                      MovieTitle = reader.GetString(reader.GetOrdinal("movie_title")),
        //                      CinemaName = reader.GetString(reader.GetOrdinal("cinema_name")),
        //                      ShowtimeId = reader.GetInt32(reader.GetOrdinal("showtime_id")),
        //                      StartTime = reader.GetDateTime(reader.GetOrdinal("start_time")),
        //                      EndTime = reader.GetDateTime(reader.GetOrdinal("end_time")),
        //                      StandardPrice = reader.GetDecimal(reader.GetOrdinal("standard_price")),
        //                      StudentPrice = reader.GetDecimal(reader.GetOrdinal("student_price")),
        //                      ChildPrice = reader.GetDecimal(reader.GetOrdinal("child_price")),
        //                      SeniorPrice = reader.GetDecimal(reader.GetOrdinal("senior_price"))
        //                  });
        //              }
        //          }
        //      }
        //      catch (Exception ex)
        //      {

        //          Console.WriteLine(ex.Message);
        //      }

        //      return results;
        //  }
        //   public List<AvailableSeatDTO> GetAvailableSeats(
        //int movieId,
        //string cinemaName,
        //DateTime showDate,
        //TimeSpan startTimeBegin,
        //TimeSpan? startTimeEnd = null)
        //   {
        //       // If end time not specified, set to end of day
        //       TimeSpan endTime = startTimeEnd ?? new TimeSpan(23, 59, 59);

        //       // Use LINQ to query the database
        //       var query = from s in _context.Seats
        //                   join r in _context.Rooms on s.RoomId equals r.RoomId
        //                   join c in _context.Cinemas on r.CinemaId equals c.CinemaId
        //                   join st in _context.Showtimes on r.RoomId equals st.RoomId
        //                   join m in _context.Movies on st.MovieId equals m.MovieId
        //                   join bd in _context.BookingDetails on new { s.SeatId, st.ShowtimeId } equals new { bd.SeatId, bd.ShowtimeId } into bookingDetails
        //                   from bd in bookingDetails.DefaultIfEmpty()
        //                   join b in _context.Bookings on bd.BookingId equals b.BookingId into bookings
        //                   from b in bookings.DefaultIfEmpty()
        //                   let startTimeDate = st.StartTime.Date
        //                   let startTimeTime = st.StartTime.TimeOfDay
        //                   where m.MovieId == movieId
        //                      && c.Name == cinemaName
        //                      && startTimeDate == showDate.Date
        //                      && startTimeTime >= startTimeBegin
        //                      && startTimeTime <= endTime
        //                      && (bd == null || b.BookingStatus == "Cancelled")
        //                   orderby st.StartTime, s.SeatRow, s.SeatNumber
        //                   select new AvailableSeatDTO
        //                   {
        //                       SeatId = s.SeatId,
        //                       SeatRow = s.SeatRow,
        //                       SeatNumber = s.SeatNumber,
        //                       SeatType = s.SeatType,
        //                       PriceModifier = s.PriceModifier ?? 1.0m,
        //                       RoomName = r.RoomName,
        //                       RoomType = r.RoomType,
        //                       MovieTitle = m.Title,
        //                       CinemaName = c.Name,
        //                       ShowtimeId = st.ShowtimeId,
        //                       StartTime = st.StartTime,
        //                       EndTime = st.EndTime,
        //                       StandardPrice = st.BasePrice * (s.PriceModifier ?? 1.0m),
        //                       StudentPrice = (st.StudentPrice ?? st.BasePrice * 0.8m) * (s.PriceModifier ?? 1.0m),
        //                       ChildPrice = (st.ChildPrice ?? st.BasePrice * 0.7m) * (s.PriceModifier ?? 1.0m),
        //                       SeniorPrice = (st.SeniorPrice ?? st.BasePrice * 0.8m) * (s.PriceModifier ?? 1.0m)
        //                   };

        //       try
        //       {
        //           return query.ToList();
        //       }
        //       catch (Exception ex)
        //       {
        //           Console.WriteLine($"Error fetching available seats: {ex.Message}");
        //           return new List<AvailableSeatDTO>();
        //       }
        //   }
        public List<RoomSeatMapDTO> GetRoomSeatingMap(
       int movieId,
       string cinemaName,
       DateTime showDate,
       TimeSpan startTimeBegin,
       TimeSpan? startTimeEnd = null)
        {
            try
            {
                // If end time not specified, set to end of day
                TimeSpan endTime = startTimeEnd ?? new TimeSpan(23, 59, 59);

                // Use LINQ to query the database - joined query to match the stored procedure logic
                var query = from s in _context.Seats
                            join r in _context.Rooms on s.RoomId equals r.RoomId
                            join c in _context.Cinemas on r.CinemaId equals c.CinemaId
                            join st in _context.Showtimes on r.RoomId equals st.RoomId
                            join m in _context.Movies on st.MovieId equals m.MovieId
                            join bd in _context.BookingDetails on new { s.SeatId, st.ShowtimeId } equals new { bd.SeatId, bd.ShowtimeId } into bookingDetails
                            from bd in bookingDetails.DefaultIfEmpty()
                            join b in _context.Bookings on bd != null ? bd.BookingId : 0 equals b.BookingId into bookings
                            from b in bookings.DefaultIfEmpty()
                            join u in _context.Users on b != null ? b.UserId : 0 equals u.UserId into users
                            from u in users.DefaultIfEmpty()
                            let startTimeDate = st.StartTime.Date
                            let startTimeTime = st.StartTime.TimeOfDay
                            where m.MovieId == movieId
                               && c.Name == cinemaName
                               && startTimeDate == showDate.Date
                               && startTimeTime >= startTimeBegin
                               && startTimeTime <= endTime
                            orderby st.StartTime, s.SeatRow, s.SeatNumber
                            select new RoomSeatMapDTO
                            {
                                // Seat information
                                SeatId = s.SeatId,
                                SeatRow = s.SeatRow,
                                SeatNumber = s.SeatNumber,
                                SeatType = s.SeatType,
                                PriceModifier = s.PriceModifier ?? 1.0m,

                                // Room information
                                RoomName = r.RoomName,
                                RoomType = r.RoomType ?? "Standard",

                                // Movie and showtime information
                                MovieTitle = m.Title,
                                CinemaName = c.Name,
                                ShowtimeId = st.ShowtimeId,
                                StartTime = st.StartTime,
                                EndTime = st.EndTime,

                                // Seat status
                                SeatStatus = bd == null ? "Available" :
                                             b != null && b.BookingStatus == "Cancelled" ? "Available" :
                                             "Booked",

                                // Pricing information
                                StandardPrice = st.BasePrice * (s.PriceModifier ?? 1.0m),
                                StudentPrice = (st.StudentPrice ?? st.BasePrice * 0.8m) * (s.PriceModifier ?? 1.0m),
                                ChildPrice = (st.ChildPrice ?? st.BasePrice * 0.7m) * (s.PriceModifier ?? 1.0m),
                                SeniorPrice = (st.SeniorPrice ?? st.BasePrice * 0.8m) * (s.PriceModifier ?? 1.0m),

                                // Booking information (if any)
                                BookedTicketType = bd != null ? bd.TicketType : null,
                                BookedPrice = bd != null ? bd.Price : 0,
                                BookingId = b != null ? b.BookingId : 0,
                                BookingStatus = b != null ? b.BookingStatus : null,
                                BookedByUsername = u != null ? u.Username : null,
                                BookingDate = b != null ? b.BookingDate : null
                            };

                var result = query.ToList();

                // Also fetch showtime information separately (like first result set in stored proc)
                var showtimeInfo = (from st in _context.Showtimes
                                    join r in _context.Rooms on st.RoomId equals r.RoomId
                                    join c in _context.Cinemas on r.CinemaId equals c.CinemaId
                                    join m in _context.Movies on st.MovieId equals m.MovieId
                                    let startTimeDate = st.StartTime.Date
                                    let startTimeTime = st.StartTime.TimeOfDay
                                    where m.MovieId == movieId
                                       && c.Name == cinemaName
                                       && startTimeDate == showDate.Date
                                       && startTimeTime >= startTimeBegin
                                       && startTimeTime <= endTime
                                    select new ShowtimeInfoDTO
                                    {
                                        ShowtimeId = st.ShowtimeId,
                                        RoomId = r.RoomId,
                                        RoomName = r.RoomName,
                                        RoomType = r.RoomType ?? "Standard",
                                        MovieTitle = m.Title,
                                        StartTime = st.StartTime,
                                        EndTime = st.EndTime,
                                        BasePrice = st.BasePrice
                                    }).FirstOrDefault();

               
                if (result.Count > 0 && showtimeInfo != null)
                {
                    foreach (var seat in result)
                    {
                        seat.ShowtimeInfo = showtimeInfo;
                    }
                }

                return result;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching room seating map: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                return new List<RoomSeatMapDTO>();
            }
        }

    }
    public class AvailableSeatDTO
    {
        public int SeatId { get; set; }
        public string SeatRow { get; set; }
        public int SeatNumber { get; set; }
        public string SeatType { get; set; }
        public decimal PriceModifier { get; set; }
        public string RoomName { get; set; }
        public string RoomType { get; set; }
        public string MovieTitle { get; set; }
        public string CinemaName { get; set; }
        public int ShowtimeId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal StandardPrice { get; set; }
        public decimal StudentPrice { get; set; }
        public decimal ChildPrice { get; set; }
        public decimal SeniorPrice { get; set; }
    }
    public class RoomSeatMapDTO
    {
        // Seat information
        public int SeatId { get; set; }
        public string SeatRow { get; set; }
        public int SeatNumber { get; set; }
        public string SeatType { get; set; }
        public decimal PriceModifier { get; set; }

        
        public string RoomName { get; set; }
        public string RoomType { get; set; }

        // Movie and showtime information
        public string MovieTitle { get; set; }
        public string CinemaName { get; set; }
        public int ShowtimeId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }

        // Seat status
        public string SeatStatus { get; set; }

        
        public decimal StandardPrice { get; set; }
        public decimal StudentPrice { get; set; }
        public decimal ChildPrice { get; set; }
        public decimal SeniorPrice { get; set; }

        
        public string BookedTicketType { get; set; }
        public decimal BookedPrice { get; set; }
        public int BookingId { get; set; }
        public string BookingStatus { get; set; }
        public string BookedByUsername { get; set; }
        public DateTime? BookingDate { get; set; }

       
        public ShowtimeInfoDTO ShowtimeInfo { get; set; }
    }

    public class ShowtimeInfoDTO
    {
        public int ShowtimeId { get; set; }
        public int RoomId { get; set; }
        public string RoomName { get; set; }
        public string RoomType { get; set; }
        public string MovieTitle { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal BasePrice { get; set; }
    }
}
