using Microsoft.EntityFrameworkCore;
using Repo.Dto;
using Repo.Entities;

namespace Repo.Service
{
    public class SeatService
    {
        private readonly CinemaManagerContext _context=new CinemaManagerContext();

        public List<AvailableSeatDTO> GetAvailableSeats(
      int movieId,
      string cinemaName,
      DateTime showDate,
      TimeSpan startTimeBegin,
      TimeSpan? startTimeEnd = null)
        {
            var startTimePart = startTimeBegin.ToString(@"hh\:mm\:ss");
            var endTimePart = startTimeEnd?.ToString(@"hh\:mm\:ss");
            var datePart = showDate.ToString("yyyy-MM-dd");

            var query = $"EXEC GetAvailableSeats @movieId = {movieId}, " +
                        $"@cinemaName = '{cinemaName}', " +
                        $"@showDate = '{datePart}', " +
                        $"@startTimeBegin = '{startTimePart}'";

            if (startTimeEnd.HasValue)
            {
                query += $", @startTimeEnd = '{endTimePart}'";
            }

            var results = new List<AvailableSeatDTO>();

            try
            {
                using (var command = _context.Database.GetDbConnection().CreateCommand())
                {
                    command.CommandText = query;

                    if (command.Connection.State != System.Data.ConnectionState.Open)
                        command.Connection.Open();

                    using var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        results.Add(new AvailableSeatDTO
                        {
                            SeatId = reader.GetInt32(reader.GetOrdinal("seat_id")),
                            SeatRow = reader.GetString(reader.GetOrdinal("seat_row")),
                            SeatNumber = reader.GetInt32(reader.GetOrdinal("seat_number")),
                            SeatType = reader.GetString(reader.GetOrdinal("seat_type")),
                            PriceModifier = reader.GetDecimal(reader.GetOrdinal("price_modifier")),
                            RoomName = reader.GetString(reader.GetOrdinal("room_name")),
                            RoomType = reader.GetString(reader.GetOrdinal("room_type")),
                            MovieTitle = reader.GetString(reader.GetOrdinal("movie_title")),
                            CinemaName = reader.GetString(reader.GetOrdinal("cinema_name")),
                            ShowtimeId = reader.GetInt32(reader.GetOrdinal("showtime_id")),
                            StartTime = reader.GetDateTime(reader.GetOrdinal("start_time")),
                            EndTime = reader.GetDateTime(reader.GetOrdinal("end_time")),
                            StandardPrice = reader.GetDecimal(reader.GetOrdinal("standard_price")),
                            StudentPrice = reader.GetDecimal(reader.GetOrdinal("student_price")),
                            ChildPrice = reader.GetDecimal(reader.GetOrdinal("child_price")),
                            SeniorPrice = reader.GetDecimal(reader.GetOrdinal("senior_price"))
                        });
                    }
                }
            }
            catch (Exception ex)
            {

                Console.WriteLine(ex.Message);
            }

            return results;
        }
        //public List<Seat> GetAvailableSeats(int movieId, DateTime startTime)
        //{
        //    try
        //    {
        //        var availableSeats = new List<Seat>();


        //        var bookedSeatIds = _context.BookingDetails
        //            .Include(bd => bd.Showtime)
        //            .Where(bd => bd.Showtime.MovieId == movieId &&
        //                   bd.Showtime.StartTime == startTime)
        //            .Select(bd => bd.SeatId)
        //            .ToList();


        //        var showtime = _context.Showtimes
        //            .Include(s => s.Room)
        //            .FirstOrDefault(s => s.MovieId == movieId && s.StartTime == startTime);

        //        if (showtime == null)
        //            return availableSeats; 


        //        availableSeats = _context.Seats
        //            .Include(s => s.Room)
        //            .Where(s => s.RoomId == showtime.RoomId &&
        //                  !bookedSeatIds.Contains(s.SeatId))
        //            .ToList();

        //        return availableSeats;
        //    }
        //    catch (Exception)
        //    {

        //        return new List<Seat>();
        //    }
        //}
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
}
