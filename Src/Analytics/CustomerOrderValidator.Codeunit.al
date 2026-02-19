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
    begin
        OnBeforeValidateOrderData(Customer); // A subscriber reads and writes the Customer table here,
                                             // unintentionally leaving locks on records we are about to read.

        Customer.FindSet();
        repeat
            Order.SetRange("Customer No.", Customer."No.");
            if Order.IsEmpty() then
                IssueCount += 1;
            Sleep(10);
        until Customer.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateOrderData(var Customer: Record "Performance Test Customer")
    begin
    end;
}
