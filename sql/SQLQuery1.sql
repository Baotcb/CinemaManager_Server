use master;
drop database if exists Cinema_Manager ;
create database Cinema_Manager;
use Cinema_Manager;

GO
drop table if exists Users;
drop table if exists Movies;
drop table if exists Cinemas;
drop table if exists Rooms;
drop table if exists Seats;
drop table if exists Showtimes;
drop table if exists Bookings;
drop table if exists Booking_Details;

go
-- Bảng Users (Người dùng)
CREATE TABLE Users (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    username NVARCHAR(50) NOT NULL UNIQUE,
    password NVARCHAR(255) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    full_name NVARCHAR(100) NOT NULL,
    phone_number NVARCHAR(15),
    date_of_birth DATE,
    address NVARCHAR(MAX),
    is_admin BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
go
-- Bảng Movies (Phim)
CREATE TABLE Movies (
    movie_id INT PRIMARY KEY IDENTITY(1,1),
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    duration INT NOT NULL, -- Thời lượng phim (phút)
    release_date DATE,
    end_date DATE,
    genre NVARCHAR(100),
    director NVARCHAR(100),
    cast NVARCHAR(MAX),
    poster_url NVARCHAR(255),
    trailer_url NVARCHAR(255),
    language NVARCHAR(50),
    subtitle NVARCHAR(50),
    rating DECIMAL(3,1), -- Đánh giá phim (ví dụ: 8.5/10)
    age_restriction NVARCHAR(10), -- Giới hạn độ tuổi (P, C13, C16, C18)
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
go
-- Bảng Cinemas (Rạp phim)
CREATE TABLE Cinemas (
    cinema_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    address NVARCHAR(MAX) NOT NULL,
    city NVARCHAR(50) NOT NULL,
    phone_number NVARCHAR(15),
    email NVARCHAR(100),
    description NVARCHAR(MAX),
    image_url NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
go
-- Bảng Rooms (Phòng chiếu)
CREATE TABLE Rooms (
    room_id INT PRIMARY KEY IDENTITY(1,1),
    cinema_id INT NOT NULL,
    room_name NVARCHAR(50) NOT NULL,
    capacity INT NOT NULL, -- Sức chứa
    room_type NVARCHAR(50), -- Loại phòng (2D, 3D, IMAX, 4DX)
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Rooms_Cinemas FOREIGN KEY (cinema_id) REFERENCES Cinemas(cinema_id) ON DELETE CASCADE
);
go
-- Bảng Seats (Ghế ngồi)
CREATE TABLE Seats (
    seat_id INT PRIMARY KEY IDENTITY(1,1),
    room_id INT NOT NULL,
    seat_row NVARCHAR(5) NOT NULL, -- Hàng (A, B, C,...)
    seat_number INT NOT NULL, -- Số ghế (1, 2, 3,...)
    seat_type NVARCHAR(20) NOT NULL, -- Loại ghế (Standard, VIP, Couple)
    price_modifier DECIMAL(3,2) DEFAULT 1.00, -- Hệ số giá cho từng loại ghế (VIP = 1.3, Couple = 1.5, Standard = 1.0)
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Seats_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE,
    CONSTRAINT UQ_Seat_Room UNIQUE (room_id, seat_row, seat_number) -- Mỗi ghế trong phòng phải là duy nhất
);
go
-- Bảng Showtimes (Lịch chiếu) - Với giá đã đơn giản hóa
CREATE TABLE Showtimes (
    showtime_id INT PRIMARY KEY IDENTITY(1,1),
    movie_id INT NOT NULL,
    room_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    base_price MONEY NOT NULL, -- Giá vé cơ bản
    student_price MONEY, -- Giá vé học sinh-sinh viên (nếu có)
    child_price MONEY,   -- Giá vé trẻ em (nếu có)
    senior_price MONEY,  -- Giá vé người cao tuổi (nếu có)
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Showtimes_Movies FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    CONSTRAINT FK_Showtimes_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE
);
go
-- Bảng Bookings (Đặt vé) - Kết hợp với thông tin thanh toán
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    booking_date DATETIME DEFAULT GETDATE(),
    total_amount MONEY NOT NULL,
    discount_amount MONEY DEFAULT 0, -- Số tiền giảm giá (nếu có)
    discount_code NVARCHAR(20),      -- Mã giảm giá (nếu có)
    additional_purchases MONEY DEFAULT 0, -- Chi phí mua thêm đồ ăn, nước uống
    payment_method NVARCHAR(50),
    transaction_id NVARCHAR(100),
    payment_status NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Trạng thái thanh toán (Pending, Completed, Failed, Refunded)
    booking_status NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Trạng thái đặt vé (Pending, Confirmed, Cancelled)
    payment_date DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Bookings_Users FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
go
-- Bảng Booking_Details (Chi tiết đặt vé)
CREATE TABLE Booking_Details (
    booking_detail_id INT PRIMARY KEY IDENTITY(1,1),
    booking_id INT NOT NULL,
    showtime_id INT NOT NULL,
    seat_id INT NOT NULL,
    price MONEY NOT NULL,
    ticket_type NVARCHAR(20) DEFAULT 'Standard', -- Loại vé (Standard, Student, Child, Senior)
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_BookingDetails_Bookings FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_BookingDetails_Showtimes FOREIGN KEY (showtime_id) REFERENCES Showtimes(showtime_id),
    CONSTRAINT FK_BookingDetails_Seats FOREIGN KEY (seat_id) REFERENCES Seats(seat_id),
    CONSTRAINT UQ_Showtime_Seat UNIQUE (showtime_id, seat_id) -- Mỗi ghế chỉ có thể được đặt một lần cho mỗi suất chiếu
);
go

-- INSERT data for Users table
INSERT INTO Users (username, password, email, full_name, phone_number, date_of_birth, address, is_admin)
VALUES
  ('admin', 'hashed_admin_pw', 'admin@cinemamanager.com', 'Administrator', '0901234567', '1990-01-01', '123 Admin St, District 1, HCMC', 1),
  ('manager', 'hashed_manager_pw', 'manager@cinemamanager.com', 'Cinema Manager', '0902345678', '1988-05-12', '456 Manager Ave, District 2, HCMC', 1),
  ('john_doe', 'hashed_password1', 'john.doe@email.com', 'John Doe', '0912345678', '1992-03-15', '789 Customer Rd, District 3, HCMC', 0),
  ('jane_smith', 'hashed_password2', 'jane.smith@email.com', 'Jane Smith', '0923456789', '1995-07-22', '101 User Blvd, District 4, HCMC', 0),
  ('robert_johnson', 'hashed_password3', 'robert.johnson@email.com', 'Robert Johnson', '0934567890', '1988-11-30', '202 Movie St, District 5, HCMC', 0),
  ('mary_williams', 'hashed_password4', 'mary.williams@email.com', 'Mary Williams', '0945678901', '1998-02-17', '303 Cinema Ave, District 6, HCMC', 0),
  ('david_brown', 'hashed_password5', 'david.brown@email.com', 'David Brown', '0956789012', '1991-09-08', '404 Film Road, District 7, HCMC', 0);
go
-- INSERT data for Movies table
INSERT INTO Movies (title, description, duration, release_date, end_date, genre, director, cast, poster_url, trailer_url, language, subtitle, rating, age_restriction)
VALUES
  -- Currently Showing Movies (Current date: March 2025)
  ('Dune: Part Three', 'The epic conclusion of Paul Atreides journey as he unites with Chani and the Fremen to bring peace to the desert planet of Arrakis.', 165, '2025-02-10', '2025-03-31', 'Sci-Fi, Adventure, Drama', 'Denis Villeneuve', 'Timothée Chalamet, Zendaya, Rebecca Ferguson', '/posters/dune3.jpg', '/trailers/dune3.mp4', 'English', 'Vietnamese', 9.1, 'C13'),
  
  ('Avengers: Secret Wars', 'The Avengers must navigate the multiverse to stop a reality-threatening force that could end everything they know.', 182, '2025-02-20', '2025-04-10', 'Action, Adventure, Sci-Fi', 'Russo Brothers', 'Robert Downey Jr., Chris Evans, Mark Ruffalo, Scarlett Johansson', '/posters/avengers_secret_wars.jpg', '/trailers/avengers_secret_wars.mp4', 'English', 'Vietnamese', 8.8, 'C13'),
  
  ('The Last Samurai: Legacy', 'A modern descendant of Nathan Algren discovers his ancestors journal and travels to Japan to explore his heritage.', 155, '2025-02-15', '2025-03-20', 'Action, Drama, History', 'James Mangold', 'Ken Watanabe, Christian Bale, Zhang Ziyi', '/posters/last_samurai_legacy.jpg', '/trailers/last_samurai_legacy.mp4', 'English, Japanese', 'Vietnamese, English', 8.2, 'C16'),
  
  ('Seoul Stories', 'Four interconnected stories of love, loss, and redemption set against the backdrop of modern Seoul.', 128, '2025-02-01', '2025-03-15', 'Drama, Romance', 'Park Chan-wook', 'Lee Min-ho, Kim Go-eun, Gong Yoo, Bae Doona', '/posters/seoul_stories.jpg', '/trailers/seoul_stories.mp4', 'Korean', 'Vietnamese, English', 8.7, 'C16'),
  
  ('Fast & Furious: Final Ride', 'Dom Toretto and his family face their ultimate challenge as past enemies unite against them.', 145, '2025-01-30', '2025-03-25', 'Action, Crime, Thriller', 'Justin Lin', 'Vin Diesel, Michelle Rodriguez, Tyrese Gibson', '/posters/ff_final.jpg', '/trailers/ff_final.mp4', 'English', 'Vietnamese', 7.6, 'C13'),
  
  -- Upcoming Movies
  ('Jurassic World: New Era', 'Twenty years after the fall of Jurassic World, dinosaurs have integrated into ecosystems worldwide, creating a new era of human-dinosaur coexistence.', 152, '2025-03-20', '2025-05-20', 'Action, Adventure, Sci-Fi', 'Colin Trevorrow', 'Chris Pratt, Bryce Dallas Howard, Sam Neill', '/posters/jurassic_new_era.jpg', '/trailers/jurassic_new_era.mp4', 'English', 'Vietnamese', 0.0, 'C13');
go
-- INSERT data for Cinemas table
INSERT INTO Cinemas (name, address, city, phone_number, email, description, image_url)
VALUES
  ('CGV Landmark 81', '208 Binh Thanh District', 'Ho Chi Minh City', '028-1234-5678', 'landmark81@cgv.vn', 'Luxury cinema located in the iconic Landmark 81 skyscraper', '/images/cgv_landmark81.jpg'),
  ('Galaxy Nguyen Du', '116 Nguyen Du, District 1', 'Ho Chi Minh City', '028-2345-6789', 'nguyendu@galaxy.vn', 'Modern cinema complex in the heart of District 1', '/images/galaxy_nguyendu.jpg'),
  ('BHD Star Vincom Center', '72 Le Thanh Ton, District 1', 'Ho Chi Minh City', '028-3456-7890', 'vincom@bhd.vn', 'Premium cinema experience in Vincom Center', '/images/bhd_vincom.jpg');
go
-- INSERT data for Rooms table
INSERT INTO Rooms (cinema_id, room_name, capacity, room_type)
VALUES
  (1, 'Screen 1', 150, 'IMAX'),
  (1, 'Screen 2', 120, '4DX'),
  (1, 'Screen 3', 100, '3D'),
  (1, 'Screen 4', 80, '2D'),
  (2, 'Hall A', 130, '3D'),
  (2, 'Hall B', 110, '2D'),
  (3, 'Premier 1', 100, 'SCREENX'),
  (3, 'Premier 2', 100, '3D');
go

  go
  -- Insert complete seats for Room 1 (IMAX, capacity 150)
-- VIP rows (A-B, 15 seats per row)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 1, 'A', number, 'VIP', 1.30
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number FROM master.dbo.spt_values WHERE type = 'P' AND number <= 15) AS nums;

INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 1, 'B', number, 'VIP', 1.30
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number FROM master.dbo.spt_values WHERE type = 'P' AND number <= 15) AS nums;

-- Standard rows (C-H, 15 seats per row)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 1, char(ASCII('C') + row_num), col_num, 'Standard', 1.00
FROM 
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS row_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 6) AS rows
CROSS JOIN
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS col_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 15) AS cols;

