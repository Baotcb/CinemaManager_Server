using Repo.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repo.Service
{
    public class UserService
    {
        private CinemaManagerContext _context= new CinemaManagerContext();
        public User Login(string email, string password)
        {
            var user = _context.Users.FirstOrDefault(x => x.Email == email && x.Password == password);
           
            return user;
        }
        public bool SignUp(User user)
        {
            var check = _context.Users.FirstOrDefault(x => x.Username == user.Username || x.Email == user.Email);
        
            if (check != null)
            {
                return false;
            }
            _context.Users.Add(user);
            _context.SaveChanges();
            return true;
        }
    }
}
