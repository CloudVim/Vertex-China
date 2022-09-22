tableextension 50010 "CBR_SalesShipmentLine" extends "Sales Shipment Line"
{
    fields
    {
        field(50010; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }
        //AGT_YK_200922++
        field(50015; "Case Pack"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Case Pack';
            Editable = false;
        }
        //AGT_YK_200922--
    }

    var
        myInt: Integer;
}