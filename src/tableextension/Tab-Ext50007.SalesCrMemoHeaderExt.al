tableextension 50007 "SalesCrMemoHeader_Ext" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50004; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
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