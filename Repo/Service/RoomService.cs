using Microsoft.EntityFrameworkCore;
using Repo.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repo.Service
{
    public class RoomService
    {
        private CinemaManagerContext _context = new CinemaManagerContext();
        private CinemaService _cinemaService = new CinemaService();
        public bool AddRoom(Room room)
        {

            var check = _context.Rooms.FirstOrDefault(x => x.RoomName == room.RoomName);
            if (check != null)
            {
                return false;
            }
            _context.Rooms.Add(room);
            _context.SaveChanges();
            return true;

        }
        public bool DeleteRoom(int roomId)
        {
            var room = _context.Rooms.Find(roomId);
            if (room == null)
            {
                return false;
            }
            _context.Rooms.Remove(room);
            _context.SaveChanges();
            return true;
        }

        public List<CinemaDto> GetAllRoom()
        {
            var cinemas = _context.Cinemas
                .Include(x => x.Rooms)
                    .ThenInclude(r => r.Seats)
                .ToList();

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
                    Capacity = r.Capacity,
                    Seats = r.Seats.Select(s => new SeatDto
                    {
                        SeatId = s.SeatId,
                        RoomId = s.RoomId,
                        SeatRow = s.SeatRow,
                        SeatNumber = s.SeatNumber,
                        SeatType = s.SeatType,
                        PriceModifier = s.PriceModifier
                    }).ToList()
                }).ToList()
            }).ToList();
        }

        public bool UpdateRoom(Room room)
        {
            try
            {
                var existingRoom = _context.Rooms.Find(room.RoomId);
                if (existingRoom == null)
                    return false;
                existingRoom.RoomName = room.RoomName;
                existingRoom.Capacity = room.Capacity;
                existingRoom.RoomType = room.RoomType;
                existingRoom.UpdatedAt = DateTime.UtcNow;
                _context.SaveChanges();
                return true;
            }
            catch
            {
                return false;
            }
        }

    }
    public class SeatDto
    {
        public int SeatId { get; set; }
        public int RoomId { get; set; }
        public string SeatRow { get; set; } = string.Empty;
        public int SeatNumber { get; set; }
        public string SeatType { get; set; } = string.Empty;
        public decimal? PriceModifier { get; set; }
    }
}
