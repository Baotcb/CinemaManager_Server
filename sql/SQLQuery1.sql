
Create database Cinema_Manager;

go
use Cinema_Manager;
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
    seat_type NVARCHAR(20) NOT NULL, -- Loại ghế (thường, VIP, đôi)
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Seats_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE,
    CONSTRAINT UQ_Seat_Room UNIQUE (room_id, seat_row, seat_number) -- Mỗi ghế trong phòng phải là duy nhất
);
go
-- Bảng Showtimes (Lịch chiếu)
CREATE TABLE Showtimes (
    showtime_id INT PRIMARY KEY IDENTITY(1,1),
    movie_id INT NOT NULL,
    room_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    price MONEY NOT NULL, -- Giá vé cơ bản
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Showtimes_Movies FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    CONSTRAINT FK_Showtimes_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE
);
go
-- Bảng Price_Types (Loại giá vé)
CREATE TABLE Price_Types (
    price_type_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50) NOT NULL, -- Tên loại (thường, học sinh-sinh viên, người cao tuổi, VIP...)
    description NVARCHAR(MAX),
    modifier DECIMAL(3,2) NOT NULL, -- Hệ số nhân với giá gốc (0.8 = giảm 20%, 1.2 = tăng 20%)
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
go
-- Bảng Showtime_Price_Types (Giá vé theo loại và suất chiếu)
CREATE TABLE Showtime_Price_Types (
    id INT PRIMARY KEY IDENTITY(1,1),
    showtime_id INT NOT NULL,
    price_type_id INT NOT NULL,
    price MONEY NOT NULL, -- Giá vé cụ thể cho loại này
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ShowtimePriceTypes_Showtimes FOREIGN KEY (showtime_id) REFERENCES Showtimes(showtime_id) ON DELETE CASCADE,
    CONSTRAINT FK_ShowtimePriceTypes_PriceTypes FOREIGN KEY (price_type_id) REFERENCES Price_Types(price_type_id) ON DELETE CASCADE,
    CONSTRAINT UQ_Showtime_PriceType UNIQUE (showtime_id, price_type_id)
);
go
-- Bảng Bookings (Đặt vé)
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    booking_date DATETIME DEFAULT GETDATE(),
    total_amount MONEY NOT NULL,
    payment_method NVARCHAR(50),
    payment_status NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Trạng thái thanh toán (Pending, Completed, Failed, Refunded)
    booking_status NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Trạng thái đặt vé (Pending, Confirmed, Cancelled)
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
    price_type_id INT NOT NULL,
    price MONEY NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_BookingDetails_Bookings FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_BookingDetails_Showtimes FOREIGN KEY (showtime_id) REFERENCES Showtimes(showtime_id),
    CONSTRAINT FK_BookingDetails_Seats FOREIGN KEY (seat_id) REFERENCES Seats(seat_id),
    CONSTRAINT FK_BookingDetails_PriceTypes FOREIGN KEY (price_type_id) REFERENCES Price_Types(price_type_id),
    CONSTRAINT UQ_Showtime_Seat UNIQUE (showtime_id, seat_id) -- Mỗi ghế chỉ có thể được đặt một lần cho mỗi suất chiếu
);
go
-- Bảng Products (Sản phẩm phụ - bắp, nước,...)
CREATE TABLE Products (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    price MONEY NOT NULL,
    category NVARCHAR(50) NOT NULL, -- Loại sản phẩm (đồ ăn, đồ uống...)
    image_url NVARCHAR(255),
    is_available BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
go
-- Bảng Booking_Products (Sản phẩm đi kèm với đặt vé)
CREATE TABLE Booking_Products (
    id INT PRIMARY KEY IDENTITY(1,1),
    booking_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price MONEY NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_BookingProducts_Bookings FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_BookingProducts_Products FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
go
-- Bảng Promotions (Khuyến mãi)
CREATE TABLE Promotions (
    promotion_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    code NVARCHAR(20) UNIQUE,
    description NVARCHAR(MAX),
    discount_type NVARCHAR(10) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')), -- Loại giảm giá (phần trăm hoặc cố định)
    discount_value DECIMAL(10,2) NOT NULL, -- Giá trị giảm giá
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    min_purchase MONEY DEFAULT 0, -- Giá trị mua tối thiểu để áp dụng
    max_discount MONEY, -- Giảm giá tối đa (cho loại phần trăm)
    usage_limit INT, -- Giới hạn sử dụng
    usage_count INT DEFAULT 0, -- Số lần đã sử dụng
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
go
-- Bảng Booking_Promotions (Khuyến mãi áp dụng cho đặt vé)
CREATE TABLE Booking_Promotions (
    id INT PRIMARY KEY IDENTITY(1,1),
    booking_id INT NOT NULL,
    promotion_id INT NOT NULL,
    discount_amount MONEY NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_BookingPromotions_Bookings FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_BookingPromotions_Promotions FOREIGN KEY (promotion_id) REFERENCES Promotions(promotion_id)
);
go
-- Bảng Reviews (Đánh giá phim)
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 10), -- Đánh giá từ 1-10
    comment NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Reviews_Users FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Reviews_Movies FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    CONSTRAINT UQ_User_Movie UNIQUE (user_id, movie_id) -- Mỗi người dùng chỉ có thể đánh giá một bộ phim một lần
);
go
-- Bảng Payments (Thanh toán)
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY IDENTITY(1,1),
    booking_id INT NOT NULL,
    amount MONEY NOT NULL,
    payment_method NVARCHAR(50) NOT NULL,
    transaction_id NVARCHAR(100),
    payment_status NVARCHAR(20) NOT NULL,
    payment_date DATETIME DEFAULT GETDATE(),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Payments_Bookings FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- Trigger để cập nhật trường updated_at khi dữ liệu được cập nhật
GO
CREATE TRIGGER TR_Users_UpdatedAt ON Users AFTER UPDATE AS
BEGIN
    UPDATE Users SET updated_at = GETDATE() FROM Users INNER JOIN inserted ON Users.user_id = inserted.user_id
END
GO

CREATE TRIGGER TR_Movies_UpdatedAt ON Movies AFTER UPDATE AS
BEGIN
    UPDATE Movies SET updated_at = GETDATE() FROM Movies INNER JOIN inserted ON Movies.movie_id = inserted.movie_id
END
GO

CREATE TRIGGER TR_Cinemas_UpdatedAt ON Cinemas AFTER UPDATE AS
BEGIN
    UPDATE Cinemas SET updated_at = GETDATE() FROM Cinemas INNER JOIN inserted ON Cinemas.cinema_id = inserted.cinema_id
END
GO

CREATE TRIGGER TR_Rooms_UpdatedAt ON Rooms AFTER UPDATE AS
BEGIN
    UPDATE Rooms SET updated_at = GETDATE() FROM Rooms INNER JOIN inserted ON Rooms.room_id = inserted.room_id
END
GO

CREATE TRIGGER TR_Seats_UpdatedAt ON Seats AFTER UPDATE AS
BEGIN
    UPDATE Seats SET updated_at = GETDATE() FROM Seats INNER JOIN inserted ON Seats.seat_id = inserted.seat_id
END
GO

CREATE TRIGGER TR_Showtimes_UpdatedAt ON Showtimes AFTER UPDATE AS
BEGIN
    UPDATE Showtimes SET updated_at = GETDATE() FROM Showtimes INNER JOIN inserted ON Showtimes.showtime_id = inserted.showtime_id
END
GO

CREATE TRIGGER TR_PriceTypes_UpdatedAt ON Price_Types AFTER UPDATE AS
BEGIN
    UPDATE Price_Types SET updated_at = GETDATE() FROM Price_Types INNER JOIN inserted ON Price_Types.price_type_id = inserted.price_type_id
END
GO

CREATE TRIGGER TR_ShowtimePriceTypes_UpdatedAt ON Showtime_Price_Types AFTER UPDATE AS
BEGIN
    UPDATE Showtime_Price_Types SET updated_at = GETDATE() FROM Showtime_Price_Types INNER JOIN inserted ON Showtime_Price_Types.id = inserted.id
END
GO

CREATE TRIGGER TR_Bookings_UpdatedAt ON Bookings AFTER UPDATE AS
BEGIN
    UPDATE Bookings SET updated_at = GETDATE() FROM Bookings INNER JOIN inserted ON Bookings.booking_id = inserted.booking_id
END
GO

CREATE TRIGGER TR_BookingDetails_UpdatedAt ON Booking_Details AFTER UPDATE AS
BEGIN
    UPDATE Booking_Details SET updated_at = GETDATE() FROM Booking_Details INNER JOIN inserted ON Booking_Details.booking_detail_id = inserted.booking_detail_id
END
GO

CREATE TRIGGER TR_Products_UpdatedAt ON Products AFTER UPDATE AS
BEGIN
    UPDATE Products SET updated_at = GETDATE() FROM Products INNER JOIN inserted ON Products.product_id = inserted.product_id
END
GO

CREATE TRIGGER TR_BookingProducts_UpdatedAt ON Booking_Products AFTER UPDATE AS
BEGIN
    UPDATE Booking_Products SET updated_at = GETDATE() FROM Booking_Products INNER JOIN inserted ON Booking_Products.id = inserted.id
END
GO

CREATE TRIGGER TR_Promotions_UpdatedAt ON Promotions AFTER UPDATE AS
BEGIN
    UPDATE Promotions SET updated_at = GETDATE() FROM Promotions INNER JOIN inserted ON Promotions.promotion_id = inserted.promotion_id
END
GO

CREATE TRIGGER TR_BookingPromotions_UpdatedAt ON Booking_Promotions AFTER UPDATE AS
BEGIN
    UPDATE Booking_Promotions SET updated_at = GETDATE() FROM Booking_Promotions INNER JOIN inserted ON Booking_Promotions.id = inserted.id
END
GO

CREATE TRIGGER TR_Reviews_UpdatedAt ON Reviews AFTER UPDATE AS
BEGIN
    UPDATE Reviews SET updated_at = GETDATE() FROM Reviews INNER JOIN inserted ON Reviews.review_id = inserted.review_id
END
GO

CREATE TRIGGER TR_Payments_UpdatedAt ON Payments AFTER UPDATE AS
BEGIN
    UPDATE Payments SET updated_at = GETDATE() FROM Payments INNER JOIN inserted ON Payments.payment_id = inserted.payment_id
END
GO



-- Insert dữ liệu mẫu


INSERT INTO Users (username, password, email, full_name, phone_number, date_of_birth, address, is_admin)
VALUES 
('john_doe', 'password123', 'john.doe@example.com', 'John Doe', '1234567890', '1985-05-15', '123 Main St, Anytown, USA', 0),
('jane_smith', 'password456', 'jane.smith@example.com', 'Jane Smith', '0987654321', '1990-08-25', '456 Elm St, Othertown, USA', 0),
('admin_user', 'adminpassword', 'admin@example.com', 'Admin User', '1122334455', '1980-01-01', '789 Oak St, Admin City, USA', 1);
GO
-- Insert additional movies - Currently showing movies
-- Insert currently showing movies
INSERT INTO Movies (title, description, duration, release_date, end_date, genre, director, cast, poster_url, trailer_url, language, subtitle, rating, age_restriction)
VALUES 
('The Last Journey', 'An epic adventure across unexplored lands where a group of explorers discover ancient secrets.', 145, '2025-01-05', '2025-03-10', 'Adventure, Fantasy', 'Christopher Nolan', 'Tom Hardy, Zendaya, Ryan Gosling', '/posters/last_journey.jpg', '/trailers/last_journey.mp4', 'English', 'Vietnamese', 8.4, 'C13'),

('Whispers in the Dark', 'A psychological thriller about a detective who begins to question his own sanity while investigating a series of mysterious disappearances.', 118, '2025-01-18', '2025-03-18', 'Thriller, Mystery', 'David Lynch', 'Jake Gyllenhaal, Tilda Swinton, Michael Shannon', '/posters/whispers.jpg', '/trailers/whispers.mp4', 'English', 'Vietnamese', 7.9, 'C16'),

('Comedy Hour', 'A hilarious comedy about a group of friends who start their own stand-up comedy club in a small town.', 105, '2025-01-22', '2025-03-22', 'Comedy', 'Judd Apatow', 'Kevin Hart, Amy Schumer, Seth Rogen', '/posters/comedy_hour.jpg', '/trailers/comedy_hour.mp4', 'English', 'Vietnamese', 7.5, 'C13'),

('Family Reunion', 'A heartwarming story about three generations coming together to celebrate their grandmother''s 90th birthday.', 110, '2025-02-05', '2025-04-05', 'Drama, Family', 'Greta Gerwig', 'Meryl Streep, Viola Davis, Timothee Chalamet', '/posters/family_reunion.jpg', '/trailers/family_reunion.mp4', 'English', 'Vietnamese', 8.1, 'P'),

('Robot Revolution', 'In a near future, artificial intelligence robots begin developing consciousness and fighting for their rights.', 132, '2025-02-08', '2025-04-10', 'Sci-Fi, Action', 'Denis Villeneuve', 'Idris Elba, Ana de Armas, Oscar Isaac', '/posters/robot_revolution.jpg', '/trailers/robot_revolution.mp4', 'English', 'Vietnamese', 8.3, 'C13'),

('Midnight Dancers', 'A musical drama following the lives of street dancers who perform at night to raise money for their community center.', 128, '2025-01-15', '2025-03-15', 'Musical, Drama', 'Lin-Manuel Miranda', 'Zendaya, Anthony Ramos, Ariana Grande', '/posters/midnight_dancers.jpg', '/trailers/midnight_dancers.mp4', 'English', 'Vietnamese', 8.0, 'P'),

('Ocean''s Depths', 'A documentary exploring the unexplored regions of the Mariana Trench and the strange creatures that live there.', 95, '2025-02-01', '2025-04-01', 'Documentary', 'James Cameron', 'Narrated by David Attenborough', '/posters/oceans_depths.jpg', '/trailers/oceans_depths.mp4', 'English', 'Vietnamese', 8.6, 'P');

GO


-- Insert upcoming movies (release_date is after current date)
INSERT INTO Movies (title, description, duration, release_date, end_date, genre, director, cast, poster_url, trailer_url, language, subtitle, rating, age_restriction)
VALUES 
('The Hidden Kingdom', 'A fantasy adventure about a young girl who discovers a portal to a magical kingdom threatened by dark forces.', 140, '2025-03-15', '2025-05-15', 'Fantasy, Adventure', 'Guillermo del Toro', 'Millie Bobby Brown, Lupita Nyongo, Ken Watanabe', '/posters/hidden_kingdom.jpg', '/trailers/hidden_kingdom.mp4', 'English', 'Vietnamese', 8.2, 'P'),

('Speed Demons', 'A high-octane action film about street racing and undercover operations.', 125, '2025-03-20', '2025-05-20', 'Action, Crime', 'Justin Lin', 'John Cena, Michelle Rodriguez, Jason Statham', '/posters/speed_demons.jpg', '/trailers/speed_demons.mp4', 'English', 'Vietnamese', 7.8, 'C16'),

('Lost in Translation 2', 'The sequel to the beloved film follows a new generation experiencing cultural disconnection in modern-day Tokyo.', 115, '2025-03-25', '2025-05-25', 'Drama, Comedy', 'Sofia Coppola', 'Elle Fanning, Rinko Kikuchi, Dev Patel', '/posters/lost_translation2.jpg', '/trailers/lost_translation2.mp4', 'English, Japanese', 'Vietnamese', 7.9, 'C13'),

('The Heist', 'A meticulously planned bank heist goes awry, leading to a tense standoff with police.', 130, '2025-04-01', '2025-06-01', 'Crime, Thriller', 'Steven Soderbergh', 'Daniel Craig, Jennifer Lawrence, Mahershala Ali', '/posters/the_heist.jpg', '/trailers/the_heist.mp4', 'English', 'Vietnamese', 8.0, 'C16'),

('Prehistoric Planet', 'When a scientific experiment goes wrong, a modern city is transported back to the Jurassic period.', 138, '2025-04-10', '2025-06-10', 'Sci-Fi, Adventure', 'J.A. Bayona', 'Chris Pratt, Bryce Dallas Howard, Jeff Goldblum', '/posters/prehistoric_planet.jpg', '/trailers/prehistoric_planet.mp4', 'English', 'Vietnamese', 8.2, 'C13'),

('Eternal Love', 'A romantic drama spanning several decades following two lovers who keep finding each other.', 135, '2025-04-15', '2025-06-15', 'Romance, Drama', 'Richard Linklater', 'Saoirse Ronan, Timothee Chalamet, Florence Pugh', '/posters/eternal_love.jpg', '/trailers/eternal_love.mp4', 'English', 'Vietnamese', 8.1, 'C13'),

('Shadows of War', 'A gripping historical drama set during World War II from the perspective of civilians.', 150, '2025-04-20', '2025-06-20', 'War, Drama, History', 'Sam Mendes', 'Gary Oldman, Barry Keoghan, Jessie Buckley', '/posters/shadows_of_war.jpg', '/trailers/shadows_of_war.mp4', 'English', 'Vietnamese', 8.5, 'C16'),

('Laugh Factory', 'A behind-the-scenes look at the competitive world of stand-up comedy.', 112, '2025-05-01', '2025-07-01', 'Comedy, Drama', 'Bo Burnham', 'Bill Hader, Awkwafina, John Mulaney', '/posters/laugh_factory.jpg', '/trailers/laugh_factory.mp4', 'English', 'Vietnamese', 7.7, 'C16'),

('Virtual Reality', 'In a world where most people live in a virtual reality, one woman discovers the truth.', 142, '2025-05-10', '2025-07-10', 'Sci-Fi, Thriller', 'Lana Wachowski', 'Zoe Saldana, John Boyega, Keanu Reeves', '/posters/virtual_reality.jpg', '/trailers/virtual_reality.mp4', 'English', 'Vietnamese', 8.3, 'C13'),

('Mountain of Souls', 'A horror film about hikers who become stranded on a haunted mountain.', 108, '2025-05-15', '2025-07-15', 'Horror, Thriller', 'Ari Aster', 'Florence Pugh, Willem Dafoe, Toni Collette', '/posters/mountain_souls.jpg', '/trailers/mountain_souls.mp4', 'English', 'Vietnamese', 7.6, 'C18');
GO

INSERT INTO Cinemas (name, address, city, phone_number, email, description)
VALUES 
('Galaxy Cinema', '123 Movie Street, District 1', 'Ho Chi Minh City', '028-1234-5678', 'contact@galaxycinema.com', 'Premium theater with latest technology'),
('Star Movies', '456 Entertainment Avenue, District 3', 'Ho Chi Minh City', '028-8765-4321', 'info@starmovies.com', 'Family-friendly cinema with affordable prices'),
('Mega Films', '789 Cinema Boulevard, District 7', 'Ho Chi Minh City', '028-2468-1357', 'support@megafilms.com', 'Luxury experience with premium seating');
GO
-- Insert data for Rooms
INSERT INTO Rooms (cinema_id, room_name, capacity, room_type)
VALUES
-- Galaxy Cinema rooms
(1, 'Room A1', 120, '2D'),
(1, 'Room A2', 150, '3D'),
(1, 'Room A3', 100, '2D'),
(1, 'Room A4', 180, 'IMAX'),
-- Star Movies rooms
(2, 'Room B1', 100, '2D'),
(2, 'Room B2', 120, '3D'),
(2, 'Room B3', 80, '2D'),
-- Mega Films rooms
(3, 'Room C1', 150, '2D'),
(3, 'Room C2', 200, '3D'),
(3, 'Room C3', 120, '4DX'),
(3, 'Room C4', 250, 'IMAX');
GO

-- Insert data for Seats
-- For Room A1 (Galaxy Cinema, 2D)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type)
VALUES
-- Row A - Standard seats
(1, 'A', 1, 'Standard'),
(1, 'A', 2, 'Standard'),
(1, 'A', 3, 'Standard'),
(1, 'A', 4, 'Standard'),
(1, 'A', 5, 'Standard'),
(1, 'A', 6, 'Standard'),
(1, 'A', 7, 'Standard'),
(1, 'A', 8, 'Standard'),
(1, 'A', 9, 'Standard'),
(1, 'A', 10, 'Standard'),
-- Row B - Standard seats
(1, 'B', 1, 'Standard'),
(1, 'B', 2, 'Standard'),
(1, 'B', 3, 'Standard'),
(1, 'B', 4, 'Standard'),
(1, 'B', 5, 'Standard'),
(1, 'B', 6, 'Standard'),
(1, 'B', 7, 'Standard'),
(1, 'B', 8, 'Standard'),
(1, 'B', 9, 'Standard'),
(1, 'B', 10, 'Standard'),
-- Row C - Standard seats
(1, 'C', 1, 'Standard'),
(1, 'C', 2, 'Standard'),
(1, 'C', 3, 'Standard'),
(1, 'C', 4, 'Standard'),
(1, 'C', 5, 'Standard'),
(1, 'C', 6, 'Standard'),
(1, 'C', 7, 'Standard'),
(1, 'C', 8, 'Standard'),
(1, 'C', 9, 'Standard'),
(1, 'C', 10, 'Standard'),
-- Row D - VIP seats
(1, 'D', 1, 'VIP'),
(1, 'D', 2, 'VIP'),
(1, 'D', 3, 'VIP'),
(1, 'D', 4, 'VIP'),
(1, 'D', 5, 'VIP'),
(1, 'D', 6, 'VIP'),
(1, 'D', 7, 'VIP'),
(1, 'D', 8, 'VIP'),
(1, 'D', 9, 'VIP'),
(1, 'D', 10, 'VIP'),
-- Row E - VIP seats
(1, 'E', 1, 'VIP'),
(1, 'E', 2, 'VIP'),
(1, 'E', 3, 'VIP'),
(1, 'E', 4, 'VIP'),
(1, 'E', 5, 'VIP'),
(1, 'E', 6, 'VIP'),
(1, 'E', 7, 'VIP'),
(1, 'E', 8, 'VIP'),
(1, 'E', 9, 'VIP'),
(1, 'E', 10, 'VIP'),
-- Row F - Couple seats (double seats, so fewer numbers)
(1, 'F', 1, 'Couple'),
(1, 'F', 2, 'Couple'),
(1, 'F', 3, 'Couple'),
(1, 'F', 4, 'Couple'),
(1, 'F', 5, 'Couple');
GO

