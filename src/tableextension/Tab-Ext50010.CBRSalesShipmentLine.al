tableextension 50010 "CBR_SalesShipmentLine" extends "Sales Shipment Line"
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