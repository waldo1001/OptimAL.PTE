codeunit 74345 "Customer Order Validator"
{
    // Business scenario: Read-only validation of order data consistency.

    trigger OnRun()
    begin
        ValidateOrderData();
    end;

    procedure ValidateOrderData() IssueCount: Integer
    var
        Customer: Record "Performance Test Customer";
        Order: Record "Performance Test Order";
        Counter: Integer;
    begin
        Customer.ReadIsolation := IsolationLevel::ReadUncommitted;
        Customer.FindSet();
        repeat
            Order.SetRange("Customer No.", Customer."No.");
            if Order.IsEmpty() then
                IssueCount += 1;
            Counter += 1;
        until (Customer.Next() = 0) or (Counter >= 100);
    end;
}
