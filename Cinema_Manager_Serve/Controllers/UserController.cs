using Cinema_Manager_Serve.Dto;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Repo.Entities;
using Repo.Service;

namespace Cinema_Manager_Serve.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly ILogger<UserController> _logger;

        public UserController(ILogger<UserController> logger)
        {
            _logger = logger;
        }

        private UserService _userService = new UserService();

        [HttpPost("Login")]
        public IActionResult Login([FromBody] UserRequest user)
        {
            User check = _userService.Login(user.email, user.password);
            if (check == null)
            {
                return BadRequest(new { message = "Email or password is incorrect" });
            }
            return Ok(check);
        }

        [HttpPost("SignUp")]
        public IActionResult SignUp([FromBody] UserSignUp user)
        {
            User newUser = new User()
            {
                Username = user.Username,
                Password = user.Password,
                Email = user.Email,
                FullName = user.FullName,
                PhoneNumber = user.PhoneNumber,
                DateOfBirth = DateOnly.FromDateTime(user.DateOfBirth),
                Address = user.Address
            };
            bool check = _userService.SignUp(newUser);
            if (!check)
            {
                return BadRequest(new { message = "Email or username is already taken" });
            }
            return Ok();
        }
        [HttpGet("GetUserById/{id}")]
        public IActionResult GetUserById(int id)
        {
            var user = _userService.GetUserById(id);
            return Ok(user);
        }
        [HttpPut("UpdateUser")]
        public IActionResult UpdateUser( [FromBody] User updatedUser)
        {
            try
            {
                var existingUser = _userService.GetUserById(updatedUser.UserId);
                if (existingUser == null)
                {
                    return NotFound(new { message = "User not found" });
                }

               
                existingUser.Username = updatedUser.Username;
                existingUser.FullName = updatedUser.FullName;
                existingUser.PhoneNumber = updatedUser.PhoneNumber;
                existingUser.DateOfBirth = updatedUser.DateOfBirth;
                existingUser.Address = updatedUser.Address;

             

                var success = _userService.UpdateUser(existingUser);
                if (!success)
                {
                    return BadRequest(new { message = "Failed to update user" });
                }

                var updatedUserData = _userService.GetUserById(updatedUser.UserId);
                return Ok(updatedUserData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user {UserId}", updatedUser.UserId);
                return StatusCode(500, new { message = "Internal server error" });
            }
        }
        [HttpPut("ChangePassword")]
        public IActionResult ChangePass([FromBody] UserChangePass user)
        {
            var existingUser = _userService.GetUserById(user.userId);
            if (existingUser == null)
            {
                return NotFound(new { message = "User not found" });
            }
            if (existingUser.Password != user.oldPassword)
            {
                return BadRequest(new { message = "Old password is incorrect" });
            }
            existingUser.Password = user.newPassword;
            var success = _userService.UpdateUser(existingUser);
            if (!success)
            {
                return BadRequest(new { message = "Failed to change password" });
            }
            return Ok();
        }




    }
}
