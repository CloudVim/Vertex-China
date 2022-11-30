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
        addafter(InventoryField)
        {
            field(QtyAvailable; QtyAvailable)
            {
                ApplicationArea = All;
                Caption = 'Qty Available';
                DecimalPlaces = 0 : 0;
            }
            field("Qty. on Sales Order"; Rec."Qty. on Sales Order")
            {
                ApplicationArea = ALL;
                DecimalPlaces = 0 : 0;
            }
            field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
            {
                ApplicationArea = ALL;
                DecimalPlaces = 0 : 0;
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
    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        IF ItemUOM.GET("No.", "Sales Unit of Measure") THEN;
        CALCFIELDS(Inventory, "Qty. on Purch. Order", "Qty. on Sales Order");
        QtyAvailable := Inventory - "Qty. on Sales Order";
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        CALCFIELDS(Inventory, "Qty. on Purch. Order", "Qty. on Sales Order");
        QtyAvailable := Inventory - "Qty. on Sales Order";
    end;

    var
        QtyAvailable: Decimal;
        ItemUOM: Record "Item Unit of Measure";
}