-- Insert data for Room A2 (60 seats for brevity)
INSERT INTO Seats (room_id, seat_row, seat_number, seat_type)
VALUES
-- Rows A-C: Standard
(2, 'A', 1, 'Standard'), (2, 'A', 2, 'Standard'), (2, 'A', 3, 'Standard'), (2, 'A', 4, 'Standard'), (2, 'A', 5, 'Standard'), 
(2, 'A', 6, 'Standard'), (2, 'A', 7, 'Standard'), (2, 'A', 8, 'Standard'), (2, 'A', 9, 'Standard'), (2, 'A', 10, 'Standard'),
(2, 'B', 1, 'Standard'), (2, 'B', 2, 'Standard'), (2, 'B', 3, 'Standard'), (2, 'B', 4, 'Standard'), (2, 'B', 5, 'Standard'), 
(2, 'B', 6, 'Standard'), (2, 'B', 7, 'Standard'), (2, 'B', 8, 'Standard'), (2, 'B', 9, 'Standard'), (2, 'B', 10, 'Standard'),
(2, 'C', 1, 'Standard'), (2, 'C', 2, 'Standard'), (2, 'C', 3, 'Standard'), (2, 'C', 4, 'Standard'), (2, 'C', 5, 'Standard'), 
(2, 'C', 6, 'Standard'), (2, 'C', 7, 'Standard'), (2, 'C', 8, 'Standard'), (2, 'C', 9, 'Standard'), (2, 'C', 10, 'Standard'),
-- Rows D-E: VIP
(2, 'D', 1, 'VIP'), (2, 'D', 2, 'VIP'), (2, 'D', 3, 'VIP'), (2, 'D', 4, 'VIP'), (2, 'D', 5, 'VIP'), 
(2, 'D', 6, 'VIP'), (2, 'D', 7, 'VIP'), (2, 'D', 8, 'VIP'), (2, 'D', 9, 'VIP'), (2, 'D', 10, 'VIP'),
(2, 'E', 1, 'VIP'), (2, 'E', 2, 'VIP'), (2, 'E', 3, 'VIP'), (2, 'E', 4, 'VIP'), (2, 'E', 5, 'VIP'), 
(2, 'E', 6, 'VIP'), (2, 'E', 7, 'VIP'), (2, 'E', 8, 'VIP'), (2, 'E', 9, 'VIP'), (2, 'E', 10, 'VIP'),
-- Row F: Couple
(2, 'F', 1, 'Couple'), (2, 'F', 2, 'Couple'), (2, 'F', 3, 'Couple'), (2, 'F', 4, 'Couple'), (2, 'F', 5, 'Couple');
GO

