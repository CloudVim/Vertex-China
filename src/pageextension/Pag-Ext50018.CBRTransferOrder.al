pageextension 50018 "CBR_TransferOrder" extends "Transfer Order"
{
    layout
    {
        addbefore("Shipment Date")
        {
            field("Total Qty."; Rec."Total Qty.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Total Qty. field.';
            }
        }
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
    {//AGT_DS_010522
        addafter("Get Bin Content")
        {
            action("CBR CopyDocument")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Copy Document';
                Enabled = "Transfer-from Code" <> '';
                Image = CopyDocument;

                trigger OnAction()
                begin
                    CopyDocument();
                end;
            }
        }
        addafter("Get Bin Content_Promoted")
        {
            actionref(CopyDocument; "CBR CopyDocument")
            {
            }
        }
    }
    //AGT_DS_010522
    procedure CopyDocument()
    var
        CopyTransferDocument: Report "Copy Transfer Document";
    begin
        CopyTransferDocument.SetTransferHeader(Rec);
        CopyTransferDocument.RunModal();
    end;

    var
        myInt: Integer;
}