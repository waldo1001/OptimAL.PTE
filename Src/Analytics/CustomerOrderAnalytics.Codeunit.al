codeunit 74350 "Customer Order Analytics"
{
    // Business scenario: Order report showing customer details per order

    procedure BuildOrderReport() TotalOrders: Integer
    var
        Customer: Record "Performance Test Customer";
        Order: Record "Performance Test Order";
    begin
        // Build report: for each order, look up customer details
        Order.FindSet();
        repeat
            Customer.Get(Order."Customer No.");
            // Use Customer.Name for report line
            TotalOrders += 1;
        until Order.Next() = 0;
    end;

}
