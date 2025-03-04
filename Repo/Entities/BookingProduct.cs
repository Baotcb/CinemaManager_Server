using System;
using System.Collections.Generic;

namespace Repo.Entities;

public partial class BookingProduct
{
    public int Id { get; set; }

    public int BookingId { get; set; }

    public int ProductId { get; set; }

    public int Quantity { get; set; }

    public decimal Price { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual Booking Booking { get; set; } = null!;

    public virtual Product Product { get; set; } = null!;
}
