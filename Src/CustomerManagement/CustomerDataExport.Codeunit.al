codeunit 74310 "Customer Data Export"
{
    // Business scenario: Export customer list for external reporting system

    procedure ExportCustomerList() ExportedCount: Integer
    var
        Customer: Record "Performance Test Customer";
    begin
        Customer.SetLoadFields("No.", Name, City);
        Customer.FindSet();
        repeat
            ExportCustomerToFile(Customer);
            ExportedCount += 1;
        until Customer.Next() = 0;
    end;

    local procedure ExportCustomerToFile(Customer: Record "Performance Test Customer")
    var
        Line: Text;
    begin
        // Format customer data for external reporting system
        Line := Customer."No." + ',' + Customer.Name + ',' + Customer.City;
        // In real scenario, this would write to file or call external API
    end;
}