-- Insert Price Types
INSERT INTO Price_Types (name, description, modifier)
VALUES
('Standard', 'Regular ticket price', 1.0),
('Student', 'Discount for students with valid ID', 0.8),
('Senior', 'Discount for seniors over 65', 0.8),
('Child', 'Discount for children under 12', 0.7),
('VIP', 'Premium experience with VIP seating', 1.5),
('Couple', 'Special rate for couple seats', 1.8),
('Morning', 'Discount for morning showtimes before 12PM', 0.9),
('Late Night', 'Special rate for shows after 10PM', 0.9),
('Weekend Premium', 'Premium rate for weekend shows', 1.2);
GO
select * from Showtimes
-- Insert Showtimes for currently showing movies
INSERT INTO Showtimes (movie_id, room_id, start_time, end_time, price)
VALUES
-- The Last Journey (movie_id 1) showtimes
(1, 1, '2025-03-01 10:00:00', '2025-03-01 12:25:00', 100000), -- Morning show
(1, 1, '2025-03-01 13:00:00', '2025-03-01 15:25:00', 120000), -- Afternoon show
(1, 1, '2025-03-01 16:00:00', '2025-03-01 18:25:00', 150000), -- Evening show
(1, 1, '2025-03-01 19:00:00', '2025-03-01 21:25:00', 150000), -- Night show
(1, 2, '2025-03-01 11:30:00', '2025-03-01 13:55:00', 120000), -- 3D showing
(1, 2, '2025-03-01 14:30:00', '2025-03-01 16:55:00', 150000), -- 3D showing
(1, 2, '2025-03-01 17:30:00', '2025-03-01 19:55:00', 180000), -- 3D showing
(1, 4, '2025-03-01 12:00:00', '2025-03-01 14:25:00', 200000), -- IMAX showing
(1, 4, '2025-03-01 15:00:00', '2025-03-01 17:25:00', 220000), -- IMAX showing
(1, 4, '2025-03-01 18:00:00', '2025-03-01 20:25:00', 250000), -- IMAX showing

