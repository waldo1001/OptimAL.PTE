codeunit 74394 "Background Data Generator"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        StartNo: Integer;
        EndNo: Integer;
    begin
        // Parse parameters from job queue entry: "StartNo|EndNo"
        if not ParseParameters(Rec."Parameter String", StartNo, EndNo) then
            exit;

        // Generate this batch of data
        GenerateBatch(StartNo, EndNo);
    end;

    local procedure ParseParameters(ParameterString: Text; var StartNo: Integer; var EndNo: Integer): Boolean
    var
        PipePos: Integer;
    begin
        if ParameterString = '' then
            exit(false);

        PipePos := StrPos(ParameterString, '|');
        if PipePos = 0 then
            exit(false);

        if not Evaluate(StartNo, CopyStr(ParameterString, 1, PipePos - 1)) then
            exit(false);

        if not Evaluate(EndNo, CopyStr(ParameterString, PipePos + 1)) then
            exit(false);

        exit(true);
    end;

    procedure GenerateBatch(StartNo: Integer; EndNo: Integer)
    var
        DataSource: Record "Performance Test Data Source";
        Customer: Record "Performance Test Customer";
        Order: Record "Performance Test Order";
        i: Integer;
        OrderCount: Integer;
        OrderNo: Integer;
    begin
        // Generate data source records for this batch
        for i := StartNo to EndNo do begin
            if not DataSource.Get('CUST-' + Format(i, 0, '<Integer,6><Filler Character,0>')) then begin
                DataSource.Init();
                DataSource."No." := 'CUST-' + Format(i, 0, '<Integer,6><Filler Character,0>');
                DataSource.Name := 'Data Source ' + Format(i);
                DataSource.Address := Format(i) + ' Main Street';
                DataSource.City := 'City ' + Format(i mod 100);
                DataSource."Phone No." := '+1-555-' + Format(i, 0, '<Integer,4><Filler Character,0>');
                DataSource.Status := DataSource.Status::New;
                DataSource.Insert();
            end;

            if (i mod 100) = 0 then begin
                // Commit every 100 records to avoid long transactions
                Commit();
            end;
        end;

        // Generate customers for this batch
        for i := StartNo to EndNo do begin
            if not Customer.Get('CUST-' + Format(i, 0, '<Integer,6><Filler Character,0>')) then begin
                Customer.Init();
                Customer."No." := 'CUST-' + Format(i, 0, '<Integer,6><Filler Character,0>');
                Customer.Name := 'Data Source ' + Format(i);
                Customer.Address := Format(i) + ' Main Street';
                Customer.City := 'City ' + Format(i mod 100);
                Customer."Phone No." := '+1-555-' + Format(i, 0, '<Integer,4><Filler Character,0>');
                Customer.Status := Customer.Status::New;
                Customer.Insert();
            end;

            if (i mod 100) = 0 then begin
                // Commit every 100 records to avoid long transactions
                Commit();
            end;
        end;

        // Generate orders for each customer in this batch
        for i := StartNo to EndNo do begin
            if Customer.Get('CUST-' + Format(i, 0, '<Integer,6><Filler Character,0>')) then begin
                OrderCount := 10 + (i mod 41); // 10 to 50 orders per customer
                for OrderNo := 1 to OrderCount do begin
                    Order.Init();
                    Order."No." := Customer."No." + '-ORD-' + Format(OrderNo);
                    if not Order.Get(Order."No.") then begin
                        Order."Customer No." := Customer."No.";
                        Order."Order Date" := CalcDate('<-' + Format((i + OrderNo) mod 365) + 'D>', Today());
                        Order.Amount := 100 + ((i + OrderNo) mod 9900);
                        Order.Description := 'Order ' + Format(OrderNo) + ' for ' + Customer.Name;
                        Order.Status := Order.Status::Active;
                        Order.Insert();
                    end;
                end;
            end;

            if (i mod 100) = 0 then begin
                // Commit every 100 records to avoid long transactions
                Commit();
            end;
        end;

        // Commit after this batch completes
        Commit();
    end;
}
