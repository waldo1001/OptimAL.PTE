permissionset 74390 "OptimAL PTE"
{
    Caption = 'OptimAL PTE';
    Assignable = true;

    Permissions =
        table "Performance Test Customer" = X,
        tabledata "Performance Test Customer" = RMID,
        table "Perf. Test Customer Archive" = X,
        tabledata "Perf. Test Customer Archive" = RMID,
        table "Performance Test Order" = X,
        tabledata "Performance Test Order" = RMID;
}
