page 74303 "Performance Test Orders"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Performance Test Order";
    Caption = 'Performance Test Orders';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order number.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number.';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order date.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order amount.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order description.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order status.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Customer)
            {
                ApplicationArea = All;
                Caption = 'Customer';
                ToolTip = 'View the customer for this order';
                Image = Customer;
                RunObject = page "Performance Test Customer Card";
                RunPageLink = "No." = field("Customer No.");
            }
        }
    }
}