-- Whispers in the Dark (movie_id 2) showtimes
(2, 3, '2025-03-01 10:30:00', '2025-03-01 12:28:00', 100000), -- Morning show
(2, 3, '2025-03-01 13:30:00', '2025-03-01 15:28:00', 120000), -- Afternoon show
(2, 3, '2025-03-01 16:30:00', '2025-03-01 18:28:00', 150000), -- Evening show
(2, 3, '2025-03-01 19:30:00', '2025-03-01 21:28:00', 150000), -- Night show
(2, 8, '2025-03-01 11:00:00', '2025-03-01 12:58:00', 100000), -- At Mega Films

-- Comedy Hour (movie_id 3) showtimes
(3, 5, '2025-03-01 10:15:00', '2025-03-01 12:00:00', 90000),
(3, 5, '2025-03-01 13:15:00', '2025-03-01 15:00:00', 100000),
(3, 5, '2025-03-01 16:15:00', '2025-03-01 18:00:00', 130000),
(3, 5, '2025-03-01 19:15:00', '2025-03-01 21:00:00', 130000),

-- Family Reunion (movie_id 4) showtimes
(4, 6, '2025-03-01 11:15:00', '2025-03-01 13:05:00', 100000),
(4, 6, '2025-03-01 14:15:00', '2025-03-01 16:05:00', 120000),
(4, 6, '2025-03-01 17:15:00', '2025-03-01 19:05:00', 150000),

