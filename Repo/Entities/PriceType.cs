using System;
using System.Collections.Generic;

namespace Repo.Entities;

public partial class PriceType
{
    public int PriceTypeId { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public decimal Modifier { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<BookingDetail> BookingDetails { get; set; } = new List<BookingDetail>();

    public virtual ICollection<ShowtimePriceType> ShowtimePriceTypes { get; set; } = new List<ShowtimePriceType>();
}
