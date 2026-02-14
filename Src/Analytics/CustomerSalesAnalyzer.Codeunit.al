codeunit 74320 "Customer Sales Analyzer"
{
    // Business scenario: Calculate total sales across all customers

    procedure CalculateTotalSales() TotalSales: Decimal
    var
        Customer: Record "Performance Test Customer";
    begin
        // Management dashboard needs aggregate sales data
        Customer.FindSet();
        repeat
            Customer.CalcFields("Total Sales", "Order Count");
            TotalSales += Customer."Total Sales";
        until Customer.Next() = 0;
    end;

}
