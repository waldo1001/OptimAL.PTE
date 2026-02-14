codeunit 74310 "Customer Data Export"
{
    // Business scenario: Export customer list for external reporting system

    procedure ExportCustomerList() ExportedCount: Integer
    var
        Customer: Record "Performance Test Customer";
    begin
        // External system only needs No., Name, City
        Customer.FindSet();
        repeat
            // Simulate export to file/external system
            ExportCustomerToFile(Customer);
            ExportedCount += 1;
        until Customer.Next() = 0;
    end;

    local procedure ExportCustomerToFile(Customer: Record "Performance Test Customer")
    begin
        // In real code, this would write to file or call external API
        // For this demo, we just access the fields
    end;
}
