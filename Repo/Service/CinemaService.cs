using Microsoft.EntityFrameworkCore;
using Repo.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repo.Service
{
    public class CinemaService
    {
        private CinemaManagerContext _context = new CinemaManagerContext();

        public bool AddCinema(Cinema cinema)
        {

            var check = _context.Cinemas.FirstOrDefault(x => x.Name == cinema.Name || x.Email == cinema.Email);
            if (check != null)
            {
                return false;
            }
            _context.Cinemas.Add(cinema);
            _context.SaveChanges();
            return true;
        }

        public bool DeleteCinema(int id)
        {
            var cinema = _context.Cinemas.Find(id);
            if (cinema == null)
            {
                return false;
            }
            _context.Cinemas.Remove(cinema);
            _context.SaveChanges();
            return true;
        }

        public List<CinemaDto> GetAllCinema()
        {
            var cinemas = _context.Cinemas.Include(x => x.Rooms).ToList();

           
            return cinemas.Select(c => new CinemaDto
            {
                CinemaId = c.CinemaId,
                Name = c.Name,
                Address = c.Address,
                City = c.City,
                PhoneNumber = c.PhoneNumber,
                Email = c.Email,
                Description = c.Description,
                ImageUrl = c.ImageUrl,
                Rooms = c.Rooms.Select(r => new RoomDto
                {
                    CinemaId = r.CinemaId,
                    RoomId = r.RoomId,
                    RoomName = r.RoomName,
                    RoomType = r.RoomType,
                    Capacity = r.Capacity
                    
                }).ToList()
            }).ToList();
        }

        public bool UpdateCinema(Cinema cinema)
        {
            
            if (cinema == null) { return false; }
            var check = _context.Cinemas.FirstOrDefault(x => x.CinemaId == cinema.CinemaId);
            if (check == null)
            {
                return false;
            }
            check.Name = cinema.Name;
            check.Address = cinema.Address;
            check.City = cinema.City;
            check.PhoneNumber = cinema.PhoneNumber;
            check.Email = cinema.Email;
            check.Description = cinema.Description;
            _context.SaveChanges();
            return true;
        }
    }
    public class CinemaDto
    {
        public int CinemaId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? Email { get; set; }
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public List<RoomDto> Rooms { get; set; } = new List<RoomDto>();
    }

    public class RoomDto
    {
        public int RoomId { get; set; }
        public int CinemaId { get; set; }
        public string RoomName { get; set; } = string.Empty;
        public string? RoomType { get; set; }
        public int Capacity { get; set; }
        public List<SeatDto> Seats { get; set; } = new List<SeatDto>();
    }
}
