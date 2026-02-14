codeunit 74351 "Order Statistics Report"
{
    // Business scenario: Generate detailed order statistics

    procedure CalculateTotalOrderCount() TotalOrders: Integer
    var
        Customer: Record "Performance Test Customer";
        Order: Record "Performance Test Order";
    begin
        // Report needs aggregated counts
        Customer.FindSet();
        repeat
            Order.SetRange("Customer No.", Customer."No.");
            Order.FindSet();
            repeat
                TotalOrders += 1;
            until Order.Next() = 0;
        until Customer.Next() = 0;
    end;

}
