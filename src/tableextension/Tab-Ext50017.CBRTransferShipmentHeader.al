tableextension 50017 "CBR_TransferShipmentHeader" extends "Transfer Shipment Header"
{
    fields
    {
        field(50001; "Reference No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}