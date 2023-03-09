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
        field(50006; "Weight To Ship"; Decimal)
        {
            //FieldClass = FlowField;
            Caption = 'Weight To Ship';
            Editable = false;
            //CalcFormula = Sum("Sales Line"."Net Weight" WHERE("Document Type" = FILTER(Order), "Document No." = FIELD("No."), Type = FILTER(Item), "No." = FILTER(<> 'ZZ*')));
        }
    }

    var
        myInt: Integer;
}