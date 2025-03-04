using System.ComponentModel.DataAnnotations;

namespace Cinema_Manager_Serve.Dto
{
    public class UserSignUp
    {
        [Required]
        public string Username { get; set; }

        [Required]
        public string Password { get; set; }

        [Required]
        [EmailAddress]
        public string Email { get; set; }

        [Required]
        public string FullName { get; set; }

        [Phone]
        public string PhoneNumber { get; set; }

        [DataType(DataType.Date)]
        public DateTime DateOfBirth { get; set; }

        public string Address { get; set; }

        [Required]
        public bool TermsAccepted { get; set; }
    }
}
