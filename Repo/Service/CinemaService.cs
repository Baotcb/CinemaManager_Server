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
        public List<Cinema> GetAllCinema()
        {
            return _context.Cinemas.ToList();
        }
    }
}
