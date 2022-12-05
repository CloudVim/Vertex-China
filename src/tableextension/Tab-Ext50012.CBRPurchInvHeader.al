tableextension 50012 "CBR_PurchInvHeader" extends "Purch. Inv. Header"
{
    fields
    {
        field(50000; "Work Description"; BLOB)
        {
            Caption = 'Work Description';
        }
    }

    var
        myInt: Integer;
}