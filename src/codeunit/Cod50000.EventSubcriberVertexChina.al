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

}
