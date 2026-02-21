codeunit 74350 "Customer Order Analytics"
{
    // Business scenario: Report combining customer and order data

    procedure BuildCustomerOrderReport() TotalProcessed: Integer
    var
        Customer: Record "Performance Test Customer";
        Order: Record "Performance Test Order";
    begin
        // Nested loop: manually joining Customer --> Order record by record
        if Customer.FindSet() then
            repeat
                Order.SetRange("Customer No.", Customer."No.");
                if Order.FindSet() then
                    repeat
                        // Combine customer + order data for each report line
                        TotalProcessed += 1;
                    until Order.Next() = 0;
            until Customer.Next() = 0;
    end;

}
