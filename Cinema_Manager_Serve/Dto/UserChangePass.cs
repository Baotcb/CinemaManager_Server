namespace Cinema_Manager_Serve.Dto
{
    public class UserChangePass
    {
        public int userId { get; set; }
        public string oldPassword { get; set; }
        public string newPassword { get; set; }
    }
}
