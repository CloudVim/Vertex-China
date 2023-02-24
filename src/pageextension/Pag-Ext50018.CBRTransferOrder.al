pageextension 50018 "CBR_TransferOrder" extends "Transfer Order"
{
    layout
    {
        addbefore("Shipment Date")
        {
            field("Total Qty."; Rec."Total Qty.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Total Qty. field.';
            }
        }
        addafter("In-Transit Code")
        {

            field("Reference No."; Rec."Reference No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Reference No. field.';
            }
        }
    }

    actions
    {//AGT_DS_010522
        addafter("Get Bin Content")
        {
            action("CBR CopyDocument")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Copy Document';
                Enabled = "Transfer-from Code" <> '';
                Image = CopyDocument;

                trigger OnAction()
                begin
                    CopyDocument();
                end;
            }
            action("Create Tracking Line")
            {
                Caption = 'Create Tracking Line';
                Image = Track;
                ApplicationArea = Basic, Suite;
                trigger OnAction()
                begin
                    if Confirm('Do you want to create reservation entries, Manually?', false) then begin
                        InsertTrackingLines; //CBR_SS 0913-1 >><<
                        Message('Reservation Entries has been created successfully.');
                    end;

                end;
            }
        }
        addafter("Get Bin Content_Promoted")
        {
            actionref(CopyDocument; "CBR CopyDocument")
            {
            }
            actionref(CreateTrackingLine; "Create Tracking Line")
            {
            }
        }
    }
    //AGT_DS_010522
    procedure CopyDocument()
    var
        CopyTransferDocument: Report "Copy Transfer Document";
    begin
        CopyTransferDocument.SetTransferHeader(Rec);
        CopyTransferDocument.RunModal();
    end;

    var
        recReservationEntry: Record "Reservation Entry";

    local procedure InsertTrackingLines()
    var
        RecTransferLine: Record "Transfer Line";
        ReservationEntry: Record "Reservation Entry";
        ErrorTable: Record "Error Message" temporary;
        ItemRec: Record Item;
        RecTransferHeader: Record "Transfer Header";
    begin
        DeleteReservationEntry(Rec);

        RecTransferLine.Reset;
        RecTransferLine.SetRange("Document No.", rec."No.");
        // RecTransferLine.SetRange(Type, RecTransferLine.Type::Item);
        RecTransferLine.SetFilter(Quantity, '>%1', 0);
        if RecTransferLine.FindSet then
            repeat
                AutoFillTrackingLines(RecTransferLine, ErrorTable);
            until RecTransferLine.Next = 0;
    end;

    procedure DeleteReservationEntry(TransferHeader: Record "Transfer Header")
    var
        ReservEntry: Record "Reservation Entry";
    begin

        ReservEntry.Reset;
        ReservEntry.SetRange("Source Type", 5741);
        ReservEntry.SetRange("Source ID", TransferHeader."No.");
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Surplus);
        if ReservEntry.FindSet then
            ReservEntry.DeleteAll;
    end;

    local procedure AutoFillTrackingLines(TransferLine: Record "Transfer Line"; var ErrorTable: Record "Error Message" temporary): Boolean
    var
        AvablSerialQty: Decimal;
        ReservEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ILE1: Record "Item Ledger Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        TotalILEQty: Decimal;
        RequiredTransferLineQty: Decimal;
        ReserveQty: Decimal;
        recTransferLine: Record "Assembly Line";
        QtytoAssign: Decimal;
        CasePackQty: Decimal;
        ItemRec: Record Item;
        CurrLotNo: Code[20];
        ILERemainingQty: Decimal;
        TransHead_L: Record "Transfer Header";
        SerialQty: Decimal;
        TotAvaliable: Decimal;
    begin
        //CBR_SS 0913-1 <<
        TotalILEQty := 0;
        ReserveQty := 0;
        SerialQty := 0;
        TotAvaliable := 0;

        If TransHead_L.Get(TransferLine."Document No.") then;
        ItemLedgerEntry.Reset;
        ItemLedgerEntry.SetRange("Item No.", TransferLine."Item No.");
        ItemLedgerEntry.SetRange("Location Code", TransHead_L."Transfer-from Code");
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
        if ItemLedgerEntry.FindSet then begin
            ItemLedgerEntry.CalcSums("Remaining Quantity");
            TotalILEQty := ItemLedgerEntry."Remaining Quantity";
        end;

        ReservEntry.Reset;
        ReservEntry.SetRange("Item No.", TransferLine."Item No.");
        ReservEntry.SetFilter("Location Code", '%1|%2', TransHead_L."Transfer-from Code", TransHead_L."Transfer-to Code");
        ReservEntry.SetRange("Source Type", 5741);
        ReservEntry.SetRange("Source Subtype", 0);
        if ReservEntry.FindSet then
            repeat
                ReserveQty += ReservEntry."Quantity (Base)";
            until ReservEntry.Next = 0;
        //-362
        CurrLotNo := '';
        // AGT_DS_122122++Subhash++
        // ReservEntry.Reset();
        // if ReservEntry.FindLast() then
        //     lastentryNo := ReservEntry."Entry No.";
        //  AGT_DS_122122--Subhash--

        RequiredTransferLineQty := TransferLine."Qty. to Ship (Base)";

        TotAvaliable := TotalILEQty + ReserveQty;

        IF TransferLine."Qty. to Ship (Base)" < TotAvaliable THEN BEGIN
            ItemLedgerEntry.Reset;
            ItemLedgerEntry.SetCurrentKey("Expiration Date");
            ItemLedgerEntry.SetRange("Item No.", TransferLine."Item No.");
            ItemLedgerEntry.SetRange("Location Code", TransHead_L."Transfer-from Code");
            ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
            if ItemLedgerEntry.FindSet then
                repeat
                    AvablSerialQty := 0;
                    ILERemainingQty := 0;
                    if (CurrLotNo <> ItemLedgerEntry."Lot No.") then begin  // Only trigger once for each Lot from the ILE
                        ILE1.Reset;
                        ILE1.SetCurrentKey(ILE1."Expiration Date");
                        ILE1.SetRange("Item No.", TransferLine."Item No.");
                        ILE1.SetRange("Location Code", TransHead_L."Transfer-from Code");

                        if ItemLedgerEntry."Lot No." <> '' then
                            ILE1.SetRange("Lot No.", ItemLedgerEntry."Lot No.");

                        ILE1.SetFilter("Remaining Quantity", '>%1', 0);
                        if ILE1.FindFirst then begin
                            ILE1.CalcSums("Remaining Quantity");
                            SerialQty := GetReservationQty1(TransferLine, ILE1);
                            AvablSerialQty := ILE1."Remaining Quantity" + SerialQty;  // Get the total avaliable quantity
                            IF AvablSerialQty > 0 THEN begin  // If avaliable quantity is not zero
                                ItemRec.Get(ILE1."Item No.");

                                if RequiredTransferLineQty > AvablSerialQty then begin
                                    QtytoAssign := AvablSerialQty;

                                    CBRCreateReservationEntry(ReservEntry, ILE1, TransferLine, QtytoAssign);
                                    //CreateReservEntry.CreateEntry(TransferLine."No.", ILE1."Variant Code", TransferLine."Location Code", '', 0D, 0D, 0, ReservEntry."Reservation Status"::Surplus);
                                end;
                                if RequiredTransferLineQty <= AvablSerialQty then begin
                                    QtytoAssign := RequiredTransferLineQty;
                                    CBRCreateReservationEntry(ReservEntry, ILE1, TransferLine, QtytoAssign);
                                    exit;
                                end;

                                //Reduce the required qty after the previous allocation ++
                                if RequiredTransferLineQty > AvablSerialQty then
                                    RequiredTransferLineQty := RequiredTransferLineQty - AvablSerialQty
                                else
                                    RequiredTransferLineQty := AvablSerialQty;
                            end;// If avaliable quantity is not zero or negative
                        end;
                    end;

                    CurrLotNo := ItemLedgerEntry."Lot No.";
                until ItemLedgerEntry.Next = 0;

            if RequiredTransferLineQty <> 0 then
                InsertErrorLog(TransferLine, RequiredTransferLineQty, ErrorTable);
            //CBR_SS 0913-1 <<
        end;
    End;

    local procedure GetReservationQty1(TransferLine: Record "Transfer Line"; ILE: Record "Item Ledger Entry"): Decimal
    var
        ReservationQty: Decimal;
        ReservEntry: Record "Reservation Entry";
        TransferHeader_L: Record "Transfer Header";
    begin
        If TransferHeader_L.Get(TransferLine."Document No.") then;
        ReservEntry.Reset;
        ReservEntry.SetRange("Item No.", TransferLine."Item No.");
        ReservEntry.SetRange("Location Code", TransferHeader_L."Transfer-from Code");
        ReservEntry.SetRange("Source Type", 5741);
        ReservEntry.SetRange("Source Subtype", 0);
        //ReservEntry.SETRANGE("Lot No.", ILE."Lot No.");
        if ILE."Lot No." <> '' then
            ReservEntry.SetRange("Lot No.", ILE."Lot No.");
        if ILE."Serial No." <> '' then
            ReservEntry.SetRange("Serial No.", ILE."Serial No.");
        if ReservEntry.FindSet then
            repeat
                ReservationQty += ReservEntry."Quantity (Base)";
            until ReservEntry.Next = 0;
        exit(ReservationQty)
    end;

    local procedure CBRCreateReservationEntry(var ReservEntry: Record "Reservation Entry"; ItemLedgerEntry: Record "Item Ledger Entry"; TransferLine: Record "Transfer Line"; QtytoAssign: Decimal)
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        TransferHeader_L: Record "Transfer Header";
        I: Integer;
    begin
        If TransferHeader_L.Get(TransferLine."Document No.") then;
        For I := 1 to 2 do begin
            ReservEntry."Entry No." := GetLastReservationEntryNo();
            ReservEntry.Validate("Item No.", ItemLedgerEntry."Item No.");
            If I = 1 then
                ReservEntry.Validate("Location Code", ItemLedgerEntry."Location Code")
            Else
                ReservEntry.Validate("Location Code", TransferHeader_L."Transfer-to Code");
            //ReservEntry.SetSource(DATABASE::"Sales Line", AssemblyHeader."Document Type".AsInteger(), AssemblyHeader."No.", 0, '', 0);
            ReservEntry."Source Type" := 5741;
            If I = 1 then begin
                ReservEntry."Source Subtype" := 0;
                ReservEntry.Positive := false;
                ReservEntry."Shipment Date" := Today;
                ReservEntry."Expected Receipt Date" := 0D;
            end Else begin
                ReservEntry."Source Subtype" := 1;
                ReservEntry.Positive := true;
                ReservEntry."Expected Receipt Date" := Today;
                ReservEntry."Shipment Date" := 0D;
            end;

            ReservEntry."Source ID" := TransferLine."Document No.";
            ReservEntry."Source Ref. No." := TransferLine."Line No.";
            ReservEntry."Source Batch Name" := '';
            ReservEntry."Source Prod. Order Line" := 0;
            ReservEntry.Validate("Reservation Status", ReservEntry."Reservation Status"::Surplus);
            ReservEntry.Validate("Creation Date", WorkDate());
            ReservEntry.Validate("Created By", UserId);
            ReservEntry.TestField("Qty. per Unit of Measure");
            ReservEntry.Validate("Qty. per Unit of Measure", 1);
            ReservEntry.Quantity := CreateReservEntry.SignFactor(ReservEntry) * QtytoAssign;
            ReservEntry.VALIDATE("Quantity (Base)", CreateReservEntry.SignFactor(ReservEntry) * QtytoAssign);
            ReservEntry.validate("Serial No.", ItemLedgerEntry."Serial No.");//AGT.SS

            ReservEntry.VALIDATE("Lot No.", ItemLedgerEntry."Lot No.");
            ReservEntry.Validate("Expiration Date", ItemLedgerEntry."Expiration Date");
            ReservEntry.Insert();
        end;
    end;

    local procedure InsertErrorLog(LocTransferLine: Record "Transfer Line"; TotalQuantity: Decimal; var ErrorTable: Record "Error Message" temporary)
    begin
        ErrorTable.Init;
        if ErrorTable.FindLast then
            ErrorTable.ID := ErrorTable.ID + 1
        else
            ErrorTable.ID += 1;
        ErrorTable."Record ID" := LocTransferLine.RecordId; //RecRef.RECORDID;
        //ErrorTable."Field Number" := LocTransferLine.FieldNo(LocTransferLine.Quantity);
        ErrorTable."Message Type" := ErrorTable."Message Type"::Information;
        ErrorTable.Description := 'Enough Lot Quantity is not available to fully assign the Sales Line Quantity ' + Format(LocTransferLine."Quantity (Base)") + ' for Item ' + LocTransferLine."Item No." + ' , Balance Lot Quantity is ' + Format(Abs(TotalQuantity));
        ErrorTable."Table Number" := DATABASE::"Assembly Line";
        ErrorTable."Field Name" := LocTransferLine.FieldName("Quantity (Base)");
        ErrorTable."Table Name" := LocTransferLine.TableName;
        ErrorTable.Insert;

    end;

    local procedure GetLastReservationEntryNo(): Integer
    var
        ReservEntry: Record "Reservation Entry";
        lastentryNo: Integer;
    Begin
        lastentryNo := 0;
        ReservEntry.Reset();
        if ReservEntry.FindLast() then
            lastentryNo := ReservEntry."Entry No." + 1;
        exit(lastentryNo);
    End;
}