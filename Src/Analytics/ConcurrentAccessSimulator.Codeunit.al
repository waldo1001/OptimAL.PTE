codeunit 74346 "Concurrent Access Simulator"
{
    // Runs two concurrent-access tests to demonstrate and validate locking fixes.
    //
    // Test 1 - Commit lesson:
    //   Background: Batch Order Processor (holds X-locks per record, no Commit)
    //   Foreground: Customer Credit Approval (tries to Modify one Customer -> blocked)
    //   Fix: Add Commit() every N records in ProcessPendingOrders()
    //
    // Test 2 - ReadUncommitted lesson:
    //   Background: Customer Order Validator (LockTable -> UpdLocks on all rows)
    //   Foreground: Batch Order Processor (tries FindSet(true) -> blocked by UpdLocks)
    //   Fix: Remove LockTable() from ValidateOrderData()

    var
        BlockingThresholdMs: Integer;        // ms - above this = "blocked"
        FixedThresholdMs: Integer;           // ms - below this = "fixed"

    procedure RunSimulation()
    var
        CommitBlockMs: Integer;
        ReadUncommittedBlockMs: Integer;
        ResultMsg: Text;
        PerfMgr: Codeunit "Performance Measurement Mgr";
        MeasurementId: Guid;
    begin
        BlockingThresholdMs := 3000;
        FixedThresholdMs := 1000;

        // --- Test 1: Commit lesson ---
        MeasurementId := PerfMgr.StartMeasurement('R6-CONCURRENT', 6, 0, 'Concurrent Access Test');
        CommitBlockMs := RunCommitTest();
        PerfMgr.StopMeasurement(MeasurementId);

        // --- Test 2: ReadUncommitted lesson ---
        ReadUncommittedBlockMs := RunReadUncommittedTest();

        // Build result message
        ResultMsg := BuildResultMessage(CommitBlockMs, ReadUncommittedBlockMs);
        Message(ResultMsg);
    end;

    local procedure RunCommitTest() BlockedMs: Integer
    var
        BackgroundSessionId: Integer;
        StartTime: DateTime;
        CreditApproval: Codeunit "Customer Credit Approval";
        PerfMgr: Codeunit "Performance Measurement Mgr";
        MeasurementId: Guid;
    begin
        // Start Batch Order Processor in background - it will hold X-locks per record with no Commit
        StartSession(BackgroundSessionId, Codeunit::"Batch Order Processor");

        // Wait for background to acquire its first locks
        Sleep(1500);

        // Try credit approval in foreground - should be blocked by batch's X-locks
        StartTime := CurrentDateTime();
        MeasurementId := PerfMgr.StartMeasurement('R6-CONCURRENT-COMMIT', 6, 1, 'Credit Approval vs Batch');
        CreditApproval.ApproveCreditForNextCustomer();
        PerfMgr.StopMeasurement(MeasurementId);
        BlockedMs := CurrentDateTime() - StartTime;

        // Write fixed measurement if credit approval was fast (Commit() added to batch)
        if BlockedMs < FixedThresholdMs then begin
            MeasurementId := PerfMgr.StartMeasurement('R6-COMMIT-FIXED', 6, 1, 'Commit Fix Verified');
            PerfMgr.StopMeasurement(MeasurementId);
        end;

        StopSession(BackgroundSessionId);
    end;

    local procedure RunReadUncommittedTest() BlockedMs: Integer
    var
        BackgroundSessionId: Integer;
        StartTime: DateTime;
        Processor: Codeunit "Batch Order Processor";
        PerfMgr: Codeunit "Performance Measurement Mgr";
        MeasurementId: Guid;
    begin
        // Start Customer Order Validator in background - LockTable() will UpdLock all Customer rows
        StartSession(BackgroundSessionId, Codeunit::"Customer Order Validator");

        // Wait for background to acquire its locks via LockTable()
        Sleep(1500);

        // Try to FindSet(true) on Customers in foreground - blocked by validator's UpdLocks
        StartTime := CurrentDateTime();
        MeasurementId := PerfMgr.StartMeasurement('R6-CONCURRENT-READUNCOMMITTED', 6, 2, 'Batch vs Validator');
        Processor.ProcessPendingOrders();
        PerfMgr.StopMeasurement(MeasurementId);
        BlockedMs := CurrentDateTime() - StartTime;

        // Write fixed measurement if batch could start immediately (LockTable() removed from validator)
        if BlockedMs < FixedThresholdMs then begin
            MeasurementId := PerfMgr.StartMeasurement('R6-READUNCOMMITTED-FIXED', 6, 2, 'ReadUncommitted Fix Verified');
            PerfMgr.StopMeasurement(MeasurementId);
        end;

        StopSession(BackgroundSessionId);
    end;

    local procedure BuildResultMessage(CommitBlockMs: Integer; ReadUncommittedBlockMs: Integer): Text
    var
        ResultLbl: Label 'Concurrent Access Simulation Results\\\Test 1 - Batch Processor vs Credit Approval:\  Credit approval blocked for: %1 ms\  %2\\Test 2 - Order Validator vs Batch Processor:\  Batch processor blocked for: %3 ms\  %4\\Check Performance Measurements for details.', Comment = '%1 = commit block ms, %2 = commit result, %3 = readuncommitted block ms, %4 = readuncommitted result';
        BlockedLbl: Label 'BLOCKED - Add Commit() to the Batch Order Processor';
        CommitFixedLbl: Label 'FIXED - Commit() releases locks periodically';
        LockedLbl: Label 'BLOCKED - Remove LockTable() from the Customer Order Validator';
        ReadUncommittedFixedLbl: Label 'FIXED - No unnecessary locks from the validator';
        CommitResult: Text;
        ReadUncommittedResult: Text;
    begin
        if CommitBlockMs >= BlockingThresholdMs then
            CommitResult := BlockedLbl
        else
            CommitResult := CommitFixedLbl;

        if ReadUncommittedBlockMs >= BlockingThresholdMs then
            ReadUncommittedResult := LockedLbl
        else
            ReadUncommittedResult := ReadUncommittedFixedLbl;

        exit(StrSubstNo(ResultLbl, CommitBlockMs, CommitResult, ReadUncommittedBlockMs, ReadUncommittedResult));
    end;
}
