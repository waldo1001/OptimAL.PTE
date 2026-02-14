page 74305 "Perf Test Orders Part"
{
    PageType = ListPart;
    SourceTable = "Performance Test Order";
    Caption = 'Orders';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Orders)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the order number';
                    ApplicationArea = All;
                }

                field("Order Date"; Rec."Order Date")
                {
                    ToolTip = 'Specifies the order date';
                    ApplicationArea = All;
                }

                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the order amount';
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the order status';
                    ApplicationArea = All;
                }

                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the order description';
                    ApplicationArea = All;
                }
            }
        }
    }
}