-- Robot Revolution (movie_id 5) showtimes
(5, 7, '2025-03-01 10:45:00', '2025-03-01 12:57:00', 100000),
(5, 7, '2025-03-01 13:45:00', '2025-03-01 15:57:00', 120000),
(5, 7, '2025-03-01 16:45:00', '2025-03-01 18:57:00', 150000),
(5, 7, '2025-03-01 19:45:00', '2025-03-01 21:57:00', 150000),
(5, 10, '2025-03-01 11:45:00', '2025-03-01 13:57:00', 180000), -- 4DX showing

-- Midnight Dancers (movie_id 6) showtimes
(6, 9, '2025-03-01 12:30:00', '2025-03-01 14:38:00', 100000),
(6, 9, '2025-03-01 15:30:00', '2025-03-01 17:38:00', 120000),
(6, 9, '2025-03-01 18:30:00', '2025-03-01 20:38:00', 150000),

-- Ocean's Depths (movie_id 7) showtimes
(7, 11, '2025-03-01 10:00:00', '2025-03-01 11:35:00', 180000), -- IMAX documentary
(7, 11, '2025-03-01 13:00:00', '2025-03-01 14:35:00', 200000),
(7, 11, '2025-03-01 16:00:00', '2025-03-01 17:35:00', 220000);
GO

