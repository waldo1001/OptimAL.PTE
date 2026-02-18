codeunit 74320 "Customer Sales Analyzer"
{
    // Business scenario: Calculate total sales across all customers

    procedure CalculateTotalSales() TotalSales: Decimal
    var
        Customer: Record "Performance Test Customer";
    begin
        // Management dashboard needs aggregate sales data
        // Room 4 optimizations already applied: SetAutoCalcFields + SetLoadFields
        Customer.SetAutoCalcFields("Total Sales", "Order Count");
        Customer.SetLoadFields("No.", "Total Sales", "Order Count");
        Customer.FindSet();
        repeat
            TotalSales += Customer."Total Sales";
        until Customer.Next() = 0;
    end;

}
