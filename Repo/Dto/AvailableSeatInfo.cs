using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repo.Dto
{
    public class AvailableSeatInfo
    {
        public int RoomId { get; set; }
        public string RoomName { get; set; }
        public string CinemaName { get; set; }
        public string RoomType { get; set; }
        public int SeatId { get; set; }
        public string SeatRow { get; set; }
        public int SeatNumber { get; set; }
        public string SeatType { get; set; }
    }
}
