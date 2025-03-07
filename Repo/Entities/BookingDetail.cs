using System;
using System.Collections.Generic;

namespace Repo.Entities;

public partial class BookingDetail
{
    public int BookingDetailId { get; set; }

    public int BookingId { get; set; }

    public int ShowtimeId { get; set; }

    public int SeatId { get; set; }

    public decimal Price { get; set; }

    public string? TicketType { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual Booking Booking { get; set; } = null!;

    public virtual Seat Seat { get; set; } = null!;

    public virtual Showtime Showtime { get; set; } = null!;
}
