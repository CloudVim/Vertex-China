pageextension 50001 ExtendItemCard_CBR extends "Item Card"  //30
{
    layout
    {
        addafter("Item Category Code")
        {
            field("Case Pack"; Rec."Case Pack")
            {
                ApplicationArea = All;
                Caption = 'Case Pack';
            }
            field(Factory; Rec.Factory)
            {
                ApplicationArea = All;
                Caption = 'Factory';
            }
        }
    }
}