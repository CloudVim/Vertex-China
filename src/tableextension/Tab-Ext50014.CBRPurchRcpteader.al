tableextension 50014 "CBR_PurchRcpteader" extends "Purch. Rcpt. Header"
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