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
        DataSource: Record "Performance Test Data Source";
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
        if DataSource.Count() >= TotalRecords then
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
            JobQueueEntry.Description := StrSubstNo('Generate test data batch %1 of %2', i, BatchCount);
            JobQueueEntry."Maximum No. of Attempts to Run" := 2;
            JobQueueEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(JobQueueEntry."User ID"));
            JobQueueEntry.ScheduleJobQueueEntryForLater(Codeunit::"Background Data Generator", CurrentDateTime, '', Format(StartNo) + '|' + Format(EndNo));
        end;
    end;

}
