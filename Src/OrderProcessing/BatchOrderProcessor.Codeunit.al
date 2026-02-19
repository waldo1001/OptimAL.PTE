codeunit 74340 "Batch Order Processor"
{
    // Business scenario: Batch update order statuses

    trigger OnRun()
    begin
        ProcessPendingOrders();
    end;

    procedure ProcessPendingOrders()
    var
        Customer: Record "Performance Test Customer";
        Counter: Integer;
    begin
        Customer.FindSet(true);
        repeat
            Customer.Status := Customer.Status::Completed;
            Customer.Modify();

            Sleep(5);
            Counter += 1;
            if Counter mod 100 = 0 then
                Commit(); // Release locks every 100 records
        until Customer.Next() = 0;
    end;

}
