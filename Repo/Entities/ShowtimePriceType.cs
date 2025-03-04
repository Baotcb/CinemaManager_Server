using System;
using System.Collections.Generic;

namespace Repo.Entities;

public partial class ShowtimePriceType
{
    public int Id { get; set; }

    public int ShowtimeId { get; set; }

    public int PriceTypeId { get; set; }

    public decimal Price { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual PriceType PriceType { get; set; } = null!;

    public virtual Showtime Showtime { get; set; } = null!;
}
