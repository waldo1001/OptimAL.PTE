codeunit 74340 "Batch Order Processor"
{
    // Business scenario: Batch update order statuses
    // PROBLEM: No Commit() in loop = holds exclusive locks for entire duration

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
            // PROBLEM: No Commit() here = all locks held until the entire loop finishes
        until Customer.Next() = 0;
    end;

}
