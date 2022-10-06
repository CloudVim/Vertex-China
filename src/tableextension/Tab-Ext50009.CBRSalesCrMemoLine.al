tableextension 50009 "CBR_SalesCrMemoLine" extends "Sales Cr.Memo Line"
{
    fields
    {
        field(50009; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
            //Editable = false;
        }
        field(50010; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }
        field(50016; "CBR_Unit Price Line Discount"; Decimal)
        {
            Caption = 'Unit Price Line Discount';
            Editable = false;

        }
    }

    var
        myInt: Integer;
}