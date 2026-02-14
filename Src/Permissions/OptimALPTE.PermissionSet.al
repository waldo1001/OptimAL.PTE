permissionset 74390 "OptimAL PTE"
{
    Caption = 'OptimAL PTE';
    Assignable = true;

    Permissions =
        table "Performance Test Customer" = X,
        tabledata "Performance Test Customer" = RMID,
        table "Performance Test Data Source" = X,
        tabledata "Performance Test Data Source" = RMID,
        table "Performance Test Order" = X,
        tabledata "Performance Test Order" = RMID;
}
