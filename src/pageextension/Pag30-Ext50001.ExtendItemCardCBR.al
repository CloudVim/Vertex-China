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
        addafter(Inventory)
        {
            field(BinInventory; Rec.BinInventory)
            {
                //ApplicationArea = All;
                Caption = 'Quantity on Hand';
                ApplicationArea = Basic, Suite;
                Enabled = IsInventoriable;
                HideValue = IsNonInventoriable;
                Importance = Promoted;
                ToolTip = 'Specifies how many units, such as pieces, boxes, or cans, of the item are in inventory.';
                //Visible = IsFoundationEnabled;

                trigger OnAssistEdit()
                var
                    AdjustInventory: Page "Adjust Bin Inventory";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);

                    if RecRef.IsDirty() then begin
                        Modify(true);
                        Commit();
                    end;

                    AdjustInventory.SetItem("No.");
                    if AdjustInventory.RunModal() in [ACTION::LookupOK, ACTION::OK] then
                        Get("No.");
                    CurrPage.Update()
                end;
            }
        }
        modify(Inventory)
        {
            Visible = false;
        }
    }
}
