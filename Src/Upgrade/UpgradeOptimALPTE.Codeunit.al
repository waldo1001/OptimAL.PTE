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
        DataSource: Record "Performance Test Data Source";
        Customer: Record "Performance Test Customer";
    begin
        // Migrating from legacy system during upgrade
        if not DataSource.FindSet() then
            exit;

        Customer.DeleteAll(); // Clear target table before migration

        repeat
            Customer.Init();
            Customer."No." := DataSource."No."; // Direct copy - no transformation
            Customer.Name := DataSource.Name;
            Customer.Address := DataSource.Address;
            Customer.City := DataSource.City;
            Customer."Phone No." := DataSource."Phone No.";
            Customer.Status := Customer.Status::New;
            Customer.Insert();
        until DataSource.Next() = 0;
    end;

    local procedure UpdateCustomerStatus()
    var
        Customer: Record "Performance Test Customer";
    begin
        // Updating field values after migration
        Customer.SetFilter("No.", 'CUST-*');
        if not Customer.FindSet(true) then
            exit;

        repeat
            Customer.Status := Customer.Status::Active;
            Customer.Modify();
        until Customer.Next() = 0;
    end;
}
