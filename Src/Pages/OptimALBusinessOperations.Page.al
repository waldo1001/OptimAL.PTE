page 74300 "OptimAL Business Operations"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'OptimAL Business Operations';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Business Operations Control Center';

                field(Instructions; InstructionsHtml)
                {
                    Caption = 'Instructions';
                    MultiLine = true;
                    Editable = false;
                    ShowCaption = false;
                    ExtendedDatatype = RichContent;
                }
            }

            group(Statistics)
            {
                Caption = 'Test Data Statistics';

                field(ArchiveCount; ArchiveCount)
                {
                    Caption = 'Archive Records';
                    ToolTip = 'Number of records in the Performance Test Customer Archive table';
                    Editable = false;
                    StyleExpr = true;
                }

                field(CustomerCount; CustomerCount)
                {
                    Caption = 'Customer Records';
                    ToolTip = 'Number of records in the Performance Test Customer table';
                    Editable = false;
                    StyleExpr = true;
                }

                field(OrderCount; OrderCount)
                {
                    Caption = 'Order Records';
                    ToolTip = 'Number of records in the Performance Test Order table';
                    Editable = false;
                    StyleExpr = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(CustomerOps)
            {
                Caption = 'Customer Management';

                action(ExportCustomers)
                {
                    Caption = 'Export Customer List';
                    ToolTip = 'Export customer data for external reporting system';
                    Image = Export;

                    trigger OnAction()
                    var
                        PerfMgr: Codeunit "Performance Measurement Mgr";
                        Exporter: Codeunit "Customer Data Export";
                        PerfTestCust: Record "Performance Test Customer";
                        MeasurementId: Guid;
                        Count: Integer;
                    begin
                        PerfTestCust.SelectLatestVersion(); // DO NOT REMOVE — needed for consistent demo results
                        // DO NOT REMOVE: Performance measurement is crucial for escape room validation
                        MeasurementId := PerfMgr.StartMeasurement('R4-EXPORT', 4, 1, 'Export Customers');
                        Count := Exporter.ExportCustomerList();
                        PerfMgr.StopMeasurement(MeasurementId);
                        // END DO NOT REMOVE
                        Message('Exported %1 customer records.', Count);
                    end;
                }

                action(ActiveCustomerReport)
                {
                    Caption = 'Active Customer Report';
                    ToolTip = 'Generate report of customers with active orders';
                    Image = Report;

                    trigger OnAction()
                    var
                        PerfMgr: Codeunit "Performance Measurement Mgr";
                        Reporter: Codeunit "Active Customer Report";
                        PerfTestCust: Record "Performance Test Customer";
                        MeasurementId: Guid;
                        Count: Integer;
                    begin
                        PerfTestCust.SelectLatestVersion(); // DO NOT REMOVE — needed for consistent demo results
                        // DO NOT REMOVE: Performance measurement is crucial for escape room validation
                        MeasurementId := PerfMgr.StartMeasurement('R4-ACTIVE', 4, 2, 'Active Customer Report');
                        Count := Reporter.GetActiveCustomerCount();
                        PerfMgr.StopMeasurement(MeasurementId);
                        // END DO NOT REMOVE
                        Message('Found %1 active customers.', Count);
                    end;
                }
            }

            group(ConcurrencyTesting)
            {
                Caption = 'Concurrency Testing';

                action(SimulateMultiUser)
                {
                    Caption = 'Simulate Multi-User Access';
                    ToolTip = 'Runs two concurrent-access tests: batch processor vs credit approval, and order validator vs credit approval. Reports blocking duration for each.';
                    Image = Workdays;

                    trigger OnAction()
                    var
                        SessionId: Integer;
                        SimulationStartedMsg: Label 'Multi-user access simulation started in the background.\The simulation takes approximately 30-60 seconds to complete.\\Click "View Simulation Results" afterwards to see the outcome.';
                    begin
                        StartSession(SessionId, Codeunit::"Concurrent Access Simulator");
                        Message(SimulationStartedMsg);
                    end;
                }
                action(ViewSimulationResults)
                {
                    Caption = 'View Simulation Results';
                    ToolTip = 'Shows the results of the last multi-user access simulation.';
                    Image = ViewDetails;

                    trigger OnAction()
                    var
                        Simulator: Codeunit "Concurrent Access Simulator";
                    begin
                        Simulator.ShowSimulationResults();
                    end;
                }
            }

            group(Analytics)
            {
                Caption = 'Analytics & Reporting';

                action(SalesAnalysis)
                {
                    Caption = 'Customer Sales Analysis';
                    ToolTip = 'Calculate total sales across all customers';
                    Image = AnalysisView;

                    trigger OnAction()
                    var
                        PerfMgr: Codeunit "Performance Measurement Mgr";
                        Analyzer: Codeunit "Customer Sales Analyzer";
                        PerfTestCust: Record "Performance Test Customer";
                        MeasurementId: Guid;
                        Total: Decimal;
                    begin
                        PerfTestCust.SelectLatestVersion(); // DO NOT REMOVE — needed for consistent demo results
                        // DO NOT REMOVE: Performance measurement is crucial for escape room validation
                        MeasurementId := PerfMgr.StartMeasurement('R5-SALES', 5, 2, 'Calculate Total Sales');
                        Total := Analyzer.CalculateTotalSales();
                        PerfMgr.StopMeasurement(MeasurementId);
                        // END DO NOT REMOVE
                        Message('Total Sales: %1', Total);
                    end;
                }

                action(RevenueCalculation)
                {
                    Caption = 'Revenue Report';
                    ToolTip = 'Calculate total revenue for financial reporting';
                    Image = Calculate;

                    trigger OnAction()
                    var
                        PerfMgr: Codeunit "Performance Measurement Mgr";
                        Calculator: Codeunit "Sales Revenue Calculator";
                        PerfTestCust: Record "Performance Test Customer";
                        MeasurementId: Guid;
                        Revenue: Decimal;
                    begin
                        PerfTestCust.SelectLatestVersion(); // DO NOT REMOVE — needed for consistent demo results
                        // DO NOT REMOVE: Performance measurement is crucial for escape room validation
                        MeasurementId := PerfMgr.StartMeasurement('R5-REVENUE', 5, 1, 'Calculate Revenue');
                        Revenue := Calculator.GetTotalRevenue();
                        PerfMgr.StopMeasurement(MeasurementId);
                        // END DO NOT REMOVE
                        Message('Total Revenue: %1', Revenue);
                    end;
                }

                action(CustomerOrderStats)
                {
                    Caption = 'Customer Order Report';
                    ToolTip = 'Build a report combining customer and order data';
                    Image = Statistics;

                    trigger OnAction()
                    var
                        PerfMgr: Codeunit "Performance Measurement Mgr";
                        Analytics: Codeunit "Customer Order Analytics";
                        PerfTestCust: Record "Performance Test Customer";
                        MeasurementId: Guid;
                        Count: Integer;
                    begin
                        PerfTestCust.SelectLatestVersion(); // DO NOT REMOVE — needed for consistent demo results
                        // DO NOT REMOVE: Performance measurement is crucial for escape room validation
                        MeasurementId := PerfMgr.StartMeasurement('R7-N+1', 7, 1, 'Customer Order Report');
                        Count := Analytics.BuildCustomerOrderReport();
                        PerfMgr.StopMeasurement(MeasurementId);
                        // END DO NOT REMOVE
                        Message('Report complete: %1 rows processed', Count);
                    end;
                }
            }

            group(OrderOps)
            {
                Caption = 'Order Processing';
            }

            group(DataMgmt)
            {
                Caption = 'Data Management';

                action(GenerateMoreTestData)
                {
                    Caption = 'Generate More Test Data';
                    ToolTip = 'Generate additional test data records to reach the 25,000 minimum required for performance testing. Runs in background via job queue entries.';
                    Image = CreateDocument;

                    trigger OnAction()
                    var
                        Customer: Record "Performance Test Customer";
                        JobQueueEntry: Record "Job Queue Entry";
                        CurrentCount: Integer;
                        TargetCount: Integer;
                        RecordsToGenerate: Integer;
                        BatchSize: Integer;
                        BatchCount: Integer;
                        StartNo: Integer;
                        EndNo: Integer;
                        i: Integer;
                        ConfirmQst: Label 'This will generate %1 additional records in background batches to reach 25,000 total.\\Continue?';
                        AlreadyEnoughMsg: Label 'You already have %1 Customer records, which exceeds the 25,000 minimum. No action needed.';
                        SuccessMsg: Label 'Created %1 background jobs to generate %2 records. This will take a few minutes. Refresh the page to see updated counts.';
                    begin
                        TargetCount := 25000;
                        CurrentCount := Customer.Count();

                        // Check if already have enough
                        if CurrentCount >= TargetCount then begin
                            Message(AlreadyEnoughMsg, CurrentCount);
                            exit;
                        end;

                        RecordsToGenerate := TargetCount - CurrentCount;

                        if not Confirm(ConfirmQst, false, RecordsToGenerate) then
                            exit;

                        // Create job queue entries for parallel generation
                        BatchCount := 10; // 10 parallel job queue entries
                        BatchSize := RecordsToGenerate div BatchCount;

                        for i := 1 to BatchCount do begin
                            StartNo := CurrentCount + ((i - 1) * BatchSize) + 1;
                            EndNo := CurrentCount + (i * BatchSize);

                            if i = BatchCount then
                                EndNo := TargetCount;

                            Clear(JobQueueEntry);
                            JobQueueEntry.Description := StrSubstNo('Generate test data batch %1 of %2', i, BatchCount);
                            JobQueueEntry."Maximum No. of Attempts to Run" := 2;
                            JobQueueEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(JobQueueEntry."User ID"));
                            JobQueueEntry.ScheduleJobQueueEntryForLater(Codeunit::"Background Data Generator", CurrentDateTime, '', Format(StartNo) + '|' + Format(EndNo));
                        end;

                        Message(SuccessMsg, BatchCount, RecordsToGenerate);
                        CalculateRecordCounts();
                    end;
                }

                action(DeleteAllTestData)
                {
                    Caption = 'Delete All Test Data';
                    ToolTip = 'Delete all performance test data (Customers, Archives, Orders). Use this to reset before reinstalling the app.';
                    Image = Delete;

                    trigger OnAction()
                    var
                        Archive: Record "Perf. Test Customer Archive";
                        Customer: Record "Performance Test Customer";
                        Order: Record "Performance Test Order";
                        ConfirmQst: Label 'This will delete ALL test data:\- %1 Customers\- %2 Archives\- %3 Orders\\Continue?';
                    begin
                        if not Confirm(ConfirmQst, false, Customer.Count(), Archive.Count(), Order.Count()) then
                            exit;

                        Order.DeleteAll();
                        Customer.DeleteAll();
                        Archive.DeleteAll();

                        CalculateRecordCounts();
                        Message('All test data deleted successfully.');
                    end;
                }

                action(ViewCustomers)
                {
                    Caption = 'View Test Customers';
                    ToolTip = 'Open the list of performance test customers';
                    Image = CustomerList;

                    trigger OnAction()
                    var
                        PerfTestCustomers: Page "Performance Test Customers";
                    begin
                        PerfTestCustomers.Run();
                    end;
                }

                action(ViewOrders)
                {
                    Caption = 'View Test Orders';
                    ToolTip = 'Open the list of performance test orders';
                    Image = OrderList;

                    trigger OnAction()
                    var
                        PerfTestOrders: Page "Performance Test Orders";
                    begin
                        PerfTestOrders.Run();
                    end;
                }

                action(ViewArchive)
                {
                    Caption = 'View Customer Archive';
                    ToolTip = 'Open the list of performance test customer archive records';
                    Image = DataEntry;

                    trigger OnAction()
                    var
                        ArchivePage: Page "Perf. Test Customer Archive";
                    begin
                        ArchivePage.Run();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        InstructionsHtml := GetInstructionsHtml();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalculateRecordCounts();
    end;

    local procedure GetInstructionsHtml(): Text
    begin
        exit(NavApp.GetResourceAsText('BusinessOperationsInstructions.html'));
    end;

    local procedure CalculateRecordCounts()
    var
        Archive: Record "Perf. Test Customer Archive";
        Customer: Record "Performance Test Customer";
        Order: Record "Performance Test Order";
    begin
        ArchiveCount := Archive.Count();
        CustomerCount := Customer.Count();
        OrderCount := Order.Count();
    end;

    var
        InstructionsHtml: Text;
        ArchiveCount: Integer;
        CustomerCount: Integer;
        OrderCount: Integer;
}
