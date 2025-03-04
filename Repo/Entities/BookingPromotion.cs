using System;
using System.Collections.Generic;

namespace Repo.Entities;

public partial class BookingPromotion
{
    public int Id { get; set; }

    public int BookingId { get; set; }

    public int PromotionId { get; set; }

    public decimal DiscountAmount { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual Booking Booking { get; set; } = null!;

    public virtual Promotion Promotion { get; set; } = null!;
}
