pageextension 50011 "PostedSalesShipment_Ext" extends "Posted Sales Shipment"
{
    layout
    {
        addbefore("External Document No.")
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