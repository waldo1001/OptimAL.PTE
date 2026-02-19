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
        until (Customer.Next() = 0) or (Counter >= 2000);
    end;

}
