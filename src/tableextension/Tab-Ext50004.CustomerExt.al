tableextension 50004 "Customer_Ext" extends Customer
{
    fields
    {
        field(50000; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Commission Percentage"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Commission %';
            DecimalPlaces = 0 : 5;
        }
    }

    var
        myInt: Integer;
}