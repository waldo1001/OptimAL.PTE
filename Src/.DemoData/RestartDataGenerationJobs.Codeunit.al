codeunit 74300 "Restart Data Generation Jobs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LogInManagement", 'OnBeforeLogInEnd', '', false, false)]
    local procedure OnAfterCompanyOpen()
    begin
        RestartPendingDataGenerationJobs();
    end;

    local procedure RestartPendingDataGenerationJobs()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Customer: Record "Performance Test Customer";
    begin
        // Skip if data is already fully generated
        if Customer.Count() >= 25000 then
            exit;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Background Data Generator");
        JobQueueEntry.SetFilter(Status, '<>%1&<>%2',
            JobQueueEntry.Status::Finished,
            JobQueueEntry.Status::"In Process");

        if JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.FindSet(true);
        repeat
            JobQueueEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(JobQueueEntry."User ID"));
            JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime();
            JobQueueEntry.Status := JobQueueEntry.Status::Ready;
            JobQueueEntry.Modify();
        until JobQueueEntry.Next() = 0;
    end;
}