-- Couple seats (I-J, 7 double-seats per row)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 1, 'I', number*2-1, 'Couple', 1.50
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number 
      FROM master.dbo.spt_values WHERE type = 'P' AND number <= 7) AS nums
WHERE NOT EXISTS (
    SELECT 1 FROM Seats 
    WHERE room_id = 1 AND seat_row = 'I' AND seat_number = (number*2-1)
);
go
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 1, 'J', number*2-1, 'Couple', 1.50
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number FROM master.dbo.spt_values WHERE type = 'P' AND number <= 7) AS nums;
go
-- Insert seats for Room 2 (4DX)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 2, char(64 + row_num), col_num, 'Standard', 1.00
FROM 
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 8) AS rows
CROSS JOIN
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS col_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 15) AS cols;
go
-- Insert seats for Room 4 (2D)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 4, char(64 + row_num), col_num, 'Standard', 1.00
FROM 
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 8) AS rows
CROSS JOIN
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS col_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 10) AS cols;
go
-- Insert seats for Room 5 (Hall A at Galaxy Nguyen Du)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 5, char(64 + row_num), col_num, 'Standard', 1.00
FROM 
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 10) AS rows
CROSS JOIN
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS col_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 13) AS cols;
GO
-- Add a few VIP seats in the front row
UPDATE Seats 
SET seat_type = 'VIP', price_modifier = 1.30
WHERE room_id = 5 AND seat_row = 'A' AND seat_number BETWEEN 4 AND 10;
GO
-- Insert seats for Room 6 (Hall B at Galaxy Nguyen Du)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 6, char(64 + row_num), col_num, 'Standard', 1.00
FROM 
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 10) AS rows
CROSS JOIN
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS col_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 11) AS cols;
GO

