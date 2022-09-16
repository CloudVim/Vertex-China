pageextension 50014 "CBR_PostedSalesCrMemoSubform" extends "Posted Sales Cr. Memo Subform"
{
    layout
    {
        addafter("Line Discount Amount")
        {
            field("Salesperson Code"; Rec."Salesperson Code")
            {
                ApplicationArea = all;
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