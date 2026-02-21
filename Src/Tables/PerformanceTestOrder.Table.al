table 74301 "Performance Test Order"
{
    DataClassification = CustomerContent;
    Caption = 'Performance Test Order';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = "Performance Test Customer"."No.";
        }
        field(3; "Order Date"; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; Status; Enum "Performance Test Status")
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
        key(CustomerKey; "Customer No.")
        {
            MaintainSIFTIndex = true;
            SumIndexFields = Amount;
        }
    }
}
