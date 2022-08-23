pageextension 50002 "ExtendSalesOrderSubform_CBR" extends "Sales Order Subform" //46
{
    layout
    {
        addafter("Qty. to Assemble to Order")
        {

            field("Qty Available"; Rec."Qty Available")
            {
                ApplicationArea = All;
            }
        }
        addafter(Quantity)
        {

            field("Commission Rate"; Rec."Commission Rate")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Commission Rate field.';
            }
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                RecItem: Record Item;
                CaseQty: Decimal;
            begin
                clear(CaseQty);
                If RecItem.Get(Rec."No.") then begin
                    if RecItem."Case Pack" <> 0 then begin
                        CaseQty := Rec.Quantity / RecItem."Case Pack";
                        iF (CaseQty MOD 1) <> 0 then
                            Error('The Quantity is out of case pack. Please correct. ')
                        else
                            Rec."No. of Cases" := Rec.Quantity / RecItem."Case Pack";
                        Rec.Modify();
                    end;
                end;
            end;
        }
        addafter(Quantity)
        {
            field("No. of Cases"; Rec."No. of Cases")
            {
                ApplicationArea = all;
                Caption = 'No. of Cases';
                Editable = false;
            }
        }
        modify("Qty. to Ship")
        {
            trigger OnAfterValidate()
            var
                RecItem1: Record Item;
                CaseQty1: Decimal;
            begin
                clear(CaseQty1);
                If RecItem1.Get(Rec."No.") then begin
                    if RecItem1."Case Pack" <> 0 then begin
                        CaseQty1 := Rec."Qty. to Ship" / RecItem1."Case Pack";
                        iF (CaseQty1 MOD 1) <> 0 then
                            Error('The Quantity to Ship is out of case pack. Please correct. ')
                        else
                            Rec."No. of Cases Ship" := Rec."Qty. to Ship" / RecItem1."Case Pack";
                        Rec.Modify();
                    end;
                end;
            end;
        }
    }
    trigger OnAfterGetRecord()
    begin
        // Rec.GetItemDataFosSales(Rec."No.", Rec."Sell-to Customer No.");
    end;
}
