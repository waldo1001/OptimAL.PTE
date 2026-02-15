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
                FillLargeTextFields(DataSource, i);
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
                FillLargeTextFields(Customer, i);
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

    local procedure FillLargeTextFields(var Customer: Record "Performance Test Customer"; i: Integer)
    begin
        Customer.Description := PadStr(StrSubstNo('Customer %1 is a valued business partner specializing in various product lines and services across multiple regions. Established operations include wholesale distribution, retail partnerships, and direct-to-consumer channels with comprehensive logistics support.', i), 2048, ' ');
        Customer.Notes := PadStr(StrSubstNo('Account %1 notes: Regular quarterly reviews scheduled. Credit limit approved at standard tier. Preferred communication method is email. Key contacts updated annually. Compliance documentation on file and verified.', i), 2048, ' ');
        Customer."Extended Address" := PadStr(StrSubstNo('Building %1, Suite %2, Industrial Park Zone %3, Regional Distribution Center, Warehouse Complex North Wing, Loading Dock B, Floor 3', i, i mod 500, i mod 50), 2048, ' ');
        Customer."Contact Information" := PadStr(StrSubstNo('Primary: John Smith (+1-555-%1). Secondary: Jane Doe (+1-555-%2). Emergency: Operations Center (+1-555-%3). Fax: +1-555-%4. Email: contact%1@example.com', Format(i, 0, '<Integer,4><Filler Character,0>'), Format(i + 1, 0, '<Integer,4><Filler Character,0>'), Format(i + 2, 0, '<Integer,4><Filler Character,0>'), Format(i + 3, 0, '<Integer,4><Filler Character,0>')), 2048, ' ');
        Customer."Shipping Instructions" := PadStr(StrSubstNo('Delivery for account %1: Use north entrance. Require signature on delivery. Fragile items must be marked. Temperature-controlled storage required for perishable goods. Weekend deliveries accepted with prior arrangement. Contact warehouse manager before arrival.', i), 2048, ' ');
        Customer."Payment Terms Detail" := PadStr(StrSubstNo('Account %1 payment terms: Net 30 standard. Early payment discount 2/10. Wire transfer preferred for amounts over 10000. Purchase order required for all transactions. Monthly statement reconciliation mandatory. Credit terms reviewed annually.', i), 2048, ' ');
        Customer."Internal Comments" := PadStr(StrSubstNo('Internal ref %1: Account managed by regional team. Annual revenue target set during Q1 planning. Customer satisfaction score tracked quarterly. Escalation path through regional manager. SLA compliance monitored monthly. Historical performance data archived.', i), 2048, ' ');
        Customer."Compliance Notes" := PadStr(StrSubstNo('Compliance record %1: All regulatory requirements verified. Tax exemption certificate on file (expires annually). Export compliance classification reviewed. Data protection agreement signed. Industry-specific certifications validated. Audit trail maintained for all transactions.', i), 2048, ' ');
    end;

    local procedure FillLargeTextFields(var DataSource: Record "Performance Test Data Source"; i: Integer)
    begin
        DataSource.Description := PadStr(StrSubstNo('Customer %1 is a valued business partner specializing in various product lines and services across multiple regions. Established operations include wholesale distribution, retail partnerships, and direct-to-consumer channels with comprehensive logistics support.', i), 2048, ' ');
        DataSource.Notes := PadStr(StrSubstNo('Account %1 notes: Regular quarterly reviews scheduled. Credit limit approved at standard tier. Preferred communication method is email. Key contacts updated annually. Compliance documentation on file and verified.', i), 2048, ' ');
        DataSource."Extended Address" := PadStr(StrSubstNo('Building %1, Suite %2, Industrial Park Zone %3, Regional Distribution Center, Warehouse Complex North Wing, Loading Dock B, Floor 3', i, i mod 500, i mod 50), 2048, ' ');
        DataSource."Contact Information" := PadStr(StrSubstNo('Primary: John Smith (+1-555-%1). Secondary: Jane Doe (+1-555-%2). Emergency: Operations Center (+1-555-%3). Fax: +1-555-%4. Email: contact%1@example.com', Format(i, 0, '<Integer,4><Filler Character,0>'), Format(i + 1, 0, '<Integer,4><Filler Character,0>'), Format(i + 2, 0, '<Integer,4><Filler Character,0>'), Format(i + 3, 0, '<Integer,4><Filler Character,0>')), 2048, ' ');
        DataSource."Shipping Instructions" := PadStr(StrSubstNo('Delivery for account %1: Use north entrance. Require signature on delivery. Fragile items must be marked. Temperature-controlled storage required for perishable goods. Weekend deliveries accepted with prior arrangement. Contact warehouse manager before arrival.', i), 2048, ' ');
        DataSource."Payment Terms Detail" := PadStr(StrSubstNo('Account %1 payment terms: Net 30 standard. Early payment discount 2/10. Wire transfer preferred for amounts over 10000. Purchase order required for all transactions. Monthly statement reconciliation mandatory. Credit terms reviewed annually.', i), 2048, ' ');
        DataSource."Internal Comments" := PadStr(StrSubstNo('Internal ref %1: Account managed by regional team. Annual revenue target set during Q1 planning. Customer satisfaction score tracked quarterly. Escalation path through regional manager. SLA compliance monitored monthly. Historical performance data archived.', i), 2048, ' ');
        DataSource."Compliance Notes" := PadStr(StrSubstNo('Compliance record %1: All regulatory requirements verified. Tax exemption certificate on file (expires annually). Export compliance classification reviewed. Data protection agreement signed. Industry-specific certifications validated. Audit trail maintained for all transactions.', i), 2048, ' ');
    end;
}
