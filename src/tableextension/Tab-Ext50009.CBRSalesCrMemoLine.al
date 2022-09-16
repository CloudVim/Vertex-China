tableextension 50009 "CBR_SalesCrMemoLine" extends "Sales Cr.Memo Line"
{
    fields
    {
        field(50010; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }
    }

    var
        myInt: Integer;
}