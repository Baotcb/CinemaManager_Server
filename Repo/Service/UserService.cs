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
        public User GetUserById(int id)
        {
            return _context.Users.FirstOrDefault(x => x.UserId == id);
        }

        public bool UpdateUser(User user)
        {
            try
            {
                var existingUser = _context.Users.Find(user.UserId);
                if (existingUser == null)
                    return false;

                
                existingUser.Username = user.Username;
                existingUser.FullName = user.FullName;
                existingUser.PhoneNumber = user.PhoneNumber;
                existingUser.DateOfBirth = user.DateOfBirth;
                existingUser.Address = user.Address;
                existingUser.UpdatedAt = DateTime.UtcNow;

                _context.SaveChanges();
                return true;
            }
            catch
            {
                return false;
            }
        }
        public bool ChangePass(User user)
        {
            try
            {
                var existingUser = _context.Users.Find(user.UserId);
                if (existingUser == null)
                    return false;
                existingUser.Password = user.Password;
                existingUser.UpdatedAt = DateTime.UtcNow;
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
