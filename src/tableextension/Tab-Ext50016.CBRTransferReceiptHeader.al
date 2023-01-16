tableextension 50016 "CBR_TransferReceiptHeader" extends "Transfer Receipt Header"
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