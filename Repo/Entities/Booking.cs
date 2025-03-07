using System;
using System.Collections.Generic;

namespace Repo.Entities;

public partial class Booking
{
    public int BookingId { get; set; }

    public int UserId { get; set; }

    public DateTime? BookingDate { get; set; }

    public decimal TotalAmount { get; set; }

    public decimal? DiscountAmount { get; set; }

    public string? DiscountCode { get; set; }

    public decimal? AdditionalPurchases { get; set; }

    public string? PaymentMethod { get; set; }

    public string? TransactionId { get; set; }

    public string PaymentStatus { get; set; } = null!;

    public string BookingStatus { get; set; } = null!;

    public DateTime? PaymentDate { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<BookingDetail> BookingDetails { get; set; } = new List<BookingDetail>();

    public virtual User User { get; set; } = null!;
}
