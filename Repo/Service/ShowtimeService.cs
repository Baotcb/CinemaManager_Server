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
            var check = _context.Showtimes.FirstOrDefault(x => x.StartTime == showtime.StartTime);
            if (check != null)
            {
                return false;
            }
            _context.Showtimes.Add(showtime);
            _context.SaveChanges();
            return true;
        }

        public bool DeleteShowtime(int id)
        {
            var showtime = _context.Showtimes.Find(id);
            if (showtime == null)
            {
                return false;
            }
            _context.Showtimes.Remove(showtime);
            _context.SaveChanges();
            return true;
        }

        public bool UpdateShowtime(Showtime showtime)
        {
            try
            {
                var existingShowtime = _context.Showtimes.Find(showtime.ShowtimeId);
                if (existingShowtime == null)
                    return false;
                existingShowtime.MovieId = showtime.MovieId;
                existingShowtime.RoomId = showtime.RoomId;
                existingShowtime.StartTime = showtime.StartTime;
                existingShowtime.EndTime = showtime.EndTime;
                existingShowtime.BasePrice = showtime.BasePrice;
                existingShowtime.StudentPrice = showtime.StudentPrice;
                existingShowtime.ChildPrice = showtime.ChildPrice;
                existingShowtime.SeniorPrice = showtime.SeniorPrice;
                _context.SaveChanges();
                return true;
            }
            catch
            {
                return false;
            }
        }
    }

}


