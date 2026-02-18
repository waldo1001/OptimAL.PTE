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
            FieldClass = FlowField;
            CalcFormula = Sum("Performance Test Order".Amount where("Customer No." = field("No.")));
            Editable = false;
        }
        field(7; "Order Count"; Integer)
        {
            Caption = 'Order Count';
            FieldClass = FlowField;
            CalcFormula = Count("Performance Test Order" where("Customer No." = field("No.")));
            Editable = false;
        }
        field(8; Status; Enum "Performance Test Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(10; "Description"; Text[2048])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Notes"; Text[2048])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
        }
        field(12; "Extended Address"; Text[2048])
        {
            Caption = 'Extended Address';
            DataClassification = CustomerContent;
        }
        field(13; "Contact Information"; Text[2048])
        {
            Caption = 'Contact Information';
            DataClassification = CustomerContent;
        }
        field(14; "Shipping Instructions"; Text[2048])
        {
            Caption = 'Shipping Instructions';
            DataClassification = CustomerContent;
        }
        field(15; "Payment Terms Detail"; Text[2048])
        {
            Caption = 'Payment Terms Detail';
            DataClassification = CustomerContent;
        }
        field(16; "Internal Comments"; Text[2048])
        {
            Caption = 'Internal Comments';
            DataClassification = CustomerContent;
        }
        field(17; "Compliance Notes"; Text[2048])
        {
            Caption = 'Compliance Notes';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}
