pageextension 50023 "CBR_PhysInventoryJournal" extends "Phys. Inventory Journal"
{
    actions
    {
        addafter("Item &Tracking Lines")
        {
            action("CBR_Auto Assign Item Tracking")
            {
                ApplicationArea = All;
                Caption = 'Auto Assign Item Tracking Lot';
                Promoted = true;
                Image = Track;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    CBR_InsertTrackingLines();
                end;
            }
        }
    }
    local procedure CBR_GetReservationQty(ItemJournalLine_L: Record "Item Journal Line"; ILE: Record "Item Ledger Entry"): Decimal
    var
        ReservationQty: Decimal;
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.RESET;
        ReservEntry.SETRANGE("Item No.", ItemJournalLine_L."Item No.");
        ReservEntry.SETRANGE("Location Code", ItemJournalLine_L."Location Code");
        ReservEntry.SETRANGE("Source Type", DATABASE::"Item Journal Line");
        ReservEntry.SETRANGE("Lot No.", ILE."Lot No.");
        IF ReservEntry.FINDSET THEN
            REPEAT
                ReservationQty += ReservEntry."Quantity (Base)";
            UNTIL ReservEntry.NEXT = 0;
        EXIT(ReservationQty)
    end;

    Procedure CBR_InsertTrackingLines()
    var
        RecItemJournalLine: Record "Item Journal Line";
        //RecSalesLine: Record "Sales Line";
        //SalesDocStatus: Enum "Sales Document Status";
        ReservationEntry: Record "Reservation Entry";
        ErrorTable: Record "Error Message";
        ItemRec: Record Item;
    begin
        CBR_DeleteReservationEntry(Rec);
        RecItemJournalLine.RESET;
        RecItemJournalLine.SETRANGE("Journal Template Name", 'PHYS. INVE');
        RecItemJournalLine.SETFILTER(Quantity, '>%1', 0);
        IF RecItemJournalLine.FINDSET THEN
            REPEAT
                IF ItemRec.GET(RecItemJournalLine."Item No.") THEN BEGIN
                    IF ItemRec.Type = ItemRec.Type::Inventory THEN BEGIN
                        CBR_DeleteUnusedReservationEntry(ItemRec."No.");//AGT_DS_021523
                        CBR_UpdateSalesLineWithFullCasePackQty(RecItemJournalLine);
                        CBR_AutoFillTrackingLines(RecItemJournalLine, ErrorTable);
                    END;
                END;
            UNTIL RecItemJournalLine.NEXT = 0;
    end;

    local procedure CBR_UpdateSalesLineWithFullCasePackQty(VAR ItemJournalLine_L: Record "Item Journal Line"): Boolean
    var
        AvablLotQty: Decimal;
        ReservEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ILE1: Record "Item Ledger Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        LotQty: Decimal;
        QtyChek: Boolean;
        QtyChek1: Boolean;
        TotalILEQty: Decimal;
        ReserveQty: Decimal;
        ItemJournalLineRec: Record "Item Journal Line";
        CasePackQty: Decimal;
        ItemRec: Record Item;
        IUoM: Record "Item Unit of Measure";
        CurrLotNo: Code[20];
        ILERemainingQty: Decimal;
        AvaliablecasePackQty: Decimal;
        TotAvaliable: Decimal;
    begin
        TotalILEQty := 0;
        ReserveQty := 0;
        CurrLotNo := '';
        TotalILEQty := 0;
        TotAvaliable := 0;
        ItemRec.GET(ItemJournalLine_L."Item No.");


        ItemLedgerEntry.RESET;
        ItemLedgerEntry.SETRANGE("Item No.", ItemJournalLine_L."Item No.");
        ItemLedgerEntry.SETFILTER("Remaining Quantity", '>%1', 0);
        IF ItemLedgerEntry.FINDSET THEN BEGIN
            ItemLedgerEntry.CALCSUMS("Remaining Quantity");
            TotalILEQty := ItemLedgerEntry."Remaining Quantity";
        END;

        ReservEntry.RESET;
        ReservEntry.SETRANGE("Item No.", ItemJournalLine_L."Item No.");
        ReservEntry.SETRANGE("Location Code", ItemJournalLine_L."Location Code");
        ReservEntry.SETFILTER("Lot No.", '<>%1', '');
        ReservEntry.SETRANGE("Source Type", DATABASE::"Item Journal Line");
        IF ReservEntry.FINDSET THEN
            REPEAT
                ReserveQty += ReservEntry."Quantity (Base)";
            UNTIL ReservEntry.NEXT = 0;

        TotAvaliable := TotalILEQty + ReserveQty;

        IF ItemJournalLine_L.Quantity > TotAvaliable THEN BEGIN
            ItemLedgerEntry.RESET;
            ItemLedgerEntry.SETCURRENTKEY("Expiration Date");
            ItemLedgerEntry.SETRANGE("Item No.", ItemJournalLine_L."Item No.");
            ItemLedgerEntry.SETFILTER("Remaining Quantity", '>%1', 0);
            IF ItemLedgerEntry.FINDSET THEN
                REPEAT
                    AvablLotQty := 0;
                    LotQty := 0;
                    ILERemainingQty := 0;
                    IF CurrLotNo <> ItemLedgerEntry."Lot No." THEN BEGIN
                        ILE1.RESET;
                        ILE1.SETCURRENTKEY(ILE1."Expiration Date");
                        ILE1.SETRANGE("Item No.", ItemJournalLine_L."Item No.");
                        ILE1.SETRANGE("Lot No.", ItemLedgerEntry."Lot No.");
                        ILE1.SETFILTER("Remaining Quantity", '>%1', 0);
                        IF ILE1.FINDFIRST THEN BEGIN
                            ILE1.CALCSUMS("Remaining Quantity");
                            LotQty := CBR_GetReservationQty(ItemJournalLine_L, ILE1);
                            AvablLotQty := ILE1."Remaining Quantity" + LotQty;
                            IF ItemJournalLine_L."Unit of Measure Code" <> ItemRec."Base Unit of Measure" THEN
                                CasePackQty += (AvablLotQty DIV ItemJournalLine_L."Qty. per Unit of Measure")
                            ELSE BEGIN
                                IF ItemJournalLine_L.Quantity > AvablLotQty THEN
                                    CasePackQty += AvablLotQty;
                            END;
                        END;
                    END;
                    CurrLotNo := ItemLedgerEntry."Lot No.";
                UNTIL (ItemLedgerEntry.NEXT = 0);

            //ItemJournalLine_L.VALIDATE(Quantity, CasePackQty);
            //SalesLine.MODIFY;
            EXIT(TRUE);
        END
    end;

    local procedure CBR_AutoFillTrackingLines(RecItemJournalLine_L: Record "Item Journal Line"; VAR ErrorTable: Record "Error Message"): Boolean
    var
        AvablLotQty: Decimal;
        ReservEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ILE1: Record "Item Ledger Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        LotQty: Decimal;
        TotalILEQty: Decimal;
        RequiredSaleLineQty: Decimal;
        ReserveQty: Decimal;
        SalesLineRec: Record "Sales Line";
        QtytoAssign: Decimal;
        CasePackQty: Decimal;
        ItemRec: Record Item;
        CurrLotNo: Code[20];
        lastentryNo: Integer;
        ILERemainingQty: Decimal;
        SalesHeader_L: Record "Sales Header";
    begin
        TotalILEQty := 0;
        ReserveQty := 0;
        ShowMessage := false;
        ItemLedgerEntry.RESET;
        ItemLedgerEntry.SETRANGE("Item No.", RecItemJournalLine_L."Item No.");
        ItemLedgerEntry.SetRange("Location Code", RecItemJournalLine_L."Location Code");
        ItemLedgerEntry.SETFILTER("Remaining Quantity", '>%1', 0);
        IF ItemLedgerEntry.FINDSET THEN BEGIN
            ItemLedgerEntry.CALCSUMS("Remaining Quantity");
            TotalILEQty := ItemLedgerEntry."Remaining Quantity";
        END;
        //AGT_DS_021523
        ReservEntry.RESET;
        ReservEntry.SETRANGE("Item No.", RecItemJournalLine_L."Item No.");
        ReservEntry.SETRANGE("Location Code", RecItemJournalLine_L."Location Code");
        ReservEntry.SETRANGE("Source Type", DATABASE::"Item Journal Line");
        IF ReservEntry.FINDSET THEN
            REPEAT
                ReserveQty += ReservEntry."Quantity (Base)";
            UNTIL ReservEntry.NEXT = 0;

        CurrLotNo := '';
        RequiredSaleLineQty := RecItemJournalLine_L.Quantity;

        ReservEntry.Reset();
        if ReservEntry.FindLast() then
            lastentryNo := ReservEntry."Entry No.";

        ItemLedgerEntry.RESET;
        ItemLedgerEntry.SETCURRENTKEY("Expiration Date");
        ItemLedgerEntry.SETRANGE("Item No.", RecItemJournalLine_L."Item No.");
        ItemLedgerEntry.SetRange("Location Code", RecItemJournalLine_L."Location Code");
        ItemLedgerEntry.SETFILTER("Remaining Quantity", '>%1', 0);
        IF ItemLedgerEntry.FINDSET THEN
            REPEAT

                AvablLotQty := 0;
                LotQty := 0;
                ILERemainingQty := 0;

                IF CurrLotNo <> ItemLedgerEntry."Lot No." THEN BEGIN
                    ILE1.RESET;
                    ILE1.SETCURRENTKEY(ILE1."Expiration Date");
                    ILE1.SETRANGE("Item No.", RecItemJournalLine_L."Item No.");
                    ILE1.SETRANGE("Lot No.", ItemLedgerEntry."Lot No.");
                    ILE1.SETFILTER("Remaining Quantity", '>%1', 0);
                    IF ILE1.FINDFIRST THEN BEGIN
                        ILE1.CALCSUMS("Remaining Quantity");
                        LotQty := CBR_GetReservationQty(RecItemJournalLine_L, ILE1);
                        AvablLotQty := ILE1."Remaining Quantity" + LotQty;
                        ItemRec.GET(ILE1."Item No.");
                        IF RecItemJournalLine_L."Unit of Measure Code" <> ItemRec."Base Unit of Measure" THEN BEGIN
                            CasePackQty := (AvablLotQty DIV RecItemJournalLine_L."Qty. per Unit of Measure");
                            AvablLotQty := (CasePackQty * RecItemJournalLine_L."Qty. per Unit of Measure");
                        END;

                        IF RequiredSaleLineQty > AvablLotQty THEN BEGIN
                            QtytoAssign := AvablLotQty;
                            CBR_CreateReservationEntry(ReservEntry, lastentryNo, ILE1, RecItemJournalLine_L, QtytoAssign);
                        END;
                        IF RequiredSaleLineQty <= AvablLotQty THEN BEGIN
                            QtytoAssign := RequiredSaleLineQty;
                            CBR_CreateReservationEntry(ReservEntry, lastentryNo, ILE1, RecItemJournalLine_L, QtytoAssign);
                            EXIT;
                        END;

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
            CBR_InsertErrorLog(RecItemJournalLine_L, RequiredSaleLineQty, ErrorTable);
    end;

    local procedure CBR_InsertErrorLog(LocItemJournalLine: Record "Item Journal Line"; TotalQuantity: Integer; VAR ErrorTable: Record "Error Message")
    begin
        ErrorTable.INIT;
        IF ErrorTable.FINDLAST THEN
            ErrorTable.ID := ErrorTable.ID + 1
        ELSE
            ErrorTable.ID += 1;
        ErrorTable."Record ID" := LocItemJournalLine.RECORDID;
        ErrorTable."Field Number" := LocItemJournalLine.FIELDNO(LocItemJournalLine.Quantity);
        ErrorTable."Message Type" := ErrorTable."Message Type"::Information;
        ErrorTable.Description := 'Enough Lot Quantity is not available to fully assign the Sales Line Quantity ' + FORMAT(LocItemJournalLine.Quantity) + ' for Item ' + LocItemJournalLine."Item No." + ' , Balance Lot Quantity is ' + FORMAT(ABS(TotalQuantity));
        ErrorTable."Table Number" := DATABASE::"Sales Line";
        ErrorTable."Field Name" := LocItemJournalLine.FIELDNAME(Quantity);
        ErrorTable."Table Name" := LocItemJournalLine.TABLENAME;
        ErrorTable.INSERT;
    end;

    procedure CBR_DeleteReservationEntry(ItemJournalLine_L: Record "Item Journal Line")
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.RESET;
        ReservEntry.SETRANGE("Source Type", DATABASE::"Item Journal Line");
        ReservEntry.SETRANGE("Source ID", ItemJournalLine_L."Journal Template Name");
        IF ReservEntry.FINDSET THEN
            ReservEntry.DELETEALL;
    end;

    procedure CBR_DeleteUnusedReservationEntry(ItemNo: Code[20])
    var
        recItemJournalLine: Record "Item Journal Line";
    begin
        recReservationEntry.RESET;
        recReservationEntry.SETRANGE("Item No.", ItemNo);
        IF recReservationEntry.FINDSET THEN
            REPEAT
                recItemJournalLine.RESET;
                recItemJournalLine.SETRANGE("Journal Template Name", recReservationEntry."Source ID");
                IF NOT recItemJournalLine.FINDSET THEN
                    recReservationEntry.DELETE;
            UNTIL recReservationEntry.NEXT = 0;
    end;

    local procedure CBR_CreateReservationEntry(var ReservEntry: Record "Reservation Entry"; lastentryNo: Integer; ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine_L: Record "Item Journal Line"; QtytoAssign: Decimal)
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        ReservEntry."Entry No." := lastentryNo + 1;
        ReservEntry.Validate("Item No.", ItemLedgerEntry."Item No.");
        ReservEntry.Validate("Location Code", ItemLedgerEntry."Location Code");
        ReservEntry.SetSource(DATABASE::"Item Journal Line", ItemJournalLine_L."Entry Type".AsInteger(), ItemJournalLine_L."Journal Template Name", ItemJournalLine_L."Line No.", ItemJournalLine_L."Journal Batch Name", 0);
        ReservEntry.Validate("Reservation Status", ReservEntry."Reservation Status"::Prospect);
        ReservEntry.Validate("Creation Date", WorkDate());
        ReservEntry.Validate("Created By", UserId);
        ReservEntry.TestField("Qty. per Unit of Measure");
        ReservEntry.Validate("Qty. per Unit of Measure", ItemJournalLine_L."Qty. per Unit of Measure");
        ReservEntry.Quantity := CreateReservEntry.SignFactor(ReservEntry) * QtytoAssign;
        ReservEntry.VALIDATE("Quantity (Base)", CreateReservEntry.SignFactor(ReservEntry) * QtytoAssign);
        If ItemJournalLine_L."Entry Type" = ItemJournalLine_L."Entry Type"::"Negative Adjmt." then
            ReservEntry.VALIDATE("Lot No.", ItemLedgerEntry."Lot No.");
        If ItemJournalLine_L."Entry Type" = ItemJournalLine_L."Entry Type"::"Positive Adjmt." then
            ReservEntry.VALIDATE("Lot No.", 'LOT-NA');
        ReservEntry.Validate("Expiration Date", ItemLedgerEntry."Expiration Date");
        ReservEntry.Validate("Shipment Date", ItemJournalLine_L."Posting Date");//AGT_DS02152023
        ReservEntry.Validate(Positive, false);
        ReservEntry.Validate("Item Tracking", ReservEntry."Item Tracking"::"Lot No.");
        if ReservEntry.Insert() then
            ShowMessage := true;
    end;



    var
        recReservationEntry: Record "Reservation Entry";
        ShowMessage: Boolean;
}