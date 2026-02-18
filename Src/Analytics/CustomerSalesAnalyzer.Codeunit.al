codeunit 74320 "Customer Sales Analyzer"
{
    // Business scenario: Calculate total sales across all customers

    procedure CalculateTotalSales() TotalSales: Decimal
    var
        Customer: Record "Performance Test Customer";
    begin
        // Management dashboard needs aggregate sales data

        // NOTE: You could calculate the grand total with Order.CalcSums(Amount) directly.
        // But the learning objective here is to demonstrate how SIFT keys make FlowField
        // aggregations fast. In real scenarios, you often need per-customer FlowField values
        // for segmentation, filtering, or detailed reporting - and SIFT is essential for that.

        Customer.SetAutoCalcFields("Total Sales", "Order Count");
        Customer.SetLoadFields("No.", "Total Sales", "Order Count");
        Customer.FindSet();
        repeat
            TotalSales += Customer."Total Sales";
        until Customer.Next() = 0;
    end;

}
