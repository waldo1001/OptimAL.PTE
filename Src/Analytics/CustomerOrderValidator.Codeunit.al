codeunit 74345 "Customer Order Validator"
{
    // Business scenario: Validate order data consistency
    // PROBLEM: Uses LockTable() for "consistent reads" but this is a read-only process.
    // The LockTable() causes UpdLocks on every record read, blocking all writers.

    trigger OnRun()
    begin
        ValidateOrderData();
    end;

    procedure ValidateOrderData() IssueCount: Integer
    var
        Customer: Record "Performance Test Customer";
        Order: Record "Performance Test Order";
    begin
        // "Ensure consistent data during validation" - sounds reasonable, but this is read-only!
        Customer.LockTable();
        Order.LockTable();

        Customer.FindSet();
        repeat
            Order.SetRange("Customer No.", Customer."No.");
            if Order.IsEmpty() then
                IssueCount += 1; // Customer with no orders
            Sleep(10); // Simulates complex validation logic per record
        until Customer.Next() = 0;
    end;
}