-- Add some VIP seats in the center
UPDATE Seats 
SET seat_type = 'VIP', price_modifier = 1.30
WHERE room_id = 6 AND seat_row IN ('C','D') AND seat_number BETWEEN 4 AND 8;
GO
-- Insert seats for Room 7 (Premier 1 - SCREENX at BHD Star Vincom Center)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type, price_modifier)
SELECT 7, char(64 + row_num), col_num, 'Standard', 1.00
FROM 
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 10) AS rows
CROSS JOIN
    (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS col_num 
     FROM master.dbo.spt_values WHERE type = 'P' AND number <= 10) AS cols;
GO

-- Add premium seats in center rows
UPDATE Seats 
SET seat_type = 'VIP', price_modifier = 1.30
WHERE room_id = 7 AND seat_row IN ('D','E') AND seat_number BETWEEN 3 AND 7;
GO
-- INSERT data for Showtimes table
INSERT INTO Showtimes (movie_id, room_id, start_time, end_time, base_price, student_price, child_price, senior_price)
VALUES
  -- Dune: Part Three (ID 1)
  (1, 1, '2025-03-10 10:00:00', '2025-03-10 12:45:00', 150000, 120000, 90000, 112500), -- Morning IMAX
  (1, 1, '2025-03-10 19:00:00', '2025-03-10 21:45:00', 200000, 160000, 120000, 150000), -- Evening IMAX
  (1, 3, '2025-03-10 16:30:00', '2025-03-10 19:15:00', 150000, 120000, 90000, 112500), -- Evening 3D
  
  -- Avengers: Secret Wars (ID 2)
  (2, 2, '2025-03-10 15:00:00', '2025-03-10 18:02:00', 200000, 160000, 120000, 150000), -- Afternoon 4DX
  (2, 2, '2025-03-10 20:00:00', '2025-03-10 23:02:00', 220000, 176000, 132000, 165000), -- Evening 4DX
  (2, 4, '2025-03-10 10:30:00', '2025-03-10 13:32:00', 100000, 80000, 60000, 75000),    -- Morning 2D
  
  -- The Last Samurai: Legacy (ID 3)
  (3, 5, '2025-03-10 11:30:00', '2025-03-10 14:05:00', 100000, 80000, 60000, 75000),
  (3, 5, '2025-03-10 18:00:00', '2025-03-10 20:35:00', 120000, 96000, 72000, 90000),
  
  -- Seoul Stories (ID 4)
  (4, 6, '2025-03-10 12:00:00', '2025-03-10 14:08:00', 120000, 96000, 72000, 90000),
  
  -- Fast & Furious: Final Ride (ID 5)
  (5, 7, '2025-03-10 15:45:00', '2025-03-10 18:10:00', 120000, 96000, 72000, 90000),
  
  -- Upcoming: Jurassic World: New Era (ID 6)
  (6, 1, '2025-03-20 15:30:00', '2025-03-20 18:02:00', 200000, 160000, 120000, 150000);