-- Insert Showtime_Price_Types
INSERT INTO Showtime_Price_Types (showtime_id, price_type_id, price)
VALUES
-- The Last Journey - Standard room (showtime_id 1)
(1, 1, 100000), -- Standard price
(1, 2, 80000),  -- Student price
(1, 3, 80000),  -- Senior price
(1, 4, 70000),  -- Child price
(1, 7, 90000),  -- Morning discount

-- The Last Journey - Standard room (showtime_id 2)
(2, 1, 120000), -- Standard price
(2, 2, 96000),  -- Student price
(2, 3, 96000),  -- Senior price
(2, 4, 84000),  -- Child price

-- The Last Journey - Standard room (showtime_id 3)
(3, 1, 150000), -- Standard price
(3, 2, 120000), -- Student price
(3, 3, 120000), -- Senior price
(3, 4, 105000), -- Child price

-- The Last Journey - Standard room (showtime_id 4)
(4, 1, 150000), -- Standard price
(4, 2, 120000), -- Student price
(4, 3, 120000), -- Senior price
(4, 4, 105000), -- Child price
(4, 8, 135000), -- Late night discount

-- The Last Journey - 3D room (showtime_id 5)
(5, 1, 120000), -- Standard price
(5, 2, 96000),  -- Student price
(5, 3, 96000),  -- Senior price
(5, 4, 84000),  -- Child price
(5, 7, 108000), -- Morning discount

-- The Last Journey - 3D room (showtime_id 6)
(6, 1, 150000), -- Standard price
(6, 2, 120000), -- Student price
(6, 3, 120000), -- Senior price
(6, 4, 105000), -- Child price

-- The Last Journey - 3D room (showtime_id 7)
(7, 1, 180000), -- Standard price
(7, 2, 144000), -- Student price
(7, 3, 144000), -- Senior price
(7, 4, 126000), -- Child price

-- The Last Journey - IMAX (showtime_id 8)
(8, 1, 200000), -- Standard price
(8, 2, 160000), -- Student price
(8, 3, 160000), -- Senior price
(8, 4, 140000), -- Child price
(8, 5, 300000), -- VIP price

-- The Last Journey - IMAX (showtime_id 9)
(9, 1, 220000), -- Standard price
(9, 2, 176000), -- Student price
(9, 3, 176000), -- Senior price
(9, 4, 154000), -- Child price
(9, 5, 330000), -- VIP price

-- The Last Journey - IMAX (showtime_id 10)
(10, 1, 250000), -- Standard price
(10, 2, 200000), -- Student price
(10, 3, 200000), -- Senior price
(10, 4, 175000), -- Child price
(10, 5, 375000); -- VIP price
GO

-- Insert Products (concessions)
INSERT INTO Products (name, description, price, category, image_url, is_available)
VALUES
-- Food items
('Small Popcorn', 'Fresh buttered popcorn', 40000, 'Food', '/images/products/small_popcorn.jpg', 1),
('Medium Popcorn', 'Fresh buttered popcorn', 60000, 'Food', '/images/products/medium_popcorn.jpg', 1),
('Large Popcorn', 'Fresh buttered popcorn', 80000, 'Food', '/images/products/large_popcorn.jpg', 1),
('Caramel Popcorn', 'Sweet caramel flavored popcorn', 70000, 'Food', '/images/products/caramel_popcorn.jpg', 1),
('Cheese Popcorn', 'Cheesy flavored popcorn', 70000, 'Food', '/images/products/cheese_popcorn.jpg', 1),
('Nachos', 'Crispy nachos with cheese dip', 65000, 'Food', '/images/products/nachos.jpg', 1),
('Hot Dog', 'Juicy hot dog with condiments', 55000, 'Food', '/images/products/hot_dog.jpg', 1),
('Chicken Nuggets', '6 pieces of chicken nuggets', 60000, 'Food', '/images/products/nuggets.jpg', 1),
('French Fries', 'Crispy golden fries', 50000, 'Food', '/images/products/fries.jpg', 1),
('Pizza Slice', 'Cheese and pepperoni pizza slice', 70000, 'Food', '/images/products/pizza.jpg', 1),

