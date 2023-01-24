tableextension 50018 "CBR_CustLedgerEntry" extends "Cust. Ledger Entry"
{
    fields
    {
        field(50000; REFERENCE; Text[35])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}