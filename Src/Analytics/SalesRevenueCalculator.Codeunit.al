codeunit 74321 "Sales Revenue Calculator"
{
    // Business scenario: Calculate revenue for financial reporting

    procedure GetTotalRevenue() TotalRevenue: Decimal
    var
        Order: Record "Performance Test Order";
    begin
        // Financial report needs order totals
        Order.FindSet();
        repeat
            TotalRevenue += Order.Amount;
        until Order.Next() = 0;
    end;

}
