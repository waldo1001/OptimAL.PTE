codeunit 74348 "Customer Lock Holder"
{
    // Simulation codeunit - used exclusively by Concurrent Access Simulator for Test 2.
    // Acquires update locks on all Customer records and holds them for a fixed duration.
    // This simulates any background process that has an active transaction on the Customer table.

    trigger OnRun()
    begin
        HoldLocksForTest();
    end;

    local procedure HoldLocksForTest()
    var
        Customer: Record "Performance Test Customer";
    begin
        Customer.FindSet(true);
        Sleep(20000); // Hold locks long enough for the foreground test to run
    end;
}
