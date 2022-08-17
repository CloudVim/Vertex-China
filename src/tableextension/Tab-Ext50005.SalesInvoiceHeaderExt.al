tableextension 50005 "SalesInvoiceHeader_Ext" extends "Sales Invoice Header"
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