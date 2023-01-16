tableextension 50015 "CBR_TransferHeader" extends "Transfer Header"
{
    fields
    {
        field(50000; "Total Qty."; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Transfer Line".Quantity where("Document No." = field("No.")));
        }
        field(50001; "Reference No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}