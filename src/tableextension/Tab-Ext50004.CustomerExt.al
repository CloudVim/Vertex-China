tableextension 50004 "Customer_Ext" extends Customer
{
    fields
    {
        field(50000; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}