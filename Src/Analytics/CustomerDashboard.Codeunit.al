codeunit 74330 "Customer Dashboard"
{
    // Business scenario: Display customer activity dashboard

    procedure GenerateDashboardData() RecordCount: Integer
    var
        Customer: Record "Performance Test Customer";
    begin
        // Dashboard just displays data, no updates
        Customer.FindSet();
        repeat
            RecordCount += 1;
        until Customer.Next() = 0;
    end;

}
