table 74300 "Performance Test Customer"
{
    DataClassification = CustomerContent;
    Caption = 'Performance Test Customer';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(4; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(5; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(6; "Total Sales"; Decimal)
        {
            Caption = 'Total Sales';
            // Intentionally NO SIFT key for Room 5
            FieldClass = FlowField;
            CalcFormula = Sum("Performance Test Order".Amount where("Customer No." = field("No.")));
            Editable = false;
        }
        field(7; "Order Count"; Integer)
        {
            Caption = 'Order Count';
            // Intentionally NO SIFT key for Room 5
            FieldClass = FlowField;
            CalcFormula = Count("Performance Test Order" where("Customer No." = field("No.")));
            Editable = false;
        }
        field(8; Status; Enum "Performance Test Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        // Intentionally missing SIFT keys - participants will add them in Room 5
    }
}
