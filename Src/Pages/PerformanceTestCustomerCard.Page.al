page 74302 "Performance Test Customer Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Performance Test Customer";
    Caption = 'Performance Test Customer Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer address.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer city.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer phone number.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer status.';
                }
            }
            group(Statistics)
            {
                Caption = 'Statistics';

                field("Order Count"; Rec."Order Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of orders for this customer.';
                }
                field("Total Sales"; Rec."Total Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total sales amount for this customer.';
                }
            }
        }
        area(FactBoxes)
        {
            part(OrderList; "Perf Test Orders Part")
            {
                ApplicationArea = All;
                SubPageLink = "Customer No." = field("No.");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Orders)
            {
                ApplicationArea = All;
                Caption = 'Orders';
                ToolTip = 'View all orders for this customer';
                Image = OrderList;
                RunObject = page "Performance Test Orders";
                RunPageLink = "Customer No." = field("No.");
            }
        }
    }
}
