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

    trigger OnRun()
    begin
        RunSimulation();
    end;

    procedure RunSimulation()
    var
        CommitBlockMs: Integer;
        ReadUncommittedBlockMs: Integer;
        ReadUncommittedFixed: Boolean;
        PerfMgr: Codeunit "Performance Measurement Mgr";
        MeasurementId: Guid;
    begin
        BlockingThresholdMs := 3000;
        FixedThresholdMs := 1000;

        // Reset data so every run starts from a known state
        ResetTestData();

        // --- Test 1: Commit lesson ---
        MeasurementId := PerfMgr.StartMeasurement('R6-CONCURRENT', 6, 0, 'Concurrent Access Test');
        CommitBlockMs := RunCommitTest();
        PerfMgr.StopMeasurement(MeasurementId);

        // --- Test 2: ReadUncommitted lesson ---
        ReadUncommittedBlockMs := RunReadUncommittedTest(ReadUncommittedFixed);
    end;

    local procedure RunCommitTest() BlockedMs: Integer
    var
        BackgroundSessionId: Integer;
        StartTime: DateTime;
        PerfMgr: Codeunit "Performance Measurement Mgr";
        MeasurementId: Guid;
        CreditApprovalSucceeded: Boolean;
    begin
        // Start Batch Order Processor in background - it holds X-locks with no Commit
        StartSession(BackgroundSessionId, Codeunit::"Batch Order Processor");
        Sleep(1500); // Let background acquire locks

        // Try credit approval - without Commit() in the batch, this will block until lock timeout
        StartTime := CurrentDateTime();
        MeasurementId := PerfMgr.StartMeasurement('R6-CONCURRENT-COMMIT', 6, 1, 'Credit Approval vs Batch');
        CreditApprovalSucceeded := TryApproveCreditForNextCustomer();
        PerfMgr.StopMeasurement(MeasurementId);
        BlockedMs := CurrentDateTime() - StartTime;

        StopSession(BackgroundSessionId);

        // With Commit() added to the batch, credit approval succeeds quickly
        if CreditApprovalSucceeded and (BlockedMs < FixedThresholdMs) then begin
            MeasurementId := PerfMgr.StartMeasurement('R6-COMMIT-FIXED', 6, 1, 'Commit Fix Verified');
            PerfMgr.StopMeasurement(MeasurementId);
        end;
    end;

    [TryFunction]
    local procedure TryApproveCreditForNextCustomer()
    var
        CreditApproval: Codeunit "Customer Credit Approval";
    begin
        CreditApproval.ApproveCreditForNextCustomer();
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

    local procedure ResetTestData()
    var
        Customer: Record "Performance Test Customer";
        PerfMeasurement: Record "Performance Measurement";
    begin
        // Reset all customers to New so every test run starts from a known state.
        // Without this, a previous batch run sets all records to Completed, and the
        // credit approval finds nothing to approve - making Test 1 look fixed when it isn't.
        Customer.ModifyAll(Status, Customer.Status::New);

        // Clean up old measurements from previous runs
        PerfMeasurement.SetRange("Room No.", 6);
        PerfMeasurement.DeleteAll();

        Commit();
    end;

    procedure ShowSimulationResults()
    var
        PerfMgr: Codeunit "Performance Measurement Mgr";
        CommitMeasurement: Record "Performance Measurement";
        ReadUncommittedMeasurement: Record "Performance Measurement";
        ConcurrentMeasurement: Record "Performance Measurement";
        CommitFixed: Boolean;
        ReadUncommittedFixed: Boolean;
        CommitBlockMs: Integer;
        ReadUncommittedBlockMs: Integer;
        ResultLbl: Label 'Concurrent Access Simulation Results\\\STATUS: %5\\\Test 1 - Batch Processor vs Credit Approval:\  Credit approval blocked for: %1 ms\  %2\\Test 2 - Lock Holder vs Order Validator:\  %3\  %4\\Check Performance Measurements for details.', Comment = '%1 = commit block ms, %2 = commit result, %3 = readuncommitted time, %4 = readuncommitted result, %5 = status';
        BlockedLbl: Label 'BLOCKED - The batch holds locks the entire time; add Commit() to release them periodically';
        CommitFixedLbl: Label 'FIXED - Commit() releases locks between intervals';
        LockedLbl: Label 'BLOCKED - lock timeout: the subscriber left UpdLocks that conflict with another session';
        ReadUncommittedFixedLbl: Label 'FIXED - validator completed: ReadIsolation bypassed the subscriber locks';
        NoResultsLbl: Label 'No simulation results found yet.\Run "Simulate Multi-User Access" first and wait approximately 30-60 seconds for it to complete.';
        InProgressLbl: Label 'SIMULATION IN PROGRESS - Please wait...';
        CompletedLbl: Label 'COMPLETED';
        CommitResult: Text;
        ReadUncommittedTimeText: Text;
        ReadUncommittedResult: Text;
        StatusText: Text;
    begin
        if not PerfMgr.GetLastMeasurement('R6-CONCURRENT-COMMIT', CommitMeasurement) then begin
            Message(NoResultsLbl);
            exit;
        end;

        // Check if simulation is still in progress by looking at the main concurrent measurement
        // If it has 0ms duration, it means it was started but not yet stopped
        if PerfMgr.GetLastMeasurement('R6-CONCURRENT', ConcurrentMeasurement) then begin
            if ConcurrentMeasurement."Duration (ms)" = 0 then begin
                StatusText := InProgressLbl;
            end else begin
                StatusText := CompletedLbl;
            end;
        end else begin
            // If the main measurement doesn't exist yet, but commit measurement does,
            // it means we're in the middle of the simulation
            StatusText := InProgressLbl;
        end;

        CommitBlockMs := CommitMeasurement."Duration (ms)";
        CommitFixed := PerfMgr.MeasurementExistsAfter('R6-COMMIT-FIXED', CommitMeasurement."Start DateTime" - 60000);

        if CommitFixed then
            CommitResult := CommitFixedLbl
        else
            CommitResult := BlockedLbl;

        ReadUncommittedFixed := PerfMgr.MeasurementExistsAfter('R6-READUNCOMMITTED-FIXED', CommitMeasurement."Start DateTime" - 60000);

        if PerfMgr.GetLastMeasurement('R6-CONCURRENT-READUNCOMMITTED', ReadUncommittedMeasurement) then
            ReadUncommittedBlockMs := ReadUncommittedMeasurement."Duration (ms)";

        if ReadUncommittedFixed then begin
            ReadUncommittedTimeText := 'Completed in ' + Format(ReadUncommittedBlockMs) + ' ms';
            ReadUncommittedResult := ReadUncommittedFixedLbl;
        end else begin
            ReadUncommittedTimeText := 'Lock timeout after ' + Format(ReadUncommittedBlockMs) + ' ms';
            ReadUncommittedResult := LockedLbl;
        end;

        Message(StrSubstNo(ResultLbl, CommitBlockMs, CommitResult, ReadUncommittedTimeText, ReadUncommittedResult, StatusText));
    end;
}
