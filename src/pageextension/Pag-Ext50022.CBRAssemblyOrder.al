pageextension 50022 "CBR_AssemblyOrder" extends "Assembly Order"
{
    layout
    {

    }

    actions
    {
        addafter(Action80)
        {
            action("Create Tracking Line")
            {
                Caption = 'Create Tracking Line';
                Image = Track;
                ApplicationArea = Basic, Suite;
                trigger OnAction()
                begin
                    InsertTrackingLines; //CBR_SS 0913-1 >><<
                end;
            }
        }
        addbefore("Update Unit Cost_Promoted")
        {
            actionref(CreateTrackingLine; "Create Tracking Line")
            {
            }
        }

    }

    var
        myInt: Integer;
        recReservationEntry: Record "Reservation Entry";

    local procedure InsertTrackingLines()
    var
        Text001: Label 'Item tracking Lines for the Order: %1  has been created successfully';
        Text002: Label 'Would you like to auto fill the tracking line for the Order %1';
        RecAssemblyLine: Record "Assembly Line";
        ReservationEntry: Record "Reservation Entry";
        ErrorTable: Record "Error Message" temporary;
        ItemRec: Record Item;
        RecAssemblyHeader: Record "Assembly Header";
    begin

        Rec.TestField(Status, Rec.Status::Open);
        if not Confirm(Text002, false, Rec."No.") then
            exit;
        DeleteReservationEntry(Rec);

        RecAssemblyLine.Reset;
        RecAssemblyLine.SetRange("Document Type", RecAssemblyLine."Document Type"::Order);
        RecAssemblyLine.SetRange("Document No.", rec."No.");
        RecAssemblyLine.SetRange(Type, RecAssemblyLine.Type::Item);
        RecAssemblyLine.SetFilter(Quantity, '>%1', 0);
        if RecAssemblyLine.FindSet then
            repeat
                if ItemRec.Get(RecAssemblyLine."No.") then begin
                    if ItemRec.Type = ItemRec.Type::Inventory then begin
                        DeleteUnusedReservationEntry(ItemRec."No."); // Delete old reservation lines (if any)
                        AutoFillTrackingLines(RecAssemblyLine, ErrorTable);
                    end;
                end;
            until RecAssemblyLine.Next = 0;

        Message('Tracking lines for Sales order : %1 have been created successfully', Rec."No.");

    end;

    procedure DeleteReservationEntry(AssemblyHeader: Record "Assembly Header")
    var
        ReservEntry: Record "Reservation Entry";
    begin

        ReservEntry.Reset;
        ReservEntry.SetRange("Source Type", DATABASE::"Assembly Line");
        ReservEntry.SetRange("Source ID", AssemblyHeader."No.");
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Surplus);
        if ReservEntry.FindSet then
            ReservEntry.DeleteAll;

    end;


    procedure DeleteUnusedReservationEntry(ItemNo: Code[20])
    var
        recAssemblyLine: Record "Assembly Line";
    begin

        recReservationEntry.Reset;
        recReservationEntry.SetRange("Source Type", DATABASE::"Assembly Line");
        recReservationEntry.SetRange("Item No.", ItemNo);
        if recReservationEntry.FindSet then
            repeat
                recAssemblyLine.Reset;
                recAssemblyLine.SetRange("Document No.", recReservationEntry."Source ID");
                if not recAssemblyLine.FindSet then
                    recReservationEntry.Delete;
            until recReservationEntry.Next = 0;

    end;

    local procedure AutoFillTrackingLines(AssemblyLine: Record "Assembly Line"; var ErrorTable: Record "Error Message" temporary): Boolean
    var
        AvablSerialQty: Decimal;
        ReservEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ILE1: Record "Item Ledger Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        SerialQty: Decimal;
        TotalILEQty: Decimal;
        RequiredAssemblyLineQty: Decimal;
        ReserveQty: Decimal;
        recAssemblyLine: Record "Assembly Line";
        QtytoAssign: Decimal;
        CasePackQty: Decimal;
        ItemRec: Record Item;
        CurrLotNo: Code[20];
        CurrSerialNo: Code[20];
        lastentryNo: Integer;
        ILERemainingQty: Decimal;
    begin
        //CBR_SS 0913-1 <<
        TotalILEQty := 0;
        ReserveQty := 0;


        ItemLedgerEntry.Reset;
        ItemLedgerEntry.SetRange("Item No.", AssemblyLine."No.");
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
        if ItemLedgerEntry.FindSet then begin
            ItemLedgerEntry.CalcSums("Remaining Quantity");
            TotalILEQty := ItemLedgerEntry."Remaining Quantity";
        end;

        ReservEntry.Reset;
        ReservEntry.SetRange("Item No.", AssemblyLine."No.");
        ReservEntry.SetRange("Location Code", AssemblyLine."Location Code");
        ReservEntry.SetRange("Source Type", DATABASE::"Assembly Line");
        if ReservEntry.FindSet then
            repeat
                ReserveQty += ReservEntry."Quantity (Base)";
            until ReservEntry.Next = 0;
        //-362

        CurrSerialNo := '';
        CurrLotNo := '';
        // AGT_DS_122122++Subhash++
        ReservEntry.Reset();
        if ReservEntry.FindLast() then
            lastentryNo := ReservEntry."Entry No.";
        //  AGT_DS_122122--Subhash--

        RequiredAssemblyLineQty := AssemblyLine."Quantity (Base)";


        ItemLedgerEntry.Reset;
        ItemLedgerEntry.SetCurrentKey("Expiration Date");
        ItemLedgerEntry.SetRange("Item No.", AssemblyLine."No.");
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
        if ItemLedgerEntry.FindSet then
            repeat
                //AGT_DS_122122++
                // lastentryNo := 0;
                // ReservEntry.Reset();
                // if ReservEntry.FindLast() then
                //     lastentryNo := ReservEntry."Entry No.";
                //AGT_DS_122122--
                AvablSerialQty := 0;
                SerialQty := 0;
                ILERemainingQty := 0;
                if (CurrSerialNo <> ItemLedgerEntry."Serial No.")
                  or (CurrLotNo <> ItemLedgerEntry."Lot No.") then begin  // Only trigger once for each Lot from the ILE
                    ILE1.Reset;
                    ILE1.SetCurrentKey(ILE1."Expiration Date");
                    ILE1.SetRange("Item No.", AssemblyLine."No.");
                    if ItemLedgerEntry."Lot No." <> '' then
                        ILE1.SetRange("Lot No.", ItemLedgerEntry."Lot No.");
                    if ItemLedgerEntry."Serial No." <> '' then
                        ILE1.SetRange("Serial No.", ItemLedgerEntry."Serial No.");
                    ILE1.SetFilter("Remaining Quantity", '>%1', 0);
                    if ILE1.FindFirst then begin
                        ILE1.CalcSums("Remaining Quantity");
                        SerialQty := GetReservationQty1(AssemblyLine, ILE1);
                        AvablSerialQty := ILE1."Remaining Quantity" + SerialQty;  // Get the total avaliable quantity
                        IF AvablSerialQty > 0 THEN begin  // If avaliable quantity is not zero
                            ItemRec.Get(ILE1."Item No.");
                            if AssemblyLine."Unit of Measure Code" <> ItemRec."Base Unit of Measure" then begin  // Check if the item is sold in different UOM
                                CasePackQty := (AvablSerialQty div AssemblyLine."Qty. per Unit of Measure");
                                AvablSerialQty := (CasePackQty * AssemblyLine."Qty. per Unit of Measure");
                            end;

                            if RequiredAssemblyLineQty > AvablSerialQty then begin
                                QtytoAssign := AvablSerialQty;
                                // CreateReservEntry.CreateReservEntryFor(DATABASE::"Assembly Line", 0, AssemblyLine."Document No.", '', 0,
                                //AssemblyLine."Line No.", AssemblyLine."Qty. per Unit of Measure", QtytoAssign, QtytoAssign, ILE1."Serial No.", ILE1."Lot No.");

                                CBRCreateReservationEntry(ReservEntry, lastentryNo, ILE1, AssemblyLine, QtytoAssign);
                                //CreateReservEntry.CreateEntry(AssemblyLine."No.", ILE1."Variant Code", AssemblyLine."Location Code", '', 0D, 0D, 0, ReservEntry."Reservation Status"::Surplus);
                            end;
                            if RequiredAssemblyLineQty <= AvablSerialQty then begin
                                QtytoAssign := RequiredAssemblyLineQty;
                                // CreateReservEntry.CreateReservEntryFor(DATABASE::"Assembly Line", "Document Type", AssemblyLine."Document No.", '', 0, AssemblyLine."Line No.", AssemblyLine."Qty. per Unit of Measure", QtytoAssign, QtytoAssign, ILE1."Serial No.", ILE1."Lot No.");
                                CBRCreateReservationEntry(ReservEntry, lastentryNo, ILE1, AssemblyLine, QtytoAssign);

                                //CreateReservEntry.CreateEntry(AssemblyLine."No.", ILE1."Variant Code", AssemblyLine."Location Code", '', 0D, 0D, 0, ReservEntry."Reservation Status"::Surplus);
                                exit;
                            end;

                            //Reduce the required qty after the previous allocation ++
                            if RequiredAssemblyLineQty > AvablSerialQty then
                                RequiredAssemblyLineQty := RequiredAssemblyLineQty - AvablSerialQty
                            else
                                RequiredAssemblyLineQty := AvablSerialQty;
                        end;// If avaliable quantity is not zero or negative
                    end;
                end;

                CurrSerialNo := ItemLedgerEntry."Serial No.";
                CurrLotNo := ItemLedgerEntry."Lot No.";
                lastentryNo := ReservEntry."Entry No.";//AGT_DS_122222
            until ItemLedgerEntry.Next = 0;

        if RequiredAssemblyLineQty <> 0 then
            InsertErrorLog(AssemblyLine, RequiredAssemblyLineQty, ErrorTable);
        //CBR_SS 0913-1 <<
    end;

    local procedure AutoFillTrackingHeader(AssemblyHeader: Record "Assembly Header"; var ErrorTable: Record "Error Message" temporary): Boolean
    var
        AvablSerialHeaderQty: Decimal;
        ReservEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ILE1: Record "Item Ledger Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        SerialHeaderQty: Decimal;
        TotalILEHeaderQty: Decimal;
        RequiredAssemblyHeaderQty: Decimal;
        ReserveHeaderQty: Decimal;
        recAssemblyLine: Record "Assembly Line";
        QtytoAssign: Decimal;
        CasePackQty: Decimal;
        ItemRec: Record Item;
        CurrHeaderLotNo: Code[20];
        CurrHeaderSerialNo: Code[20];
        ILERemainingHeaderQty: Decimal;
        I: Integer;
        LotNo: Code[20];
        SerialNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
        lastentryNo: Integer;
    begin



    end;

    local procedure InsertErrorLog(LocAssemblyLine: Record "Assembly Line"; TotalQuantity: Decimal; var ErrorTable: Record "Error Message" temporary)
    begin

        ErrorTable.Init;
        if ErrorTable.FindLast then
            ErrorTable.ID := ErrorTable.ID + 1
        else
            ErrorTable.ID += 1;
        ErrorTable."Record ID" := LocAssemblyLine.RecordId; //RecRef.RECORDID;
        ErrorTable."Field Number" := LocAssemblyLine.FieldNo(LocAssemblyLine.Quantity);
        ErrorTable."Message Type" := ErrorTable."Message Type"::Information;
        ErrorTable.Description := 'Enough Lot Quantity is not available to fully assign the Sales Line Quantity ' + Format(LocAssemblyLine."Quantity (Base)") + ' for Item ' + LocAssemblyLine."No." + ' , Balance Lot Quantity is ' + Format(Abs(TotalQuantity));
        ErrorTable."Table Number" := DATABASE::"Assembly Line";
        ErrorTable."Field Name" := LocAssemblyLine.FieldName("Quantity (Base)");
        ErrorTable."Table Name" := LocAssemblyLine.TableName;
        ErrorTable.Insert;

    end;

    local procedure GetReservationQty1(AssemblyLine: Record "Assembly Line"; ILE: Record "Item Ledger Entry"): Decimal
    var
        ReservationQty: Decimal;
        ReservEntry: Record "Reservation Entry";
    begin

        ReservEntry.Reset;
        ReservEntry.SetRange("Item No.", AssemblyLine."No.");
        ReservEntry.SetRange("Location Code", AssemblyLine."Location Code");
        ReservEntry.SetRange("Source Type", DATABASE::"Assembly Line");
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

    local procedure GetReservationHeaderQty(AssemblyHeader: Record "Assembly Header"; ILE: Record "Item Ledger Entry"): Decimal
    var
        ReservationQty: Decimal;
        ReservEntry: Record "Reservation Entry";
    begin

        ReservEntry.Reset;
        ReservEntry.SetRange("Item No.", AssemblyHeader."Item No.");
        ReservEntry.SetRange("Location Code", AssemblyHeader."Location Code");
        ReservEntry.SetRange("Source Type", DATABASE::"Assembly Header");
        ReservEntry.SetRange("Serial No.", ILE."Serial No.");
        if ReservEntry.FindSet then
            repeat
                ReservationQty += ReservEntry."Quantity (Base)";
            until ReservEntry.Next = 0;
        exit(ReservationQty)

    end;

    local procedure InsertHeaderErrorLog(LocAssemblyHeader: Record "Assembly Header"; TotalHeaderQuantity: Integer; var ErrorTable: Record "Error Message" temporary)
    begin

        ErrorTable.Init;
        if ErrorTable.FindLast then
            ErrorTable.ID := ErrorTable.ID + 1
        else
            ErrorTable.ID += 1;
        ErrorTable."Record ID" := LocAssemblyHeader.RecordId; //RecRef.RECORDID;
        ErrorTable."Field Number" := LocAssemblyHeader.FieldNo(LocAssemblyHeader.Quantity);
        ErrorTable."Message Type" := ErrorTable."Message Type"::Information;
        ErrorTable.Description := 'Enough Lot Quantity is not available to fully assign the Sales Header Quantity ' +
        Format(LocAssemblyHeader."Quantity (Base)") + ' for Item ' + (LocAssemblyHeader."Item No.") + ' , Balance Lot Quantity is ' + Format(Abs(TotalHeaderQuantity));
        ErrorTable."Table Number" := DATABASE::"Assembly Header";
        ErrorTable."Field Name" := LocAssemblyHeader.FieldName("Quantity (Base)");
        ErrorTable."Table Name" := LocAssemblyHeader.TableName;
        ErrorTable.Insert;

    end;


    procedure DeleteUnusedReservEntry(ItemNo: Code[20])
    var
        recAssemblyHeader: Record "Assembly Header";
    begin

        recReservationEntry.Reset;
        recReservationEntry.SetRange("Item No.", ItemNo);
        if recReservationEntry.FindSet then
            repeat
                recAssemblyHeader.Reset;
                recAssemblyHeader.SetRange("No.", recReservationEntry."Source ID");
                if not recAssemblyHeader.FindSet then
                    recReservationEntry.Delete;
            until recReservationEntry.Next = 0;

    end;

    local procedure UpdateReservationEntry(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.Reset;
        ReservEntry.SetRange("Source ID", Rec."No.");
        ReservEntry.SetRange("Source Ref. No.", 0);
        ReservEntry.SetRange("Source Type", 900);
        if ReservEntry.FindFirst then begin
            ReservEntry."Reservation Status" := ReservEntry."Reservation Status"::Reservation;
            ReservEntry.Binding := ReservEntry.Binding::"Order-to-Order";
            ReservEntry.Positive := false;
            ReservEntry."Planning Flexibility" := ReservEntry."Planning Flexibility"::None;
            ReservEntry."Disallow Cancellation" := true;
            ReservEntry.Modify;
        end;
    end;

    local procedure CBRCreateReservationEntry(var ReservEntry: Record "Reservation Entry"; lastentryNo: Integer; ItemLedgerEntry: Record "Item Ledger Entry"; AssemblyLine: Record "Assembly Line"; QtytoAssign: Decimal)
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        ReservEntry."Entry No." := lastentryNo + 1;
        ReservEntry.Validate("Item No.", ItemLedgerEntry."Item No.");
        ReservEntry.Validate("Location Code", ItemLedgerEntry."Location Code");
        ReservEntry.SetSource(DATABASE::"Assembly Line", AssemblyLine."Document Type".AsInteger(), AssemblyLine."Document No.", AssemblyLine."Line No.", '', 0);
        ReservEntry.Validate("Reservation Status", ReservEntry."Reservation Status"::Surplus);
        ReservEntry.Validate("Creation Date", WorkDate());
        ReservEntry.Validate("Created By", UserId);
        ReservEntry.TestField("Qty. per Unit of Measure");
        ReservEntry.Validate("Qty. per Unit of Measure", AssemblyLine."Qty. per Unit of Measure");
        ReservEntry.Quantity := CreateReservEntry.SignFactor(ReservEntry) * QtytoAssign;
        ReservEntry.VALIDATE("Quantity (Base)", CreateReservEntry.SignFactor(ReservEntry) * QtytoAssign);
        ReservEntry.Validate("Serial No.", ItemLedgerEntry."Serial No.");//AGt.SS
        ReservEntry.VALIDATE("Lot No.", ItemLedgerEntry."Lot No.");
        ReservEntry.Validate("Expiration Date", ItemLedgerEntry."Expiration Date");
        ReservEntry.Insert();
    end;

    local procedure CBRCreateReservationEntry1(var ReservEntry: Record "Reservation Entry"; lastentryNo: Integer; ItemLedgerEntry: Record "Item Ledger Entry"; AssemblyHeader: Record "Assembly Header"; QtytoAssign: Decimal)
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        ReservEntry."Entry No." := lastentryNo + 1;
        ReservEntry.Validate("Item No.", ItemLedgerEntry."Item No.");
        ReservEntry.Validate("Location Code", ItemLedgerEntry."Location Code");
        ReservEntry.SetSource(DATABASE::"Sales Line", AssemblyHeader."Document Type".AsInteger(), AssemblyHeader."No.", 0, '', 0);
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
}