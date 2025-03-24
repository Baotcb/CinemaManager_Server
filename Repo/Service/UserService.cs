using BCrypt.Net; 
using Repo.Entities;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Repo.Service
{
    public class UserService
    {
        private readonly CinemaManagerContext _context = new CinemaManagerContext();

        public void MigrateExistingPasswords()
        {
            var users = _context.Users.ToList();

            foreach (var user in users)
            {
               
                if (!IsPasswordHashed(user.Password))
                {
                    
                    user.Password = HashPassword(user.Password);
                    user.UpdatedAt = DateTime.UtcNow;
                }
            }

            _context.SaveChanges();
        }

        private bool IsPasswordHashed(string password)
        {
       
            return password.StartsWith("$2a$") || password.StartsWith("$2b$") || password.StartsWith("$2y$");
        }
        public bool CheckPassword(int userId, string password)
        {
           
            var user = _context.Users.Find(userId);

            
            if (user == null)
                return false;

           
            return BCrypt.Net.BCrypt.Verify(password, user.Password);
        }





        public User Login(string email, string password)
        {

            MigrateExistingPasswords();
            var user = _context.Users.FirstOrDefault(x => x.Email == email);


            if (user == null || !BCrypt.Net.BCrypt.Verify(password, user.Password))
                return null;

            return user;
        }

        public bool SignUp(User user)
        {
            var check = _context.Users.FirstOrDefault(x => x.Username == user.Username || x.Email == user.Email);

            if (check != null)
            {
                return false;
            }

           
            user.Password = HashPassword(user.Password);

          
            user.CreatedAt = DateTime.UtcNow;
            user.UpdatedAt = DateTime.UtcNow;

            _context.Users.Add(user);
            _context.SaveChanges();
            return true;
        }

       
        private string HashPassword(string password)
        {
            
            return BCrypt.Net.BCrypt.HashPassword(password, workFactor: 12);
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

       
        public bool ChangePass(int userId, string currentPassword, string newPassword)
        {
            try
            {
                var existingUser = _context.Users.Find(userId);
                if (existingUser == null)
                    return false;

               
                if (!BCrypt.Net.BCrypt.Verify(currentPassword, existingUser.Password))
                    return false;

              
                existingUser.Password = HashPassword(newPassword);
                existingUser.UpdatedAt = DateTime.UtcNow;

                _context.SaveChanges();
                return true;
            }
            catch
            {
                return false;
            }
        }

        
        public bool ResetPassword(int userId, string newPassword)
        {
            try
            {
                var existingUser = _context.Users.Find(userId);
                if (existingUser == null)
                    return false;

                existingUser.Password = HashPassword(newPassword);
                existingUser.UpdatedAt = DateTime.UtcNow;

                _context.SaveChanges();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public List<User> GetAllUser()
        {
            return _context.Users.ToList();
        }
    }
}
