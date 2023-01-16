pageextension 50019 "CBR_PostedTransferReceipt" extends "Posted Transfer Receipt"
{
    layout
    {
        addafter("In-Transit Code")
        {
            field("Reference No."; Rec."Reference No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Reference No. field.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}