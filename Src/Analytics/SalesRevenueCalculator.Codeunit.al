codeunit 74321 "Sales Revenue Calculator"
{
    // Business scenario: Calculate revenue for financial reporting

    procedure GetTotalRevenue() TotalRevenue: Decimal
    var
        Order: Record "Performance Test Order";
    begin
        Order.CalcSums(Amount);
        TotalRevenue := Order.Amount;
    end;

}
