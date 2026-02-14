codeunit 74350 "Customer Order Analytics"
{
    // Business scenario: Dashboard showing which customers have orders

    procedure GetCustomersWithOrders() CustomersWithOrders: Integer
    var
        Customer: Record "Performance Test Customer";
        Order: Record "Performance Test Order";
    begin
        // Dashboard tiles showing activity
        Customer.FindSet();
        repeat
            Order.SetRange("Customer No.", Customer."No.");
            if not Order.IsEmpty() then
                CustomersWithOrders += 1;
        until Customer.Next() = 0;
    end;

}
