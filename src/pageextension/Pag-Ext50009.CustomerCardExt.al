pageextension 50009 "CustomerCard_Ext" extends "Customer Card"
{
    layout
    {
        addbefore("Last Date Modified")
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