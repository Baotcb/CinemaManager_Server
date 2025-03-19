using Microsoft.EntityFrameworkCore;
using Repo.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repo.Service
{
    public class ShowtimeService
    {
        private CinemaManagerContext _context = new CinemaManagerContext();
        public List<Showtime> GetAllShowTime()
        {
            return _context.Showtimes.ToList();
        }
        public bool AddShowtime(Showtime showtime)
        {
            try
            {
               
                if (showtime == null || showtime.StartTime >= showtime.EndTime)
                {
                    return false;
                }

              
                var exactMatch = _context.Showtimes
                    .FirstOrDefault(x => x.StartTime == showtime.StartTime && x.RoomId == showtime.RoomId);

                if (exactMatch != null)
                {
                    return false;
                }

                
                var roomConflicts = _context.Showtimes
                    .Where(x => x.RoomId == showtime.RoomId &&
                           ((showtime.StartTime >= x.StartTime && showtime.StartTime < x.EndTime) ||     
                            (showtime.EndTime > x.StartTime && showtime.EndTime <= x.EndTime) ||       
                            (showtime.StartTime <= x.StartTime && showtime.EndTime >= x.EndTime)))       
                    .ToList();

                if (roomConflicts.Any())
                {
                    return false;
                }

              
                int bufferMinutes = 30;
                var adjacentShowtimes = _context.Showtimes
                    .Where(x => x.RoomId == showtime.RoomId &&
                           ((x.EndTime <= showtime.StartTime && showtime.StartTime.Subtract(x.EndTime).TotalMinutes < bufferMinutes) ||  
                            (x.StartTime >= showtime.EndTime && x.StartTime.Subtract(showtime.EndTime).TotalMinutes < bufferMinutes)))    
                    .ToList();

                if (adjacentShowtimes.Any())
                {
                    return false;
                }

               
                if (showtime.EndTime == DateTime.MinValue && showtime.MovieId > 0)
                {
                    var movie = _context.Movies.Find(showtime.MovieId);
                    if (movie != null)
                    {
                        showtime.EndTime = showtime.StartTime.AddMinutes(movie.Duration);
                    }
                }

               
                if (showtime.StudentPrice == null)
                    showtime.StudentPrice = showtime.BasePrice * 0.8m; 

                if (showtime.ChildPrice == null)
                    showtime.ChildPrice = showtime.BasePrice * 0.5m; 

                if (showtime.SeniorPrice == null)
                    showtime.SeniorPrice = showtime.BasePrice * 0.7m; 

                showtime.CreatedAt = DateTime.Now;
                showtime.UpdatedAt = DateTime.Now;

                _context.Showtimes.Add(showtime);
                _context.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {
               
                Console.WriteLine($"Error adding showtime: {ex.Message}");
                return false;
            }
        }


        public bool DeleteShowtime(int id)
        {
            try
            {
                var showtime = _context.Showtimes
                    .Include(s => s.BookingDetails)
                    .FirstOrDefault(s => s.ShowtimeId == id);

                if (showtime == null)
                {
                    return false;
                }

                
                if (showtime.BookingDetails != null && showtime.BookingDetails.Any())
                {
                    bool hasActiveBookings = showtime.BookingDetails.Any(bd =>
                        bd.Booking != null && bd.Booking.BookingStatus != "Cancelled");

                    if (hasActiveBookings)
                    {
                        Console.WriteLine($"Cannot delete showtime {id} as it has active bookings");
                        return false;
                    }
                }

             
                if (showtime.StartTime <= DateTime.Now.AddHours(24))
                {
                    Console.WriteLine($"Cannot delete showtime {id} as it starts within 24 hours");
                    return false;
                }

                _context.Showtimes.Remove(showtime);
                _context.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting showtime: {ex.Message}");
                return false;
            }
        }

        public bool UpdateShowtime(Showtime showtime)
        {
            try
            {
               
                var existingShowtime = _context.Showtimes
                    .Include(s => s.BookingDetails)
                    .ThenInclude(bd => bd.Booking)
                    .FirstOrDefault(s => s.ShowtimeId == showtime.ShowtimeId);

                if (existingShowtime == null)
                    return false;

               
                if (existingShowtime.BookingDetails != null && existingShowtime.BookingDetails.Any())
                {
                    
                    bool hasActiveBookings = existingShowtime.BookingDetails.Any(bd =>
                        bd.Booking != null && bd.Booking.BookingStatus != "Cancelled");

                    if (hasActiveBookings)
                    {
                      
                        existingShowtime.BasePrice = showtime.BasePrice;
                        existingShowtime.StudentPrice = showtime.StudentPrice;
                        existingShowtime.ChildPrice = showtime.ChildPrice;
                        existingShowtime.SeniorPrice = showtime.SeniorPrice;
                        existingShowtime.UpdatedAt = DateTime.Now;

                        _context.SaveChanges();
                        return true;
                    }
                }

            
                if (existingShowtime.StartTime <= DateTime.Now.AddHours(24))
                {
                    existingShowtime.BasePrice = showtime.BasePrice;
                    existingShowtime.StudentPrice = showtime.StudentPrice;
                    existingShowtime.ChildPrice = showtime.ChildPrice;
                    existingShowtime.SeniorPrice = showtime.SeniorPrice;
                    existingShowtime.UpdatedAt = DateTime.Now;

                    _context.SaveChanges();
                    return true;
                }

               
                if (existingShowtime.RoomId != showtime.RoomId ||
                    existingShowtime.StartTime != showtime.StartTime ||
                    existingShowtime.EndTime != showtime.EndTime)
                {
                   
                    var roomConflicts = _context.Showtimes
                        .Where(x => x.ShowtimeId != showtime.ShowtimeId && 
                                   x.RoomId == showtime.RoomId &&
                                   ((showtime.StartTime >= x.StartTime && showtime.StartTime < x.EndTime) ||
                                    (showtime.EndTime > x.StartTime && showtime.EndTime <= x.EndTime) ||
                                    (showtime.StartTime <= x.StartTime && showtime.EndTime >= x.EndTime)))
                        .ToList();

                    if (roomConflicts.Any())
                    {
                        return false;
                    }

                    int bufferMinutes = 30;
                    var adjacentShowtimes = _context.Showtimes
                        .Where(x => x.ShowtimeId != showtime.ShowtimeId && 
                                   x.RoomId == showtime.RoomId &&
                                   ((x.EndTime <= showtime.StartTime && showtime.StartTime.Subtract(x.EndTime).TotalMinutes < bufferMinutes) ||
                                    (x.StartTime >= showtime.EndTime && x.StartTime.Subtract(showtime.EndTime).TotalMinutes < bufferMinutes)))
                        .ToList();

                    if (adjacentShowtimes.Any())
                    {
                        return false;
                    }
                }

                if (existingShowtime.MovieId != showtime.MovieId)
                {
                    var movie = _context.Movies.Find(showtime.MovieId);
                    if (movie != null)
                    {
                        showtime.EndTime = showtime.StartTime.AddMinutes(movie.Duration);
                    }
                }

             
                existingShowtime.MovieId = showtime.MovieId;
                existingShowtime.RoomId = showtime.RoomId;
                existingShowtime.StartTime = showtime.StartTime;
                existingShowtime.EndTime = showtime.EndTime;
                existingShowtime.BasePrice = showtime.BasePrice;
                existingShowtime.StudentPrice = showtime.StudentPrice;
                existingShowtime.ChildPrice = showtime.ChildPrice;
                existingShowtime.SeniorPrice = showtime.SeniorPrice;
                existingShowtime.UpdatedAt = DateTime.Now;

                _context.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating showtime: {ex.Message}");
                return false;
            }
        }


    }

}


