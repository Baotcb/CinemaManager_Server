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
    }
}
