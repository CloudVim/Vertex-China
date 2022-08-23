pageextension 50001 "ExtendItemCard_CBR" extends "Item Card" //30
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
            field("Group Code"; Rec."Group Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Group Code field.';
            }
        }
    }
}
