pageextension 50000 "ExtendItemList_CBR" extends "Item List" //31
{
    layout
    {
        addafter("Unit Price")
        {
            field(GTIN; REC.GTIN)
            {
                ApplicationArea = all;
            }
            field("Case Pack"; Rec."Case Pack")
            {
                ApplicationArea = All;
                Caption = 'Case Pack';
            }
            field(CaseWeight; Rec."Case Pack" * REC."Gross Weight")
            {
                ApplicationArea = All;
                Caption = 'Case Weight';
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
    actions
    {
        addafter("Item Reclassification Journal")
        {
            action("Inventory Planning")
            {
                ApplicationArea = All;
                Caption = 'Inventory Planning';
                Image = Inventory;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Inventory Planning";
            }
        }
    }
}
