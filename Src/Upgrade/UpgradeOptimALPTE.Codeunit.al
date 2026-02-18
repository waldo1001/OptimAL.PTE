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
        DataTransfer: DataTransfer;
        Customer: Record "Performance Test Customer";
        Archive: Record "Perf. Test Customer Archive";
    begin
        Archive.Truncate(); // Clear target table before migration

        // Set up bulk transfer from Customer to Archive
        DataTransfer.SetTables(Database::"Performance Test Customer", Database::"Perf. Test Customer Archive");

        // Map fields from source to destination
        DataTransfer.AddFieldValue(Customer.FieldNo("No."), Archive.FieldNo("No."));
        DataTransfer.AddFieldValue(Customer.FieldNo(Name), Archive.FieldNo(Name));
        DataTransfer.AddFieldValue(Customer.FieldNo(Address), Archive.FieldNo(Address));
        DataTransfer.AddFieldValue(Customer.FieldNo(City), Archive.FieldNo(City));
        DataTransfer.AddFieldValue(Customer.FieldNo("Phone No."), Archive.FieldNo("Phone No."));

        // Set constant value for Status
        DataTransfer.AddConstantValue(Archive.Status::New, Archive.FieldNo(Status));

        // Execute bulk copy - ONE OPERATION FOR ALL RECORDS!
        DataTransfer.CopyRows();
    end;

    local procedure UpdateCustomerStatus()
    var
        DataTransfer: DataTransfer;
        Archive: Record "Perf. Test Customer Archive";
    begin
        // Set up bulk update on same table
        DataTransfer.SetTables(Database::"Perf. Test Customer Archive", Database::"Perf. Test Customer Archive");

        // Add filter to match only records we want to update
        DataTransfer.AddSourceFilter(Archive.FieldNo("No."), 'CUST-*');

        // Set constant value for Status field
        DataTransfer.AddConstantValue(Archive.Status::Active, Archive.FieldNo(Status));

        // Execute bulk update - ONE OPERATION FOR ALL RECORDS!
        DataTransfer.CopyFields();
    end;

}
