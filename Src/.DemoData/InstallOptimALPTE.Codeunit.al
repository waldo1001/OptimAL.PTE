codeunit 74390 "Install OptimAL PTE"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        InstallTracker: Codeunit "PTE Install Tracker";
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);

        // Track installation in EscapeRoom1 framework (direct call)
        InstallTracker.RecordInstallation(Me.Id, Me.Name);

        // Schedule background data generation via job queue entries
        ScheduleBackgroundDataGeneration();
    end;

    local procedure ScheduleBackgroundDataGeneration()
    var
        Customer: Record "Performance Test Customer";
        JobQueueEntry: Record "Job Queue Entry";
        TotalRecords: Integer;
        BatchSize: Integer;
        BatchCount: Integer;
        StartNo: Integer;
        EndNo: Integer;
        i: Integer;
    begin
        TotalRecords := 25000;

        // Skip if data already exists
        if Customer.Count() >= TotalRecords then
            exit;

        BatchCount := 10; // 10 parallel job queue entries
        BatchSize := TotalRecords div BatchCount;

        // Create job queue entries for each batch
        for i := 1 to BatchCount do begin
            StartNo := ((i - 1) * BatchSize) + 1;
            EndNo := i * BatchSize;

            if i = BatchCount then
                EndNo := TotalRecords;

            Clear(JobQueueEntry);
            JobQueueEntry.Init();
            JobQueueEntry.ID := CreateGuid();
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry."Object ID to Run" := Codeunit::"Background Data Generator";
            JobQueueEntry.Description := StrSubstNo('Generate test data batch %1 of %2', i, BatchCount);
            JobQueueEntry."Parameter String" := Format(StartNo) + '|' + Format(EndNo);
            JobQueueEntry."Maximum No. of Attempts to Run" := 2;
            JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime();
            JobQueueEntry.Status := JobQueueEntry.Status::"On Hold"; // Real user will start it via OnBeforeLogInEnd
            JobQueueEntry.Insert(true);
        end;
    end;

}