go
-- INSERT data for Bookings table
INSERT INTO Bookings (user_id, booking_date, total_amount, discount_amount, discount_code, additional_purchases, payment_method, transaction_id, payment_status, booking_status, payment_date)
VALUES
  (3, '2025-03-08 14:23:15', 435000, 0, NULL, 85000, 'Credit Card', 'TXN123456789', 'Completed', 'Confirmed', '2025-03-08 14:25:32'),
  (4, '2025-03-08 10:45:22', 327000, 20000, 'WELCOME25', 0, 'E-Wallet', 'EWALLET98765432', 'Completed', 'Confirmed', '2025-03-08 10:47:15'),
  (5, '2025-03-09 18:12:37', 580000, 50000, 'MARCH10', 150000, 'Credit Card', 'TXN234567890', 'Completed', 'Confirmed', '2025-03-09 18:14:23'),
  (6, '2025-03-09 20:34:19', 198000, 0, NULL, 65000, 'Debit Card', 'DC345678901', 'Completed', 'Confirmed', '2025-03-09 20:36:42');
go
-- INSERT data for Booking_Details table
INSERT INTO Booking_Details (booking_id, showtime_id, seat_id, price, ticket_type)
VALUES
  -- Booking 1: Two VIP seats for Dune IMAX evening
  (1, 2, 1, 200000 * 1.3, 'Standard'), -- Seat A1 (VIP)
  (1, 2, 2, 200000 * 1.3, 'Standard'), -- Seat A2 (VIP)
  
  -- Booking 2: Two standard seats for Avengers 4DX evening with student discount
  (2, 5, 11, 176000, 'Student'), -- Seat B1
  (2, 5, 12, 176000, 'Student'), -- Seat B2
  
  -- Booking 3: Two VIP seats for Dune IMAX morning
  (3, 1, 6, 150000 * 1.3, 'Standard'), -- Seat B1 (VIP)
  (3, 1, 7, 150000 * 1.3, 'Standard'), -- Seat B2 (VIP)
  
  -- Booking 4: One standard and one child ticket for Last Samurai
  (4, 8, 21, 120000, 'Standard'), -- First available seat in room 5
  (4, 8, 22, 72000, 'Child');     -- Child price
