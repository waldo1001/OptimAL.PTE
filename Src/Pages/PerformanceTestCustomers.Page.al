page 74301 "Performance Test Customers"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Performance Test Customer";
    CardPageId = "Performance Test Customer Card";
    Caption = 'Performance Test Customers';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer description.';
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies notes for the customer.';
                }
                field("Extended Address"; Rec."Extended Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the extended address details.';
                }
                field("Contact Information"; Rec."Contact Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies contact information.';
                }
                field("Shipping Instructions"; Rec."Shipping Instructions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies shipping instructions.';
                }
                field("Payment Terms Detail"; Rec."Payment Terms Detail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies payment terms details.';
                }
                field("Internal Comments"; Rec."Internal Comments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies internal comments.';
                }
                field("Compliance Notes"; Rec."Compliance Notes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies compliance notes.';
                }
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
                ToolTip = 'View orders for this customer';
                Image = OrderList;
                RunObject = page "Performance Test Orders";
                RunPageLink = "Customer No." = field("No.");
            }
        }
    }
}
