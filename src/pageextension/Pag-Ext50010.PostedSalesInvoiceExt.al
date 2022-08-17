pageextension 50010 "PostedSalesInvoice_Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addbefore(Closed)
        {
            field("Commission Rate"; Rec."Commission Rate")
            {
                ApplicationArea = All;
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