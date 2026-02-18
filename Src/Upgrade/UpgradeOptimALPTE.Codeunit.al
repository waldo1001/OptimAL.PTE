codeunit 74391 "Upgrade OptimAL PTE"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        PerfMgr: Codeunit "Performance Measurement Mgr";
        InstallTracker: Codeunit "PTE Install Tracker";
        MeasurementId: Guid;
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);

        // Track upgrade in EscapeRoom1 framework (direct call)
        InstallTracker.RecordUpgrade(Me.Id, Me.Name);

        // DO NOT REMOVE: Performance measurement is crucial for escape room baseline
        // Start performance measurement (direct call - replaces OnBeforeDataMigration event)
        MeasurementId := PerfMgr.StartMeasurement('R1-BASELINE-UPGRADE', 1, 1, 'Upgrade Data Migration');

        // Migrate customer data from source table
        MigrateCustomerData();

        // Update customer status after migration
        UpdateCustomerStatus();

        // Stop measurement (direct call - replaces OnAfterDataMigration event)
        PerfMgr.StopMeasurement(MeasurementId);
        // END DO NOT REMOVE
    end;

    local procedure MigrateCustomerData()
    var
        Customer: Record "Performance Test Customer";
        Archive: Record "Perf. Test Customer Archive";
    begin
        // Archiving customer data during upgrade
        // Only load the fields we actually copy - ignore the large text fields
        Customer.SetLoadFields("No.", Name, Address, City, "Phone No.");
        if not Customer.FindSet() then
            exit;

        Archive.Truncate(); // Clear target table before migration

        repeat
            Archive.Init();
            Archive."No." := Customer."No."; // Direct copy - no transformation
            Archive.Name := Customer.Name;
            Archive.Address := Customer.Address;
            Archive.City := Customer.City;
            Archive."Phone No." := Customer."Phone No.";
            Archive.Status := Archive.Status::New;
            Archive.Insert();
        until Customer.Next() = 0;
    end;

    local procedure UpdateCustomerStatus()
    var
        Archive: Record "Perf. Test Customer Archive";
    begin
        // Updating field values after migration
        Archive.SetLoadFields(Status);
        Archive.SetFilter("No.", 'CUST-*');
        if not Archive.FindSet(true) then
            exit;

        repeat
            Archive.Status := Archive.Status::Active;
            Archive.Modify();
        until Archive.Next() = 0;
    end;

}
