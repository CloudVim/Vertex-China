tableextension 50007 "SalesCrMemoHeader_Ext" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50004; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}