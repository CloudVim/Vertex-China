table 50000 "Sales Invoice Detail CBR"
{
    DataClassification = ToBeClassified;
    Caption = 'Sales Invoice Detail';

    fields
    {
        field(1; "Invoice No"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Invoice No';
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Invoice Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Customer PO"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer PO #';
        }
        field(5; "Payment Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Item Description"; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(8; Collection; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(9; "Customer No"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Customer Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Customer Price Group"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Group';
        }
        field(12; "Ship-to Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship to Code';
        }
        field(13; "Ship-to Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship to Name';
        }
        field(14; "Ship-to Post Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Zip Code';
        }
        field(15; "Ship-to State"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'State';
        }
        field(16; Warehouse; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Warehouse';
        }
        field(17; "Sales Rep"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Rep';
        }
        field(18; "Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(19; "Net Sale"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Net Sale';
        }
        field(20; "Margin"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Margin';
        }

    }

    keys
    {
        key(Key1; "Invoice No", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;
        AdjustCost: Decimal;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    var


    procedure UpdateItemHistory()
    var
        SalesInvHead: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesInvoiceDetail: Record "Sales Invoice Detail CBR";
    begin
        if not Confirm('Do you want to refresh data into Item Sales History Table, this action will delete all of the existing sales history lines and re-populate the data from posted Sales Invoice', false) then
            exit;
        SalesInvoiceDetail.DeleteAll;

        SalesInvHead.Reset;
        if SalesInvHead.Find('-') then
            repeat
                if not IFItemSalesLinesExit(SalesInvHead) then begin
                    SalesInvLine.Reset;
                    SalesInvLine.SetRange("Document No.", SalesInvHead."No.");
                    SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                    if SalesInvLine.FindSet then
                        repeat
                            CreateLines(SalesInvHead, SalesInvLine);
                        until SalesInvLine.Next = 0;
                end;
            until SalesInvHead.Next = 0;
        Message('Completed Successfully');
    end;

    procedure CreateLines(SInvHead: Record "Sales Invoice Header"; SInvLine: Record "Sales Invoice Line")
    var
        SalesInvoiceDetail: Record "Sales Invoice Detail CBR";
        Item: Record Item;
        recCustomer: Record Customer;
    begin
        SalesInvoiceDetail.Init;
        SalesInvoiceDetail."Invoice No" := SInvHead."No.";
        SalesInvoiceDetail."Line No." := SInvLine."Line No.";
        SalesInvoiceDetail."Invoice Date" := SInvHead."Posting Date";
        SalesInvoiceDetail."Payment Date" := GetPaymentDate(SInvHead."No.");
        SalesInvoiceDetail."Customer PO" := SInvHead."External Document No.";
        SalesInvoiceDetail."Item No." := SInvLine."No.";
        SalesInvoiceDetail."Item Description" := SInvLine.Description;
        if Item.Get(SInvLine."No.") then
            SalesInvoiceDetail.Collection := Item."Item Category Code";
        SalesInvoiceDetail."Customer No" := SInvHead."Sell-to Customer No.";
        SalesInvoiceDetail."Customer Name" := SInvHead."Sell-to Customer Name";
        if recCustomer.Get(SInvHead."Sell-to Customer No.") then
            SalesInvoiceDetail."Customer Price Group" := recCustomer."Customer Price Group";
        SalesInvoiceDetail."Ship-to Code" := SInvHead."Ship-to Code";
        SalesInvoiceDetail."Ship-to Name" := SInvHead."Ship-to Name";
        SalesInvoiceDetail."Ship-to Post Code" := SInvHead."Ship-to Post Code";
        SalesInvoiceDetail."Ship-to State" := SInvHead."Ship-to County";
        SalesInvoiceDetail.Warehouse := SInvLine."Location Code";
        SalesInvoiceDetail."Sales Rep" := SInvHead."Salesperson Code";
        SalesInvoiceDetail.Quantity := SInvLine.Quantity;
        SalesInvoiceDetail."Net Sale" := SInvLine."Line Amount";
        SalesInvoiceDetail.Margin := (SInvLine."Line Amount" - GetAdjustedCost(SInvLine."Document No.", SInvLine."Line No."));
        if SalesInvoiceDetail.Insert then;
    end;



    procedure IFItemSalesLinesExit(SalesInvHead: Record "Sales Invoice Header"): Boolean
    var
        SalesInvoiceDetail: Record "Sales Invoice Detail CBR";
    begin
        SalesInvoiceDetail.Reset;
        SalesInvoiceDetail.SetRange("Invoice No", SalesInvHead."No.");
        if SalesInvoiceDetail.Count > 0 then
            exit(true)
        else
            exit(false)
    end;

    procedure GetAdjustedCost(InvoiceDocNo: Code[20]; InvoiceLineNo: Integer): Decimal
    var
        recSalesInvoiceLine: Record "Sales Invoice Line";
        CostCalcMgt: Codeunit "Cost Calculation Management";
    begin
        if recSalesInvoiceLine.get(InvoiceDocNo, InvoiceLineNo) then begin
            AdjustCost := CostCalcMgt.CalcSalesInvLineCostLCY(recSalesInvoiceLine);
            exit(AdjustCost);
        end;
    end;

    procedure GetPaymentDate(DocNo: Code[20]): Date
    var
        CLEInvoice: Record "Cust. Ledger Entry";
        CLEPayment: Record "Cust. Ledger Entry";
    begin
        CLEInvoice.Reset();
        CLEInvoice.SetRange("Document Type", CLEInvoice."Document Type"::Invoice);
        CLEInvoice.SetRange("Document No.", DocNo);
        if CLEInvoice.FindFirst() then begin
            if CLEPayment.get(CLEInvoice."Closed by Entry No.") then
                exit(CLEPayment."Posting Date");
        end;

    end;

}