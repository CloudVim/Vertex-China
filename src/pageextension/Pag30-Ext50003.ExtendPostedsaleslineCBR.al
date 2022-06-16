pageextension 50003 "ExtendPostedsalesline_CBR" extends "Posted Sales Invoice Subform" //30
{
    layout
    {
        addafter(Quantity)
        {
            field("No. of Cases";Rec."No. of Cases")
            {
                ApplicationArea = All;
                Caption = 'No. of Cases';
            }
        }
    }
}
