pageextension 50003 "ExtendPostedsalesline_CBR" extends "Posted Sales Invoice Subform" //30
{
    layout
    {
        addafter(Quantity)
        {
            field("No. of Cases"; Rec."No. of Cases")
            {
                ApplicationArea = All;
                Caption = 'No. of Cases';
            }
            field("Commission Rate"; Rec."Commission Rate")
            {
                ApplicationArea = All;
                Caption = 'Commission Rate';
            }
        }
        addafter("Location Code")
        {
            field("Salesperson Code"; Rec."Salesperson Code")
            {
                ApplicationArea = all;
            }
        }

    }
}
