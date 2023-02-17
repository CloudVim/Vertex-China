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

            action(DeleteIJL)
            {
                ApplicationArea = All;
                Caption = 'Delete_Reservation';
                Promoted = true;
                Image = Track;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    ItemJourLine: Record "Item Journal Line";
                    ReservationEntry_L: Record "Reservation Entry";
                begin
                    // ItemJourLine.Reset();
                    // ItemJourLine.SetRange("Journal Template Name", 'PHYS. INVE');
                    // ItemJourLine.SetRange("Journal Batch Name", 'DEFAULT');
                    // If ItemJourLine.FindSet() then
                    //    ItemJourLine.DeleteAll();
                    ReservationEntry_L.Reset();
                    ReservationEntry_L.SetRange("Source Type", 83);
                    ReservationEntry_L.SetRange("Source ID", 'PHYS. INVE');
                    ReservationEntry_L.SetRange("Source Batch Name", 'DEFAULT');
                    If ReservationEntry_L.FindSet() then
                        ReservationEntry_L.DeleteAll();
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
        LocCodeVar: Code[50];

    begin
        Clear(LocCodeVar);
        CBR_DeleteReservationEntry(Rec);
        RecItemJournalLine.SetCurrentKey("Location Code");
        RecItemJournalLine.SETRANGE("Journal Template Name", 'PHYS. INVE');
        RecItemJournalLine.SETFILTER(Quantity, '>%1', 0);
        IF RecItemJournalLine.FINDSET THEN
            REPEAT
                IF LocCodeVar <> RecItemJournalLine."Location Code" then begin

                    CBR_AutoFillTrackingLines(RecItemJournalLine, ErrorTable);//Different B|IN
                    LocCodeVar := RecItemJournalLine."Location Code";
                End;
            UNTIL RecItemJournalLine.NEXT = 0;
    end;


    local procedure CBR_AutoFillTrackingLines(RecItemJournalLine_L1: Record "Item Journal Line"; VAR ErrorTable: Record "Error Message"): Boolean
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
        RecItemJournalLine_L: Record "Item Journal Line";
        SalesHeader_L: Record "Sales Header";
        BinCode_L: Text;
        LotFound: Boolean;
    begin
        TotalILEQty := 0;
        ReserveQty := 0;
        ShowMessage := false;
        //AGT_DS_021723
        RecItemJournalLine_L.Reset();
        RecItemJournalLine_L.SetRange("Journal Template Name", RecItemJournalLine_L1."Journal Template Name");
        RecItemJournalLine_L.SetRange("Journal Batch Name", RecItemJournalLine_L1."Journal Batch Name");
        RecItemJournalLine_L.SetRange("Item No.", RecItemJournalLine_L1."Item No.");
        RecItemJournalLine_L.SetRange("Location Code", RecItemJournalLine_L1."Location Code");
        If RecItemJournalLine_L.FindSet() then
            repeat
                If BinCode_L <> RecItemJournalLine_L."Bin Code" then begin
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

                    If RecItemJournalLine_L."Entry Type" = RecItemJournalLine_L."Entry Type"::"Positive Adjmt." then//AGT_DS
                        CBR_CreateReservationEntry(ReservEntry, lastentryNo, ILE1, RecItemJournalLine_L, RequiredSaleLineQty);

                    If RecItemJournalLine_L."Entry Type" = RecItemJournalLine_L."Entry Type"::"Negative Adjmt." then begin//AGT_DS
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


                                        IF RequiredSaleLineQty > AvablLotQty THEN BEGIN
                                            QtytoAssign := AvablLotQty;
                                            CBR_CreateReservationEntry(ReservEntry, lastentryNo, ILE1, RecItemJournalLine_L, QtytoAssign);
                                        END;
                                        IF RequiredSaleLineQty <= AvablLotQty THEN BEGIN
                                            LotFound := true;
                                            QtytoAssign := RequiredSaleLineQty;
                                            CBR_CreateReservationEntry(ReservEntry, lastentryNo, ILE1, RecItemJournalLine_L, QtytoAssign);
                                            // If LotFound then
                                            //     EXIT;
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
                    BinCode_L := RecItemJournalLine_L."Bin Code";
                end
            Until RecItemJournalLine_L.Next() = 0;
    end;

    local procedure CBR_InsertErrorLog(LocItemJournalLine: Record "Item Journal Line"; TotalQuantity: Integer; VAR ErrorTable: Record "Error Message")
    begin
        ErrorTable.INIT;
        IF ErrorTable.FINDLAST THEN
            ErrorTable.ID := ErrorTable.ID + 1
        ELSE
            ErrorTable.ID += 1;
        ErrorTable."Record ID" := LocItemJournalLine.RECORDID;
        //ErrorTable."Field Number" := LocItemJournalLine.FIELDNO(LocItemJournalLine.Quantity);

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
        ReservEntry.SetRange("Source Batch Name", ItemJournalLine_L."Journal Batch Name");
        IF ReservEntry.FINDSET THEN
            ReservEntry.DELETEALL;
    end;
    //AGT_DS_021623
    // procedure CBR_DeleteUnusedReservationEntry(ItemNo: Code[20])
    // var
    //     recItemJournalLine: Record "Item Journal Line";
    // begin
    //     recReservationEntry.RESET;
    //     recReservationEntry.SETRANGE("Item No.", ItemNo);
    //     IF recReservationEntry.FINDSET THEN
    //         REPEAT
    //             recItemJournalLine.RESET;
    //             recItemJournalLine.SETRANGE("Journal Template Name", recReservationEntry."Source ID");
    //             IF NOT recItemJournalLine.FINDSET THEN
    //                 recReservationEntry.DELETE;
    //         UNTIL recReservationEntry.NEXT = 0;
    // end;

    local procedure CBR_CreateReservationEntry(var ReservEntry: Record "Reservation Entry"; lastentryNo: Integer; ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine_L: Record "Item Journal Line"; QtytoAssign: Decimal)
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        ReservEntry."Entry No." := lastentryNo + 1;
        If ItemJournalLine_L."Entry Type" = ItemJournalLine_L."Entry Type"::"Negative Adjmt." then
            ReservEntry.Validate("Item No.", ItemLedgerEntry."Item No.");

        If ItemJournalLine_L."Entry Type" = ItemJournalLine_L."Entry Type"::"Positive Adjmt." then//AGT_DS
            ReservEntry.Validate("Item No.", ItemJournalLine_L."Item No.");

        If ItemJournalLine_L."Entry Type" = ItemJournalLine_L."Entry Type"::"Negative Adjmt." then
            ReservEntry.Validate("Location Code", ItemLedgerEntry."Location Code");

        If ItemJournalLine_L."Entry Type" = ItemJournalLine_L."Entry Type"::"Positive Adjmt." then//AGT_DS
            ReservEntry.Validate("Location Code", ItemJournalLine_L."Location Code");

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

        If ItemJournalLine_L."Entry Type" = ItemJournalLine_L."Entry Type"::"Negative Adjmt." then
            ReservEntry.Validate("Expiration Date", ItemLedgerEntry."Expiration Date");

        If ItemJournalLine_L."Entry Type" = ItemJournalLine_L."Entry Type"::"Positive Adjmt." then
            ReservEntry.Validate("Expiration Date", WorkDate());//DS

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