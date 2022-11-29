reportextension 50000 "CBR_PurchaseOrder" extends "Purchase Order"
{
    dataset
    {
        add("Purchase Line")
        {

            column(Item_Factory; Item_L.Factory) { }
            column(Item_CasePack; CasePack_G) { }
        }
        modify("Purchase Line")
        {
            trigger OnAfterAfterGetRecord()
            var
            begin
                CasePack_G := 0;
                If Item_L.Get("Purchase Line"."No.") then
                    If Item_L."Case Pack" <> 0 then
                        CasePack_G := Item_L."Case Pack";
            end;
        }
    }

    var
        Item_L: Record Item;
        CasePack_G: Integer;
}