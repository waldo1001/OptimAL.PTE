codeunit 74330 "Customer Credit Approval"
{
    // Business scenario: Sales rep approves credit for a single customer
    // This is a fast, single-record update that should take milliseconds.
    // Used as the foreground operation in concurrency testing.

    trigger OnRun()
    begin
        ApproveCreditForNextCustomer();
    end;

    procedure ApproveCreditForNextCustomer(): Boolean
    var
        Customer: Record "Performance Test Customer";
    begin
        if not Customer.FindFirst() then
            exit(false);

        Customer.Status := Customer.Status::Active;
        Customer.Modify(true);
        exit(true);
    end;
}
