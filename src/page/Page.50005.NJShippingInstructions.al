page 50005 "NJ Shipping Instructions"
{
    PageType = List;
    SourceTable = "Sales Line";
    SourceTableView = SORTING("Document Type", "Document No.", "Line No.")
                      ORDER(Ascending)
                      WHERE(Status = CONST(Released),
                            "Location Code" = CONST('888'),
                            "Qty. to Ship" = FILTER(> 0));

    Caption = 'NJ Shipping Instructions';
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite, Assembly, Service;
    PromotedActionCategories = 'New,Process,Report,Item,History,Prices & Discounts,Request Approval,Periodic Activities,Inventory,Attributes';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Reference Number';
                }
                field("External Document No"; recSalesHeader."External Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Order Number';
                }
                field("Shipping Agent Code"; recSalesHeader."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Caption = 'Ship Carrier';
                }
                field("Shipping Agent Service Code"; recSalesHeader."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    Caption = 'Ship Service';
                }
                field("ShipBilling"; ShipmentMethod.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Ship Billing';
                }
                field("ShipAccount"; ShipAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Ship Account';
                }
                field("AccountZip"; AccountZip)
                {
                    ApplicationArea = All;
                    Caption = 'Account Zip';
                }
                field("ShipDate"; ShipDate)
                {
                    ApplicationArea = All;
                    Caption = 'Ship Date';
                }
                field("CancelDate"; CancelDate)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Date';
                }
                field("Notes"; Notes)
                {
                    ApplicationArea = All;
                    Caption = 'Notes';
                }
                field("Ship-to Contact"; recSalesHeader."Ship-to Contact")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Name';
                }
                field("Ship-to Name"; recSalesHeader."Ship-to Name")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Company';
                }
                field("Ship-to Address"; recSalesHeader."Ship-to Address")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Address1';
                }
                field("Ship-to Address 2"; recSalesHeader."Ship-to Address 2")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Address 2';
                }
                field("Ship-to City"; recSalesHeader."Ship-to City")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To City';
                }
                field("Ship-to County"; recSalesHeader."Ship-to County")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To State';
                }
                field("Ship-to Post Code"; recSalesHeader."Ship-to Post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Zip';
                }
                field("Ship-to Country/Region Code"; recSalesHeader."Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Country';
                }
                field("ShipToPhone"; recSalesHeader."Ship-to Phone No.")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Phone';
                }
                field("ShipToFax"; recSalesHeader."Ship-to Fax No.")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Fax';
                }
                field("ShipToEmail"; recSalesHeader."Ship-to E-Mail")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Email';
                }
                field("ShipToCustomerID"; recSalesHeader."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Customer ID';
                }
                field("ShipToDeptNumber"; ShipToDeptNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Ship To Dept Number';
                }
                field("RetailerID"; RetailerID)
                {
                    ApplicationArea = All;
                    Caption = 'Retailer ID';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                }
                field("UseCOD"; UseCOD)
                {
                    ApplicationArea = All;
                    Caption = 'Use COD';
                }
                field("UseInsurance"; UseInsurance)
                {
                    ApplicationArea = All;
                    Caption = 'Use Insurance';
                }
                field("Saved Elements"; SavedElements)
                {
                    ApplicationArea = All;
                    Caption = 'Saved Elements';
                }
                field("Order Item Saved Elements"; OrderItemSavedElements)
                {
                    ApplicationArea = All;
                    Caption = 'Order Item Saved Elements';
                }
                field("Carrier Notes"; CarrierNotes)
                {
                    ApplicationArea = All;
                    Caption = 'Carrier Notes';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if recSalesHeader.Get(Rec."Document Type"::Order, Rec."Document No.") then begin
            if ShipmentMethod.Get(recSalesHeader."Shipment Method Code") then;
            if recSalesHeader."Shipper Acct No." <> '' then
                ShipAccount := recSalesHeader."Shipper Acct No."
            else
                ShipAccount := '02A1V8';
            AccountZip := '07072';
        end;
    end;

    var
        recSalesHeader: Record "Sales Header";
        UseInsurance: Text;
        SavedElements: Text;
        OrderItemSavedElements: Text;
        CarrierNotes: Text;
        UseCOD: Text;
        ShipToDeptNumber: Text;
        RetailerID: Text;
        ShipToCustomerID: Text;
        ShipToEmail: Text;
        ShipToFax: Text;
        ShipToPhone: Text;
        Notes: Text;
        ShipDate: Date;
        CancelDate: Date;
        AccountZip: Code[20];
        ShipAccount: Code[20];
        ShipBilling: Text;
        ShipmentMethod: Record "Shipment Method";
        recShipTo: Record Customer;
}

