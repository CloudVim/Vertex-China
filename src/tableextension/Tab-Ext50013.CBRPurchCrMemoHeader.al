tableextension 50013 "CBR_PurchCrMemoHeader" extends "Purch. Cr. Memo Hdr."
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