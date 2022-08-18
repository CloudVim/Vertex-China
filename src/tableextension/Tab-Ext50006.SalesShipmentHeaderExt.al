tableextension 50006 "SalesShipmentHeader_Ext" extends "Sales Shipment Header"
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