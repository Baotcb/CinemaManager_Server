using Microsoft.AspNetCore.SignalR;
using Repo.Entities;
using Repo.Service;

namespace Cinema_Manager_Serve
{
    public class AdminHub : Hub
    {
        private MovieService _movieService = new MovieService();
        private CinemaService _cinemaService = new CinemaService();
        private UserService userService = new UserService();
        private RoomService roomService = new RoomService();
        private ShowtimeService showtimeService = new ShowtimeService();


        public async Task GetMovies()
        {
            var movies = _movieService.GetAllMovies();
            await Clients.All.SendAsync("GetMovies", movies);
        }
        public async Task GetCinemas()
        {
            // get room and cinema
            var cinemas = _cinemaService.GetAllCinema();
            await Clients.All.SendAsync("GetCinemas", cinemas);
        }
        public async Task GetUser()
        {
            var users = userService.GetAllUser();
            await Clients.All.SendAsync("GetUser", users);
        }
        public async Task GetRooms()
        {
            var rooms = roomService.GetAllRoom();
            await Clients.All.SendAsync("GetRooms", rooms);
        }
        public async Task GetShowtimes()
        {
            var showtimes = showtimeService.GetAllShowTime();
            await Clients.All.SendAsync("GetShowtimes", showtimes);
        }


        // CRUD Opratior
        // movie
        public async Task AddMovie(Movie movie)
        {
            var result = _movieService.AddMovie(movie);
            await Clients.All.SendAsync("AddMovie", result);
        }
        public async Task UpdateMovie(Movie movie)
        {
            var result = _movieService.UpdateMovie(movie);
            await Clients.All.SendAsync("UpdateMovie", result);
        }
        public async Task DeleteMovie(int id)
        {
            var result = _movieService.DeleteMovie(id);
            await Clients.All.SendAsync("DeleteMovie", result);
        }
        // cinema
        public async Task AddCinema(Cinema cinema)
        {
            var result = _cinemaService.AddCinema(cinema);
            await Clients.All.SendAsync("AddCinema", result);
        }
        public async Task DeleteCinema(int id)
        {
            var result = _cinemaService.DeleteCinema(id);
            await Clients.All.SendAsync("DeleteCinema", result);
        }
        public async Task UpdateCinema(Cinema cinema)
        {
            var result = _cinemaService.UpdateCinema(cinema);
            await Clients.All.SendAsync("UpdateCinema", result);
        }
        //room
        public async Task AddRoom(Room room)
        {
            var result = roomService.AddRoom(room);
            await Clients.All.SendAsync("AddRoom", result);
        }
        public async Task DeleteRoom(int id)
        {
            var result = roomService.DeleteRoom(id);
            await Clients.All.SendAsync("DeleteRoom", result);
        }
        public async Task UpdateRoom(Room room)
        {
            var result = roomService.UpdateRoom(room);
            await Clients.All.SendAsync("UpdateRoom", result);
        }
        // showtime
        public async Task AddShowtime(Showtime showtime)
        {
            var result = showtimeService.AddShowtime(showtime);
            await Clients.All.SendAsync("AddShowtime", result);
        }
        public async Task DeleteShowtime(int id)
        {
            var result = showtimeService.DeleteShowtime(id);
            await Clients.All.SendAsync("DeleteShowtime", result);
        }
        public async Task UpdateShowtime(Showtime showtime)
        {
            var result = showtimeService.UpdateShowtime(showtime);
            await Clients.All.SendAsync("UpdateShowtime", result);
        }

    }
}
