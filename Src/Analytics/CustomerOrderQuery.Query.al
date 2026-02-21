query 74352 "Customer Order Report"
{
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Customer; "Performance Test Customer")
        {
            column(CustomerNo; "No.") { }
            column(CustomerName; Name) { }

            dataitem(Order; "Performance Test Order")
            {
                DataItemLink = "Customer No." = Customer."No.";
                column(OrderNo; "No.") { }
                column(OrderAmount; Amount) { }
                column(OrderDate; "Order Date") { }
            }
        }
    }
}
