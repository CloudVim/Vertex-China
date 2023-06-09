pageextension 50008 "ExtendSalesOrder_CBR" extends "Sales Order"
{

    layout
    {
        addafter("External Document No.")
        {
            field("Shipper Acct No."; Rec."Shipper Acct No.")
            {
                ApplicationArea = All;
                Caption = 'Shipper Acct No.';
            }
        }
        addbefore(Status)
        {
            field("Commission Rate"; Rec."Commission Rate")
            {
                ApplicationArea = All;
            }
        }
        addafter(Status)
        {
            field(Stage; Rec.Stage)
            {
                ApplicationArea = all;
                Caption = 'Stage';
            }
        }
        //..AGT_VS_070323++  
        modify("External Document No.")
        {
            Caption = 'P.O. Number';
        }
        addbefore("Combine Shipments")
        {
            field("Weight To Ship"; Rec."Weight To Ship")
            { ApplicationArea = all; Caption = 'Weight To Ship'; }
        }
        //..AGT_VS_070323--
    }
    actions
    {
        addafter("Print Confirmation")
        {
            action(CBR_ProFormaInvoice)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Pro Forma Invoice';
                Ellipsis = true;
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Category11;
                trigger OnAction()
                var
                    salesHeader: Record "Sales Header";
                begin
                    salesHeader.Reset();
                    CurrPage.SetSelectionFilter(salesHeader);
                    Report.Run(50009, true, false, salesHeader);
                end;
            }
        }
        addafter(AttachAsPDF)
        {
            action(packingslip)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Packing Slip';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Category11;
                Ellipsis = true;

                trigger OnAction()
                var
                    salesHeader: Record "Sales Header";
                begin
                    salesHeader.Reset();
                    CurrPage.SetSelectionFilter(salesHeader);
                    Report.Run(50001, true, false, salesHeader);
                end;
            }
            action(BillofLading)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bill Of Lading';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Category11;
                Ellipsis = true;

                trigger OnAction()
                var
                    salesHeader: Record "Sales Header";
                begin
                    salesHeader.Reset();
                    CurrPage.SetSelectionFilter(salesHeader);
                    Report.Run(50002, true, false, salesHeader);
                end;
            }
        }

        addafter("Create &Warehouse Shipment")
        {
            action("Vertex_Auto Assign Item Tracking")
            {
                ApplicationArea = All;
                Caption = 'Auto Assign Item Tracking Lot';
                Image = Track;
                Promoted = true;
                PromotedCategory = Category7;
                trigger OnAction()
                begin
                    InsertTrackingLines();
                end;
            }
        }
        // addafter(GetRecurringSalesLines_Promoted)
        // {

        //     actionref(asd; "Vertex_Auto Assign Item Tracking")
        //     { }
        // }
    }
    var
        ShowMessage: Boolean;
        recReservationEntry: Record "Reservation Entry";

    local procedure InsertTrackingLines()
    var
        RecSalesLine: Record "Sales Line";
        SalesDocStatus: Enum "Sales Document Status";
        ReservationEntry: Record "Reservation Entry";
        ErrorTable: Record "Error Message";
        InvSetup: Record "Inventory Setup";


        ItemRec: Record Item;
        Text001: Label 'Item Tracking Lines for the Order: %1  has been created successfully';
        Text002: Label 'Would you like to auto fill the tracking line for the Order No %1';
    begin
        Rec.TestField(Status, 0);
        IF NOT CONFIRM(Text002, FALSE, Rec."No.") THEN
            EXIT;
        InvSetup.get;
        VertexDeleteReservationEntry(Rec);

        ShowMessage := false;
        RecSalesLine.RESET;
        RecSalesLine.SETRANGE("Document Type", RecSalesLine."Document Type"::Order);
        RecSalesLine.SETRANGE("Document No.", Rec."No.");
        RecSalesLine.SETRANGE(Type, RecSalesLine.Type::Item);
        RecSalesLine.SETFILTER("Qty. to Ship", '>%1', 0);
        IF RecSalesLine.FINDSET THEN
            REPEAT
                //f RecSalesLine."Location Code" IN ['WA', 'SA', 'NSW', 'QLD', 'VIC', 'TAS', 'AUCK NZ', 'CHRISTC NZ'] then begin
                IF ItemRec.GET(RecSalesLine."No.") THEN BEGIN
                    IF ItemRec.Type = ItemRec.Type::Inventory THEN BEGIN
                        VertexDeleteUnusedReservationEntry(ItemRec."No.", RecSalesLine."Location Code");
                        VertexAutoFillTrackingLines(Rec, RecSalesLine, ErrorTable);
                    END;
                END;
            // end;
            UNTIL RecSalesLine.NEXT = 0;
        if ShowMessage then
            MESSAGE('Tracking lines for Sales order : %1 have been created successfully', Rec."No.");
    end;

    procedure VertexDeleteReservationEntry(SalesHead: Record "Sales Header")
    var
        ReservEntry: Record "Reservation Entry";
        ReservEntry1: Record "Reservation Entry";
    begin
        ReservEntry.RESET;
        ReservEntry.SETRANGE("Source Type", DATABASE::"Sales Line");
        ReservEntry.SETRANGE("Source ID", SalesHead."No.");
        IF ReservEntry.FINDSET THEN
            repeat
                ReservEntry1.Reset();
                ReservEntry1.Setrange("Entry No.", ReservEntry."Entry No.");
                If ReservEntry1.FindSet() then
                    ReservEntry1.DELETEALL;
            Until ReservEntry.next = 0;
    end;

    procedure VertexDeleteUnusedReservationEntry(ItemNo: Code[20]; Location: code[20])
    var
        recSalesLine: Record "Sales Line";
    begin
        recReservationEntry.RESET;
        recReservationEntry.SETRANGE("Item No.", ItemNo);
        recReservationEntry.SetRange("Location Code", Location);
        IF recReservationEntry.FINDSET THEN
            REPEAT
                recSalesLine.RESET;
                recSalesLine.SetRange("Document Type", recSalesLine."Document Type"::Order);
                recSalesLine.SETRANGE("Document No.", recReservationEntry."Source ID");
                IF NOT recSalesLine.FINDSET THEN
                    recReservationEntry.DELETE;
            UNTIL recReservationEntry.NEXT = 0;
    end;

    local procedure VertexAutoFillTrackingLines(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; VAR ErrorTable: Record "Error Message"): Boolean
    var
        AvablLotQty: Decimal;
        ReservEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ILE1: Record "Item Ledger Entry";
        PostedPurchaseRecpt: Record "Purch. Rcpt. Header";
        LotQty: Decimal;
        TotalILEQty: Decimal;
        RequiredSaleLineQty: Decimal;
        ReserveQty: Decimal;
        SalesLineRec: Record "Sales Line";
        QtytoAssign: Decimal;
        CasePackQty: Decimal;
        ItemRec: Record Item;
        CurrLotNo: Code[20];
        ILERemainingQty: Decimal;
        lastentryNo: Integer;
        ItemLedgerEntry1: Record "Item Ledger Entry";
        PurchaseNumber: Code[20];
        POAvailable: Boolean;
    begin
        POAvailable := false;
        TotalILEQty := 0;
        ReserveQty := 0;


        ItemLedgerEntry.RESET;
        ItemLedgerEntry.SETRANGE("Item No.", SalesLine."No.");
        ItemLedgerEntry.SetRange("Location Code", SalesLine."Location Code");
        ItemLedgerEntry.SETFILTER("Remaining Quantity", '>%1', 0);
        IF ItemLedgerEntry.FINDSET THEN BEGIN
            ItemLedgerEntry.CALCSUMS("Remaining Quantity");
            TotalILEQty := ItemLedgerEntry."Remaining Quantity";
        END;

        ReservEntry.RESET;
        ReservEntry.SETRANGE("Item No.", SalesLine."No.");
        ReservEntry.SETRANGE("Location Code", SalesLine."Location Code");
        ReservEntry.SETRANGE("Source Type", DATABASE::"Sales Line");
        IF ReservEntry.FINDSET THEN
            REPEAT
                ReserveQty += ReservEntry."Quantity (Base)";
            UNTIL ReservEntry.NEXT = 0;

        CurrLotNo := '';
        RequiredSaleLineQty := SalesLine."Qty. to Ship (Base)";

        //Get the last reservation entry No
        ReservEntry.Reset();
        if ReservEntry.FindLast() then
            lastentryNo := ReservEntry."Entry No.";
        //AGT
        ItemLedgerEntry.RESET;
        ItemLedgerEntry.SETCURRENTKEY("Expiration Date");
        ItemLedgerEntry.SETRANGE("Item No.", SalesLine."No.");
        ItemLedgerEntry.SetRange("Location Code", SalesLine."Location Code");
        ItemLedgerEntry.SETFILTER("Remaining Quantity", '>%1', 0);
        IF ItemLedgerEntry.FINDSET THEN
            REPEAT
                AvablLotQty := 0;
                LotQty := 0;
                ILERemainingQty := 0;
                IF CurrLotNo <> ItemLedgerEntry."Lot No." THEN BEGIN  // Only trigger once for each Lot from the ILE
                    ILE1.RESET;
                    ILE1.SETCURRENTKEY(ILE1."Expiration Date");
                    ILE1.SETRANGE("Item No.", SalesLine."No.");
                    ILE1.SETRANGE("Lot No.", ItemLedgerEntry."Lot No.");
                    ile1.SetRange("Location Code", ItemLedgerEntry."Location Code");
                    ILE1.SETFILTER("Remaining Quantity", '>%1', 0);
                    IF ILE1.FINDFIRST THEN BEGIN
                        ILE1.CALCSUMS("Remaining Quantity");
                        LotQty := VertexGetReservationQty(SalesLine, ILE1);
                        AvablLotQty := ILE1."Remaining Quantity" + LotQty;  // Get the total avaliable quantity
                        ItemRec.GET(ILE1."Item No.");

                        IF RequiredSaleLineQty > AvablLotQty THEN BEGIN
                            QtytoAssign := AvablLotQty;
                            VertexCreateReservationEntry(ReservEntry, lastentryNo, ItemLedgerEntry, SalesLine, QtytoAssign);
                        END;
                        IF RequiredSaleLineQty <= AvablLotQty THEN BEGIN
                            QtytoAssign := RequiredSaleLineQty;
                            VertexCreateReservationEntry(ReservEntry, lastentryNo, ItemLedgerEntry, SalesLine, QtytoAssign);
                            EXIT;
                        END;

                        //Reduce the required qty after the previous allocation ++
                        IF RequiredSaleLineQty > AvablLotQty THEN
                            RequiredSaleLineQty := RequiredSaleLineQty - AvablLotQty
                        ELSE
                            RequiredSaleLineQty := AvablLotQty;
                    END;
                END;
                CurrLotNo := ItemLedgerEntry."Lot No.";
                lastentryNo := ReservEntry."Entry No.";
            UNTIL ItemLedgerEntry.NEXT = 0;

        IF RequiredSaleLineQty <> 0 THEN
            VertexInsertErrorLog(SalesLine, RequiredSaleLineQty, ErrorTable);
    end;

    local procedure VertexGetReservationQty(SalesLine: Record "Sales Line"; ILE: Record "Item Ledger Entry"): Decimal
    var
        ReservationQty: Decimal;
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.RESET;
        ReservEntry.SETRANGE("Item No.", SalesLine."No.");
        ReservEntry.SETRANGE("Location Code", SalesLine."Location Code");
        ReservEntry.SETRANGE("Source Type", DATABASE::"Sales Line");
        ReservEntry.SETRANGE("Lot No.", ILE."Lot No.");
        IF ReservEntry.FINDSET THEN
            REPEAT
                ReservationQty += ReservEntry."Quantity (Base)";
            UNTIL ReservEntry.NEXT = 0;
        EXIT(ReservationQty)
    end;

    local procedure VertexCreateReservationEntry(var ReservEntry: Record "Reservation Entry"; lastentryNo: Integer; ItemLedgerEntry: Record "Item Ledger Entry"; SalesLine: Record "Sales Line"; QtytoAssign: Decimal)
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        ReservEntry."Entry No." := lastentryNo + 1;
        ReservEntry.Validate("Item No.", ItemLedgerEntry."Item No.");
        ReservEntry.Validate("Location Code", ItemLedgerEntry."Location Code");
        ReservEntry.SetSource(DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", '', 0);
        ReservEntry.Validate("Reservation Status", ReservEntry."Reservation Status"::Surplus);
        ReservEntry.Validate("Creation Date", WorkDate());
        ReservEntry.Validate("Created By", UserId);
        ReservEntry.TestField("Qty. per Unit of Measure");
        ReservEntry.Validate("Qty. per Unit of Measure", SalesLine."Qty. per Unit of Measure");
        ReservEntry.Quantity := CreateReservEntry.SignFactor(ReservEntry) * QtytoAssign;
        ReservEntry.VALIDATE("Quantity (Base)", CreateReservEntry.SignFactor(ReservEntry) * QtytoAssign);
        ReservEntry.VALIDATE("Lot No.", ItemLedgerEntry."Lot No.");
        ReservEntry.Validate("Expiration Date", ItemLedgerEntry."Expiration Date");
        ReservEntry.Validate("Shipment Date", SalesLine."Shipment Date");
        ReservEntry.Validate(Positive, false);
        ReservEntry.Validate("Item Tracking", ReservEntry."Item Tracking"::"Lot No.");
        ReservEntry.Binding := 0;
        ReservEntry."Expected Receipt Date" := 0D;
        ReservEntry."Planning Flexibility" := ReservEntry."Planning Flexibility"::Unlimited;
        ReservEntry."Disallow Cancellation" := false;
        if ReservEntry.Insert() then
            ShowMessage := true;
    end;

    local procedure VertexInsertErrorLog(LocSalesLine: Record "Sales Line"; TotalQuantity: Integer; VAR ErrorTable: Record "Error Message")
    begin
        ErrorTable.INIT;
        IF ErrorTable.FINDLAST THEN
            ErrorTable.ID := ErrorTable.ID + 1
        ELSE
            ErrorTable.ID += 1;
        ErrorTable."Record ID" := LocSalesLine.RECORDID; //RecRef.RECORDID;
        ErrorTable."Field Number" := LocSalesLine.FIELDNO(LocSalesLine."Qty. to Ship (Base)");
        ErrorTable."Message Type" := ErrorTable."Message Type"::Information;
        ErrorTable.Description := 'Enough Lot Quantity is not available to fully assign the Sales Line Quantity ' + FORMAT(LocSalesLine."Qty. to Ship (Base)") + ' for Item ' + LocSalesLine."No." + ' , Balance Lot Quantity is ' + FORMAT(ABS(TotalQuantity));
        ErrorTable."Table Number" := DATABASE::"Sales Line";
        ErrorTable."Field Name" := LocSalesLine.FIELDNAME("Qty. to Ship (Base)");
        ErrorTable."Table Name" := LocSalesLine.TABLENAME;
        ErrorTable.INSERT;
    end;
}