-- Beverages
('Small Soda', 'Coca-Cola, Pepsi, Sprite, or Fanta', 30000, 'Beverage', '/images/products/small_soda.jpg', 1),
('Medium Soda', 'Coca-Cola, Pepsi, Sprite, or Fanta', 40000, 'Beverage', '/images/products/medium_soda.jpg', 1),
('Large Soda', 'Coca-Cola, Pepsi, Sprite, or Fanta', 50000, 'Beverage', '/images/products/large_soda.jpg', 1),
('Bottled Water', '500ml purified water', 25000, 'Beverage', '/images/products/water.jpg', 1),
('Coffee', 'Freshly brewed coffee', 45000, 'Beverage', '/images/products/coffee.jpg', 1),
('Milk Tea', 'Sweet and creamy milk tea', 50000, 'Beverage', '/images/products/milk_tea.jpg', 1),
('Fruit Juice', 'Orange, apple, or mixed fruit juice', 55000, 'Beverage', '/images/products/juice.jpg', 1),

-- Combo deals
('Popcorn & Soda Combo', 'Medium popcorn and medium soda', 90000, 'Combo', '/images/products/popcorn_soda_combo.jpg', 1),
('Family Combo', 'Large popcorn, 2 large sodas, and nachos', 160000, 'Combo', '/images/products/family_combo.jpg', 1),
('Deluxe Combo', 'Large popcorn, large soda, hot dog, and nachos', 200000, 'Combo', '/images/products/deluxe_combo.jpg', 1),
('Kids Combo', 'Small popcorn, small soda, and candy', 80000, 'Combo', '/images/products/kids_combo.jpg', 1);
GO

-- Insert Promotions
INSERT INTO Promotions (name, code, description, discount_type, discount_value, start_date, end_date, min_purchase, max_discount, usage_limit, is_active)
VALUES
('Welcome Discount', 'WELCOME25', 'Special 25% discount for new users', 'percentage', 25, '2025-01-01', '2025-12-31', 100000, 50000, 1000, 1),
('Student Tuesday', 'STUDENT20', '20% off on Tuesdays with valid student ID', 'percentage', 20, '2025-01-01', '2025-12-31', 0, 40000, NULL, 1),
('Family Package', 'FAMILY50K', '50,000 VND off for bookings of 4 or more tickets', 'fixed', 50000, '2025-01-01', '2025-06-30', 300000, NULL, NULL, 1),
('Weekday Special', 'WEEKDAY15', '15% off for all shows Monday through Thursday', 'percentage', 15, '2025-02-01', '2025-04-30', 100000, 30000, NULL, 1),
('Mega Cinema Launch', 'MEGA30', '30% off at Mega Cinema', 'percentage', 30, '2025-01-01', '2025-03-31', 150000, 100000, 500, 1),
('Birthday Treat', 'BIRTHDAY', 'Free ticket on your birthday (min purchase of 1 ticket)', 'fixed', 150000, '2025-01-01', '2025-12-31', 150000, NULL, NULL, 1),
('Early Bird', 'EARLY20', '20% off for bookings made 7 days in advance', 'percentage', 20, '2025-02-15', '2025-12-31', 100000, 60000, NULL, 1),
('Valentine Special', 'LOVE2025', 'Special discount for Valentine''s Day', 'percentage', 25, '2025-02-10', '2025-02-14', 200000, 100000, 1000, 1);
GO

-- Insert some sample bookings
INSERT INTO Bookings (user_id, booking_date, total_amount, payment_method, payment_status, booking_status)
VALUES
(1, '2025-02-25 14:22:35', 440000, 'Credit Card', 'Completed', 'Confirmed'),
(2, '2025-02-26 10:15:42', 285000, 'Momo Wallet', 'Completed', 'Confirmed'),
(1, '2025-02-26 16:45:13', 650000, 'Bank Transfer', 'Completed', 'Confirmed'),
(2, '2025-02-27 09:30:22', 310000, 'Credit Card', 'Failed', 'Cancelled'),
(1, '2025-02-28 18:12:07', 830000, 'Credit Card', 'Completed', 'Confirmed'),
(3, '2025-03-01 11:05:50', 520000, 'Momo Wallet', 'Pending', 'Pending');
GO

-- Insert booking details for first booking (2 VIP tickets for The Last Journey IMAX showing)
INSERT INTO Booking_Details (booking_id, showtime_id, seat_id, price_type_id, price)
VALUES
(1, 10, 31, 5, 375000), -- VIP seat D1 for IMAX showing of The Last Journey
(1, 10, 32, 5, 375000); -- VIP seat D2 for IMAX showing of The Last Journey
GO

-- Insert booking details for second booking (2 standard tickets, student discount for Comedy Hour)
INSERT INTO Booking_Details (booking_id, showtime_id, seat_id, price_type_id, price)
VALUES
(2, 17, 11, 2, 96000), -- Standard seat B1 for Comedy Hour with student price
(2, 17, 12, 2, 96000); -- Standard seat B2 for Comedy Hour with student price
GO

-- Insert booking details for third booking (family of 4 for Robot Revolution)
INSERT INTO Booking_Details (booking_id, showtime_id, seat_id, price_type_id, price)
VALUES
(3, 20, 21, 1, 150000), -- Standard seat C1
(3, 20, 22, 1, 150000), -- Standard seat C2
(3, 20, 23, 1, 150000), -- Standard seat C3
(3, 20, 24, 4, 105000); -- Standard seat C4 (child price)
GO

