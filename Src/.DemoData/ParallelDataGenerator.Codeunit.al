codeunit 74393 "Parallel Data Generator"
{
    trigger OnRun()
    begin
        // Called when started as background session
        GenerateFullDatasetBackground();
    end;

    procedure GenerateFullDatasetBackground()
    var
        DataSource: Record "Performance Test Data Source";
        TotalRecords: Integer;
        BatchSize: Integer;
        BatchCount: Integer;
        StartNo: Integer;
        EndNo: Integer;
        i: Integer;
    begin
        // Skip if data already exists
        if DataSource.Count() >= 50000 then
            exit;

        TotalRecords := 50000;
        BatchCount := 50; // More batches = more commits = faster
        BatchSize := TotalRecords div BatchCount;

        // Generate data in small batches with frequent commits for performance
        // Commits every 1,000 records keeps transaction size small
        for i := 1 to BatchCount do begin
            StartNo := ((i - 1) * BatchSize) + 1;
            EndNo := i * BatchSize;

            if i = BatchCount then
                EndNo := TotalRecords;

            GenerateBatchSync(StartNo, EndNo, i);
            Commit(); // Commit every 1,000 records for better performance
        end;
    end;

    procedure GenerateFullDataset()
    begin
        // For button click - call sync version with progress
        GenerateFullDatasetSync();
    end;

    procedure GenerateFullDatasetSync()
    var
        TotalRecords: Integer;
        BatchSize: Integer;
        BatchCount: Integer;
        StartNo: Integer;
        EndNo: Integer;
        i: Integer;
        Window: Dialog;
    begin
        TotalRecords := 50000;
        BatchCount := 10;
        BatchSize := TotalRecords div BatchCount;

        Window.Open('Generating batch #1####### of #2######');

        for i := 1 to BatchCount do begin
            Window.Update(1, i);
            Window.Update(2, BatchCount);

            StartNo := ((i - 1) * BatchSize) + 1;
            EndNo := i * BatchSize;

            if i = BatchCount then
                EndNo := TotalRecords;

            GenerateBatchSync(StartNo, EndNo, i);
            Commit(); // Commit after each batch for better performance
        end;

        Window.Close();
        Message('Full dataset generated: %1 records completed.', TotalRecords);
    end;

    local procedure GenerateBatchSync(StartNo: Integer; EndNo: Integer; BatchNo: Integer)
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
        end;
    end;
}
