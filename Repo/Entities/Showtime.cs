using System;
using System.Collections.Generic;

namespace Repo.Entities;

public partial class Showtime
{
    public int ShowtimeId { get; set; }

    public int MovieId { get; set; }

    public int RoomId { get; set; }

    public DateTime StartTime { get; set; }

    public DateTime EndTime { get; set; }

    public decimal BasePrice { get; set; }

    public decimal? StudentPrice { get; set; }

    public decimal? ChildPrice { get; set; }

    public decimal? SeniorPrice { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<BookingDetail> BookingDetails { get; set; } = new List<BookingDetail>();

    public virtual Movie Movie { get; set; } = null!;

    public virtual Room Room { get; set; } = null!;
}
