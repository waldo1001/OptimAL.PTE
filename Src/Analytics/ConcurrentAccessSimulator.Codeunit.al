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
    //   Background: Customer Lock Holder (holds U-locks on all Customer rows for 20 seconds)
    //   Foreground: Customer Order Validator
    //     - AuditHook calls LockTable() on the Customer var via OnBeforeValidateOrderData
    //     - FindSet() then tries U-locks -> conflicts with Lock Holder's U-locks -> lock timeout
    //   Fix: Set ReadIsolation(ReadUncommitted) in ValidateOrderData() after the event call

    var
        BlockingThresholdMs: Integer;        // ms - above this = "blocked"
        FixedThresholdMs: Integer;           // ms - below this = "fixed"

    procedure RunSimulation()
    var
        CommitBlockMs: Integer;
        ReadUncommittedBlockMs: Integer;
        ReadUncommittedFixed: Boolean;
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
        ReadUncommittedBlockMs := RunReadUncommittedTest(ReadUncommittedFixed);

        // Build result message
        ResultMsg := BuildResultMessage(CommitBlockMs, ReadUncommittedBlockMs, ReadUncommittedFixed);
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

    local procedure RunReadUncommittedTest(var ValidatorFixed: Boolean) BlockedMs: Integer
    var
        BackgroundSessionId: Integer;
        StartTime: DateTime;
        PerfMgr: Codeunit "Performance Measurement Mgr";
        MeasurementId: Guid;
        IssueCount: Integer;
    begin
        // Start lock holder in background - holds U-locks on all Customer rows
        StartSession(BackgroundSessionId, Codeunit::"Customer Lock Holder");

        // Wait for background to acquire its locks
        Sleep(1500);

        // Run validator in foreground:
        // Without fix: AuditHook sets LockTable() hint -> FindSet() tries U-locks
        //              -> conflicts with Lock Holder's U-locks -> lock timeout
        // With fix:    ReadIsolation(ReadUncommitted) overrides the hint -> reads freely
        StartTime := CurrentDateTime();
        MeasurementId := PerfMgr.StartMeasurement('R6-CONCURRENT-READUNCOMMITTED', 6, 2, 'Validator vs Lock Holder');
        ValidatorFixed := TryRunValidator(IssueCount);
        PerfMgr.StopMeasurement(MeasurementId);
        BlockedMs := CurrentDateTime() - StartTime;

        if ValidatorFixed then begin
            MeasurementId := PerfMgr.StartMeasurement('R6-READUNCOMMITTED-FIXED', 6, 2, 'ReadUncommitted Fix Verified');
            PerfMgr.StopMeasurement(MeasurementId);
        end;

        StopSession(BackgroundSessionId);
    end;

    [TryFunction]
    local procedure TryRunValidator(var IssueCount: Integer)
    var
        Validator: Codeunit "Customer Order Validator";
    begin
        IssueCount := Validator.ValidateOrderData();
    end;

    local procedure BuildResultMessage(CommitBlockMs: Integer; ReadUncommittedBlockMs: Integer; ReadUncommittedFixed: Boolean): Text
    var
        ResultLbl: Label 'Concurrent Access Simulation Results\\\Test 1 - Batch Processor vs Credit Approval:\  Credit approval blocked for: %1 ms\  %2\\Test 2 - Lock Holder vs Order Validator:\  %3\  %4\\Check Performance Measurements for details.', Comment = '%1 = commit block ms, %2 = commit result, %3 = readuncommitted time, %4 = readuncommitted result';
        BlockedLbl: Label 'BLOCKED - The batch holds locks; add Commit() to release them periodically';
        CommitFixedLbl: Label 'FIXED - Commit() releases locks between intervals';
        LockedLbl: Label 'BLOCKED - lock timeout: the subscriber left UpdLocks, the validator could not read';
        ReadUncommittedFixedLbl: Label 'FIXED - validator completed: ReadIsolation bypassed the subscriber locks';
        CommitResult: Text;
        ReadUncommittedResult: Text;
        ReadUncommittedTimeText: Text;
    begin
        if CommitBlockMs >= BlockingThresholdMs then
            CommitResult := BlockedLbl
        else
            CommitResult := CommitFixedLbl;

        if ReadUncommittedFixed then begin
            ReadUncommittedTimeText := 'Completed in ' + Format(ReadUncommittedBlockMs) + ' ms';
            ReadUncommittedResult := ReadUncommittedFixedLbl;
        end else begin
            ReadUncommittedTimeText := 'Lock timeout after ' + Format(ReadUncommittedBlockMs) + ' ms';
            ReadUncommittedResult := LockedLbl;
        end;

        exit(StrSubstNo(ResultLbl, CommitBlockMs, CommitResult, ReadUncommittedTimeText, ReadUncommittedResult));
    end;
}
