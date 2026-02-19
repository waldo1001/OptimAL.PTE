codeunit 74347 "Order Data Audit Hook"
{
    // This codeunit is outside your control - it belongs to a different extension.
    // It subscribes to OnBeforeValidateOrderData to do its own processing on Customer records
    // just before the validation runs. As a side effect, it leaves locks on those records
    // that are still held when Customer Order Validator starts reading the same table.

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Order Validator", 'OnBeforeValidateOrderData', '', false, false)]
    local procedure AuditHook_LockCustomerForSnapshot(var Customer: Record "Performance Test Customer")
    begin
        // Sets an update-lock hint on the record variable passed from Customer Order Validator.
        // When ValidateOrderData() calls FindSet() afterwards, it will try to acquire UpdLocks
        // on every row - blocking anyone else trying to write to those same records.
        Customer.FindSet(true); // true = for update -> applies update locks to the record variable, which is not released until the end of the transaction in Customer Order Validator.
    end;
}
