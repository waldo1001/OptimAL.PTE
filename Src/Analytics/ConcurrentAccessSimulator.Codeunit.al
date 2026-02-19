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
    //   Background: Batch Order Processor (holds X-locks per record, no Commit)
    //   Foreground: Customer Order Validator
    //     - A subscriber calls LockTable() on the Customer var via the OnBefore event
    //     - FindSet() then tries UpdLocks -> blocked by batch X-locks
    //   Fix: Set ReadIsolation(ReadUncommitted) in ValidateOrderData() after the event

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
        Validator: Codeunit "Customer Order Validator";
        PerfMgr: Codeunit "Performance Measurement Mgr";
        MeasurementId: Guid;
        IssueCount: Integer;
    begin
        // Start Batch Order Processor in background - it will hold X-locks per record with no Commit
        StartSession(BackgroundSessionId, Codeunit::"Batch Order Processor");

        // Wait for background to acquire its first locks
        Sleep(1500);

        // Run Customer Order Validator in foreground:
        // - Subscriber sets LockTable() on the Customer var via the OnBefore event
        // - FindSet() then tries UpdLocks -> blocked by batch X-locks
        // - With ReadIsolation(ReadUncommitted) set after the event, FindSet bypasses all locks
        StartTime := CurrentDateTime();
        MeasurementId := PerfMgr.StartMeasurement('R6-CONCURRENT-READUNCOMMITTED', 6, 2, 'Validator vs Batch');
        IssueCount := Validator.ValidateOrderData();
        PerfMgr.StopMeasurement(MeasurementId);
        BlockedMs := CurrentDateTime() - StartTime;

        // Write fixed measurement if validator completed quickly despite batch holding X-locks
        if BlockedMs < FixedThresholdMs then begin
            MeasurementId := PerfMgr.StartMeasurement('R6-READUNCOMMITTED-FIXED', 6, 2, 'ReadUncommitted Fix Verified');
            PerfMgr.StopMeasurement(MeasurementId);
        end;

        StopSession(BackgroundSessionId);
    end;

    local procedure BuildResultMessage(CommitBlockMs: Integer; ReadUncommittedBlockMs: Integer): Text
    var
        ResultLbl: Label 'Concurrent Access Simulation Results\\\Test 1 - Batch Processor vs Credit Approval:\  Credit approval blocked for: %1 ms\  %2\\Test 2 - Batch Processor vs Order Validator:\  Order validator blocked for: %3 ms\  %4\\Check Performance Measurements for details.', Comment = '%1 = commit block ms, %2 = commit result, %3 = readuncommitted block ms, %4 = readuncommitted result';
        BlockedLbl: Label 'BLOCKED - The batch holds locks; add Commit() to release them periodically';
        CommitFixedLbl: Label 'FIXED - Commit() releases locks between intervals';
        LockedLbl: Label 'BLOCKED - A subscriber left UpdLocks; the validator cannot read past them';
        ReadUncommittedFixedLbl: Label 'FIXED - ReadIsolation allows the validator to read past existing locks';
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
