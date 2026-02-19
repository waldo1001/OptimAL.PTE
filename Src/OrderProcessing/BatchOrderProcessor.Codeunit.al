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
    begin
        // Batch job processes large dataset
        Customer.FindSet(true);
        repeat
            Customer.Status := Customer.Status::Completed;
            Customer.Modify();
            Sleep(50); // Simulates complex business logic per record
        until Customer.Next() = 0;
    end;

}
