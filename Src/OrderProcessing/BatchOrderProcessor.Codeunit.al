codeunit 74340 "Batch Order Processor"
{
    // Business scenario: Batch update order statuses

    procedure ProcessPendingOrders()
    var
        Customer: Record "Performance Test Customer";
    begin
        // Batch job processes large dataset
        Customer.LockTable();
        Customer.FindSet(true);
        repeat
            Customer.Status := Customer.Status::Completed;
            Customer.Modify();
        until Customer.Next() = 0;
    end;

}
