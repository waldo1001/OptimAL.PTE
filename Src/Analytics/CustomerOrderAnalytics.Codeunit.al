codeunit 74350 "Customer Order Analytics"
{
    // Business scenario: Report combining customer and order data

    procedure BuildCustomerOrderReport() TotalProcessed: Integer
    var
        Qry: Query "Customer Order Report";
    begin
        Qry.Open();
        while Qry.Read() do begin
            // Access Qry.CustomerNo, Qry.CustomerName, Qry.OrderNo, Qry.OrderAmount
            TotalProcessed += 1;
        end;
        Qry.Close();
    end;

}
