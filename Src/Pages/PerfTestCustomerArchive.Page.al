page 74304 "Perf. Test Customer Archive"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Perf. Test Customer Archive";
    Caption = 'Performance Test Customer Archive';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the data source number.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the data source name.';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the address.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the phone number.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies notes.';
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
}
