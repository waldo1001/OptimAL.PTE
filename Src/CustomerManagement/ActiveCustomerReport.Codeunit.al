codeunit 74311 "Active Customer Report"
{
    // Business scenario: Generate report of customers with active orders

    procedure GetActiveCustomerCount() ActiveCount: Integer
    var
        Customer: Record "Performance Test Customer";
    begin
        // Need to check which customers have orders
        Customer.FindSet();
        repeat
            Customer.CalcFields("Order Count");
            if Customer."Order Count" > 0 then
                ActiveCount += 1;
        until Customer.Next() = 0;
    end;

}
