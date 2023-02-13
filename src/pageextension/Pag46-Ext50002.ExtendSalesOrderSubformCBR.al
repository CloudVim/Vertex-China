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
        //AGT_YK_200922++
        addafter("Unit of Measure")
        {

            field("Case Pack"; Rec."Case Pack")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Case Pack field.';
            }
        }
        //AGT_YK_200922--
        addafter("Qty. to Ship")
        {

            field(CasestoShip; Rec.CasestoShip)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the CasestoShip field.';
            }
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                RecItem: Record Item;
                CaseQty: Decimal;
            begin
                UpdateTotalWeightForOrder(Rec);
                CurrPage.Update(false);
                clear(CaseQty);
                If RecItem.Get(Rec."No.") then begin
                    if (RecItem."Case Pack" <> 0) and (rec."Unit of Measure Code" = 'DZ') then begin  //AGT.YK.090223 added UOM condition
                        CaseQty := Rec.Quantity / RecItem."Case Pack";
                        iF (CaseQty MOD 1) <> 0 then
                            Error('The Quantity on sales line is out of case pack. Please correct. ')
                        else
                            Rec."No. of Cases" := Rec.Quantity / RecItem."Case Pack";
                        Rec.Modify();
                    end;
                end;
            end;
        }
        addafter("Location Code")
        {
            field("Salesperson Code"; Rec."Salesperson Code")
            {
                ApplicationArea = all;
            }
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
                    if (RecItem1."Case Pack" <> 0) and (rec."Unit of Measure Code" = 'DZ') then begin//AGT.SS
                        CaseQty1 := Rec."Qty. to Ship" / RecItem1."Case Pack";
                        iF (CaseQty1 MOD 1) <> 0 then
                            Error('The Quantity of sales Line to Ship is out of case pack. Please correct. ')
                        else
                            Rec."No. of Cases Ship" := Rec."Qty. to Ship" / RecItem1."Case Pack";
                        Rec.Modify();
                    end;
                end;
            end;
        }
        addafter("Line Discount %")
        {
            field("Unit Price Line Discount"; Rec."CBR_Unit Price Line Discount")
            {
                ApplicationArea = All;
                Caption = 'Unit Price after Discount';
                ToolTip = 'Specifies the value of the Unit Price Line Discount field.';
            }
        }
        // modify("No.")//AGT_DS_011223
        // {
        //     trigger OnAfterValidate()
        //     var
        //         Item_L: Record Item;
        //     begin
        //         If Item_L.Get("No.") then
        //             If Item_L."Sales Unit of Measure" <> 'DZ' Then begin
        //                 Item_L."Stockout Warning" := Item_L."Stockout Warning"::No;
        //                 Item_L.Modify()
        //             end;
        //     end;
        // }
    }
    // trigger OnAfterGetRecord()
    // begin
    //     // Rec.GetItemDataFosSales(Rec."No.", Rec."Sell-to Customer No.");
    // end;

    trigger OnAfterGetRecord()
    begin
        UpdateTotalWeightForOrder(Rec);//AGT_DS_10192022
    end;
}