GO

CREATE PROCEDURE GetAvailableSeats
    @movieId INT,
    @cinemaName NVARCHAR(100),
    @showDate DATE,
    @startTimeBegin TIME,
    @startTimeEnd TIME = NULL -- Optional parameter, if not specified will search all times after @startTimeBegin
AS
BEGIN
    -- If end time not specified, set to end of day
    IF @startTimeEnd IS NULL
        SET @startTimeEnd = '23:59:59';

    SELECT 
        s.seat_id,
        s.seat_row,
        s.seat_number,
        s.seat_type,
        s.price_modifier,
        r.room_name,
        r.room_type,
        m.title AS movie_title,
        c.name AS cinema_name,
        st.showtime_id,
        st.start_time,
        st.end_time,
        CASE 
            WHEN s.seat_type = 'Standard' THEN st.base_price * s.price_modifier
            WHEN s.seat_type = 'VIP' THEN st.base_price * s.price_modifier
            WHEN s.seat_type = 'Couple' THEN st.base_price * s.price_modifier
        END AS standard_price,
        CASE 
            WHEN s.seat_type = 'Standard' THEN st.student_price * s.price_modifier
            WHEN s.seat_type = 'VIP' THEN st.student_price * s.price_modifier
            WHEN s.seat_type = 'Couple' THEN st.student_price * s.price_modifier
        END AS student_price,
        CASE 
            WHEN s.seat_type = 'Standard' THEN st.child_price * s.price_modifier
            WHEN s.seat_type = 'VIP' THEN st.child_price * s.price_modifier
            WHEN s.seat_type = 'Couple' THEN st.child_price * s.price_modifier
        END AS child_price,
        CASE 
            WHEN s.seat_type = 'Standard' THEN st.senior_price * s.price_modifier
            WHEN s.seat_type = 'VIP' THEN st.senior_price * s.price_modifier
            WHEN s.seat_type = 'Couple' THEN st.senior_price * s.price_modifier
        END AS senior_price
    FROM 
        Seats s
    JOIN 
        Rooms r ON s.room_id = r.room_id
    JOIN 
        Cinemas c ON r.cinema_id = c.cinema_id
    JOIN 
        Showtimes st ON r.room_id = st.room_id
    JOIN 
        Movies m ON st.movie_id = m.movie_id
    LEFT JOIN 
        Booking_Details bd ON s.seat_id = bd.seat_id AND st.showtime_id = bd.showtime_id
    LEFT JOIN
        Bookings b ON bd.booking_id = b.booking_id
    WHERE 
        m.movie_id = @movieId
        AND c.name = @cinemaName
        AND CAST(st.start_time AS DATE) = @showDate
        AND CAST(st.start_time AS TIME) BETWEEN @startTimeBegin AND @startTimeEnd
        AND (bd.booking_detail_id IS NULL OR b.booking_status = 'Cancelled')
    ORDER BY 
        st.start_time, s.seat_row, s.seat_number;
