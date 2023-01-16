tableextension 50005 "SalesInvoiceHeader_Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(50004; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50005; "CBR Customer Price Group"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Customer."Customer Price Group" where("No." = field("Sell-to Customer No.")));
        }
    }

    var
        myInt: Integer;
}