codeunit 50000 "EventSubcriber_VertexChina"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopyShipToCustomerAddressFieldsFromCustomer', '', true, true)]
    local procedure UpdateContactData(VAR SalesHeader: Record "Sales Header";
    SellToCustomer: Record Customer)
    begin
        SalesHeader."Ship-to Phone No." := SellToCustomer."Phone No.";
        SalesHeader."Ship-to Fax No." := SellToCustomer."Fax No.";
        SalesHeader."Ship-to E-Mail" := SellToCustomer."E-Mail";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', true, true)]
    local procedure UpdateContactData1(VAR SalesHeader: Record "Sales Header";
    ShipToAddress: Record "Ship-to Address")
    begin
        SalesHeader."Ship-to Phone No." := ShipToAddress."Phone No.";
        SalesHeader."Ship-to Fax No." := ShipToAddress."Fax No.";
        SalesHeader."Ship-to E-Mail" := ShipToAddress."E-Mail";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item-Check Avail.", 'OnBeforeCreateAndSendNotification', '', false, false)]

    local procedure OnBeforeCreateAndSendNotification(UnitOfMeasureCode: Code[20]; var IsHandled: Boolean);
    Var
    Begin
        IF UnitOfMeasureCode <> 'DZ' then
            IsHandled := true;
    End;

    //AGT.YK.090223++
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Quantity', False, False)]
    local procedure OnAfterValidateEvent_SalesLineQty(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
    begin
        UpdateCasePackQty(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Unit of Measure Code', False, False)]
    local procedure OnAfterValidateEvent_SalesLineUOM(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
    begin
        UpdateCasePackQty(Rec);
    end;

    local procedure UpdateCasePackQty(var Rec: Record "Sales Line")
    var
        RecItem1: Record Item;
    begin
        If RecItem1.Get(Rec."No.") then begin
            if (RecItem1."Case Pack" > 0) and (rec."Unit of Measure Code" = 'DZ') then
                Rec."Case Pack" := RecItem1."Case Pack"
            else
                if rec."Unit of Measure Code" = 'EA' then
                    Rec."Case Pack" := 1;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Unit Price', False, False)]
    local procedure OnAfterValidateEvent_SalesLineUnitPrice(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.UpdateTotalWeightForOrder(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Line Discount %', False, False)]
    local procedure OnAfterValidateEvent_SalesLineDiscout(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.UpdateTotalWeightForOrder(Rec);
    end;
    //AGT.YK.090223--
    //AGT_DS_130223++
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Qty. to Ship', False, False)]
    local procedure OnAfterValidateEvent_QtyToShip(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        Item_L: Record Item;
    begin
        If (Rec."Qty. to Ship" <> 0) and (Rec.Type = Rec.Type::Item) then
            If Item_L.Get(Rec."No.") then
                if Item_L."Case Pack" > 0 then
                    Rec.CasestoShip := Rec."Qty. to Ship" / Item_L."Case Pack";
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order List", 'OnOpenPageEvent', '', False, False)]
    local procedure OnOpenPageEvent_SalesOrderList(var Rec: Record "Sales Header")
    var
        Item_L: Record Item;
        SalesLine_L: Record "Sales Line";
    begin
        SalesLine_L.Reset();
        SalesLine_L.SetFilter(CasestoShip, '=%1', 0);
        If SalesLine_L.FindSet() then
            repeat
                If (SalesLine_L."Qty. to Ship" <> 0) and (SalesLine_L.Type = SalesLine_L.Type::Item) then
                    If Item_L.Get(SalesLine_L."No.") then
                        if Item_L."Case Pack" > 0 then begin
                            SalesLine_L.CasestoShip := SalesLine_L."Qty. to Ship" / Item_L."Case Pack";
                            SalesLine_L.Modify();
                        end;
            Until SalesLine_L.Next() = 0;
    end;
    //AGT_DS_130223--
}