END;
GO

EXEC GetAvailableSeats 
    @movieId = 1, 
    @cinemaName = 'CGV Landmark 81',
    @showDate = '2025-03-10',
    @startTimeBegin = '04:30:00',
    @startTimeEnd = '07:15:00';
GO

-- select * from Booking_Details;
-- select * from Bookings;
-- select * from Users;



CREATE OR ALTER PROCEDURE BookTickets
    @user_id INT,
    @showtime_id INT,
    @seat_ids NVARCHAR(MAX),
    @ticket_types NVARCHAR(MAX),
    @payment_method NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Declare variables
    DECLARE @booking_id INT;
    DECLARE @total_amount MONEY = 0;
    DECLARE @transaction_id NVARCHAR(100);
    DECLARE @error_message NVARCHAR(MAX);
    DECLARE @showtime_start DATETIME;
    DECLARE @showtime_end DATETIME;
    DECLARE @current_time DATETIME = GETDATE();
    
    -- Begin transaction
    BEGIN TRY
        -- Get showtime information
        SELECT @showtime_start = start_time, @showtime_end = end_time
        FROM Showtimes
        WHERE showtime_id = @showtime_id;
        
        -- Check if showtime is in the past
        IF @showtime_start < @current_time
        BEGIN
            RAISERROR('Suất chiếu đã kết thúc hoặc đã bắt đầu', 16, 1);
            RETURN;
        END
 
        BEGIN TRANSACTION;
        
        -- Create temp table to hold seat and ticket type data
        CREATE TABLE #BookingSeats (
            seat_id INT,
            ticket_type NVARCHAR(20)
        );
        
        -- Parse the comma-delimited seat IDs and ticket types
        WITH 
        Seats AS (
            SELECT 
                value AS seat_id,
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num
            FROM STRING_SPLIT(@seat_ids, ',')
        ),
        TicketTypes AS (
            SELECT 
                value AS ticket_type,
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num
            FROM STRING_SPLIT(@ticket_types, ',')
        )
        INSERT INTO #BookingSeats (seat_id, ticket_type)
        SELECT Seats.seat_id, TicketTypes.ticket_type
        FROM Seats JOIN TicketTypes ON Seats.row_num = TicketTypes.row_num;

        -- Validate seats - make sure they're for the correct room and available
        IF EXISTS (
            SELECT 1 
            FROM #BookingSeats bs 
            JOIN Seats s ON bs.seat_id = s.seat_id
            JOIN Showtimes st ON st.showtime_id = @showtime_id
            WHERE s.room_id != st.room_id
        )
        BEGIN
            RAISERROR('Một hoặc nhiều ghế không thuộc phòng chiếu này', 16, 1);
            RETURN;
        END

        -- Check if any seat is already booked
        IF EXISTS (
            SELECT 1 
            FROM Booking_Details bd 
            WHERE bd.showtime_id = @showtime_id 
            AND bd.seat_id IN (SELECT seat_id FROM #BookingSeats)
        )
        BEGIN
            RAISERROR('Một hoặc nhiều ghế đã được đặt', 16, 1);
            RETURN;
        END

        -- Calculate ticket prices based on seat type, ticket type, and showtime pricing
        SELECT @total_amount = SUM(
            CASE 
                WHEN bs.ticket_type = 'Standard' THEN st.base_price * s.price_modifier
                WHEN bs.ticket_type = 'Student' THEN st.student_price * s.price_modifier
                WHEN bs.ticket_type = 'Child' THEN st.child_price * s.price_modifier
                WHEN bs.ticket_type = 'Senior' THEN st.senior_price * s.price_modifier
            END
        )
        FROM #BookingSeats bs
        JOIN Seats s ON bs.seat_id = s.seat_id
        CROSS JOIN Showtimes st 
        WHERE st.showtime_id = @showtime_id;
        
        -- Generate a transaction ID
SET @transaction_id = 'TXN' + CONVERT(VARCHAR(8), GETDATE(), 112) + 
                     RIGHT('00000000' + CAST(FLOOR(RAND() * 100000000) AS VARCHAR(20)), 8);               
        -- Insert booking record
        INSERT INTO Bookings (
            user_id, booking_date, total_amount, payment_method, 
            transaction_id, payment_status, booking_status,
            discount_amount, discount_code, additional_purchases -- Required columns with default values
        )
        VALUES (
            @user_id, GETDATE(), @total_amount, @payment_method,
            @transaction_id, 'Pending', 'Pending',
            0, NULL, 0 -- Default values
        );
        
        -- Get the booking ID
        SET @booking_id = SCOPE_IDENTITY();
        
        -- Insert booking details
        INSERT INTO Booking_Details (
            booking_id, showtime_id, seat_id, price, ticket_type
        )
        SELECT 
            @booking_id,
            @showtime_id,
            bs.seat_id,
            CASE 
                WHEN bs.ticket_type = 'Standard' THEN st.base_price * s.price_modifier
                WHEN bs.ticket_type = 'Student' THEN st.student_price * s.price_modifier
                WHEN bs.ticket_type = 'Child' THEN st.child_price * s.price_modifier
                WHEN bs.ticket_type = 'Senior' THEN st.senior_price * s.price_modifier
            END,
            bs.ticket_type
        FROM #BookingSeats bs
        JOIN Seats s ON bs.seat_id = s.seat_id
        CROSS JOIN Showtimes st 
        WHERE st.showtime_id = @showtime_id;
        
        -- Simulate payment completion
        UPDATE Bookings 
        SET payment_status = 'Completed', 
            booking_status = 'Confirmed',
            payment_date = GETDATE()
        WHERE booking_id = @booking_id;
        
        -- Cleanup
        DROP TABLE #BookingSeats;
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Return booking ID for reference
        SELECT 
            @booking_id AS booking_id, 
            @transaction_id AS transaction_id,
            @total_amount AS total_amount,
            @payment_method AS payment_method,
            'Confirmed' AS status;
        
    END TRY
    BEGIN CATCH
        -- Rollback on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @error_message = ERROR_MESSAGE();
        
        -- Return error
        SELECT 0 AS booking_id, @error_message AS error_message;
    END CATCH
END;
GO

EXEC BookTickets 
    @user_id = 2,
    @showtime_id = 1,
    @seat_ids = '1',
    @ticket_types = 'Student',
    @payment_method = 'Credit Card';
GO




CREATE OR ALTER PROCEDURE CancelBooking
    @booking_id INT,     -- ID của đặt vé cần hủy
    @user_id INT     -- ID của người dùng để xác minh quyền hủy vé
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Khai báo biến
    DECLARE @booking_status NVARCHAR(20);
    DECLARE @showtime_start DATETIME;
    DECLARE @current_time DATETIME = GETDATE();
    DECLARE @time_before_showtime INT = 60; -- Số phút tối thiểu trước giờ chiếu
    DECLARE @error_message NVARCHAR(MAX);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Kiểm tra xem đặt vé tồn tại và thuộc về người dùng này không
        SELECT @booking_status = b.booking_status, @showtime_start = MIN(st.start_time)
        FROM Bookings b
        JOIN Booking_Details bd ON b.booking_id = bd.booking_id
        JOIN Showtimes st ON bd.showtime_id = st.showtime_id
        WHERE b.booking_id = @booking_id AND b.user_id = @user_id
        GROUP BY b.booking_status;
        
        -- Kiểm tra nếu đặt vé không tồn tại
        IF @booking_status IS NULL
        BEGIN
            RAISERROR('Đặt vé không tồn tại hoặc không thuộc về người dùng này', 16, 1);
            RETURN;
        END
        
        -- Kiểm tra nếu đặt vé đã bị hủy trước đó
        IF @booking_status = 'Cancelled'
        BEGIN
            RAISERROR('Đặt vé này đã bị hủy trước đó', 16, 1);
            RETURN;
        END
        
        -- Kiểm tra thời gian - không cho phép hủy vé nếu quá gần giờ chiếu
        IF DATEDIFF(MINUTE, @current_time, @showtime_start) < @time_before_showtime
        BEGIN
            RAISERROR('Không thể hủy vé khi đã quá gần giờ chiếu (cần hủy trước ít nhất %d phút)', 16, 1, @time_before_showtime);
            RETURN;
        END
        
        -- Cập nhật trạng thái đặt vé
        UPDATE Bookings
        SET 
            booking_status = 'Cancelled',
            payment_status = 'Refunded',
            updated_at = GETDATE()
        WHERE booking_id = @booking_id;
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Trả về thông báo thành công
        SELECT 
            @booking_id AS booking_id,
            'Cancelled' AS booking_status,
            'Refunded' AS payment_status,
            'Đặt vé đã được hủy thành công và tiền sẽ được hoàn trả' AS message;
        
    END TRY
    BEGIN CATCH
        -- Rollback nếu có lỗi
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @error_message = ERROR_MESSAGE();
        
        -- Trả về thông báo lỗi
        SELECT 0 AS booking_id, @error_message AS error_message;
    END CATCH
END;
GO