-- Insert booking details for fifth booking (2 Couple seats + 1 standard for Family Reunion)
INSERT INTO Booking_Details (booking_id, showtime_id, seat_id, price_type_id, price)
VALUES
(5, 13, 51, 6, 216000), -- Couple seat F1
(5, 5, 52, 6, 216000), -- Couple seat F2
(5, 5, 1, 1, 120000);  -- Standard seat A1
GO

-- Insert booking products (concessions)
INSERT INTO Booking_Products (booking_id, product_id, quantity, price)
VALUES
(1, 19, 1, 160000), -- Family Combo with booking 1
(2, 18, 1, 90000),  -- Popcorn & Soda Combo with booking 2
(3, 19, 1, 160000), -- Family Combo with booking 3
(3, 10, 1, 70000),  -- Pizza Slice with booking 3
(5, 20, 1, 200000), -- Deluxe Combo with booking 5
(5, 3, 1, 80000);   -- Large Popcorn with booking 5
GO

-- Insert Payments for completed bookings
INSERT INTO Payments (booking_id, amount, payment_method, transaction_id, payment_status, payment_date)
VALUES
(1, 440000, 'Credit Card', 'TXN78912345', 'Completed', '2025-02-25 14:24:10'),
(2, 285000, 'Momo Wallet', 'MOMO98765432', 'Completed', '2025-02-26 10:16:30'),
(3, 650000, 'Bank Transfer', 'BNK12345678', 'Completed', '2025-02-26 16:47:22'),
(4, 310000, 'Credit Card', 'TXN23456789', 'Failed', '2025-02-27 09:32:15'),
(5, 830000, 'Credit Card', 'TXN34567890', 'Completed', '2025-02-28 18:14:45');
GO

-- Insert applied promotions
INSERT INTO Booking_Promotions (booking_id, promotion_id, discount_amount)
VALUES
(1, 1, 110000),  -- Welcome discount (25% off, capped at 50000) for booking 1
(3, 3, 50000),   -- Family package (fixed 50000 off) for booking 3
(5, 4, 124500);  -- Weekday special (15% off) for booking 5
GO

-- Insert reviews
INSERT INTO Reviews (user_id, movie_id, rating, comment)
VALUES
(1, 1, 9, 'Amazing effects and storytelling. One of the best adventure movies I''ve seen in years.'),
(2, 1, 8, 'Great movie with stunning visuals. The plot was engaging throughout.'),
(1, 2, 7, 'Solid thriller with some good twists. A bit slow in the middle but the ending made up for it.'),
(2, 3, 9, 'Absolutely hilarious! Haven''t laughed this much in a theater for a long time.'),
(1, 5, 8, 'Thought-provoking sci-fi with excellent special effects and a compelling story.'),
(2, 6, 7, 'Good performances and choreography. The music was particularly memorable.'),
(1, 7, 10, 'Breathtaking documentary. The underwater scenes were unbelievable.');
GO

-- Update movie ratings based on reviews
UPDATE Movies
SET rating = (SELECT AVG(CAST(rating AS DECIMAL(3,1))) FROM Reviews WHERE Reviews.movie_id = Movies.movie_id)
WHERE movie_id IN (SELECT DISTINCT movie_id FROM Reviews);
GO



SELECT 
    m.movie_id,
    m.title AS movie_title,
    c.cinema_id,
    c.name AS cinema_name,
    c.address AS cinema_address,
    STRING_AGG(CONVERT(VARCHAR, s.start_time, 108), ', ') AS showing_times,
    STRING_AGG(r.room_name + ' (' + r.room_type + ')', ', ') AS rooms
FROM Movies m
INNER JOIN Showtimes s ON m.movie_id = s.movie_id
INNER JOIN Rooms r ON s.room_id = r.room_id
INNER JOIN Cinemas c ON r.cinema_id = c.cinema_id
GROUP BY m.movie_id, m.title, c.cinema_id, c.name, c.address
ORDER BY c.name, m.title;



DECLARE @movie_id INT = 2;  -- ID của bộ phim
DECLARE @start_time DATETIME = '2025-03-01 10:15:00';

-- Truy vấn lấy thông tin phòng và ghế trống cho một bộ phim và thời gian cụ thể
WITH BookedSeats AS (
    -- Lấy các ghế đã được đặt cho suất chiếu cụ thể
    SELECT DISTINCT bd.seat_id
    FROM Showtimes st
    JOIN Booking_Details bd ON st.showtime_id = bd.showtime_id
    WHERE st.movie_id = @movie_id  -- Thay @movie_id bằng ID phim bạn muốn
    AND st.start_time = @start_time  -- Thay @start_time bằng thời gian bắt đầu phim
), 
RoomDetails AS (
    -- Lấy thông tin chi tiết về phòng chiếu
    SELECT 
        r.room_id,
        r.room_name,
        r.cinema_id,
        c.name AS cinema_name,
        r.room_type,
        r.capacity
    FROM Showtimes st
    JOIN Rooms r ON st.room_id = r.room_id
    JOIN Cinemas c ON r.cinema_id = c.cinema_id
    WHERE st.movie_id = @movie_id
    AND st.start_time = @start_time
)

-- Lấy danh sách ghế trống
SELECT 
    rd.room_id,
    rd.room_name,
    rd.cinema_name,
    rd.room_type,
    s.seat_id,
    s.seat_row,
    s.seat_number,
    s.seat_type
FROM RoomDetails rd
JOIN Seats s ON s.room_id = rd.room_id
LEFT JOIN BookedSeats bs ON s.seat_id = bs.seat_id
WHERE bs.seat_id IS NULL
ORDER BY s.seat_row, s.seat_number;

