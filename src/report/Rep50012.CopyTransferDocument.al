report 50012 "Copy Transfer Document"
{
    Caption = 'Copy Transfer Document';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        //  SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DocumentType; FromDocType)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Document Type';
                        ToolTip = 'Specifies the type of document that is processed by the report or batch job.';

                    }
                    field(DocumentNo; FromDocNo)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Document No.';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupDocNo;
                        end;
                    }
                }
            }
        }

        actions
        {
        }
        trigger OnOpenPage()
        begin
            Clear(FromDocNo);
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = ACTION::OK then
                if FromDocNo = '' then
                    Error(DocNoNotSerErr)
        end;
    }

    labels
    {
    }
    trigger OnPreReport()
    var
        myInt: Integer;
    begin
        CreatetransferOrderline();
    end;

    var
        TransferHeader: Record "Transfer Header";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        RecalculateLines: Boolean;
        Text000: Label 'The price information may not be reversed correctly, if you copy a %1. If possible copy a %2 instead or use %3 functionality.';
        Text001: Label 'Undo Shipment';
        Text002: Label 'Undo Return Receipt';
        DocNoNotSerErr: Label 'Select a document number to continue, or choose Cancel to close the page.';

    protected var
        FromDocType: Enum "Transfer Document Type From";
        FromDocNo: Code[20];
        FromDocNoOccurrence: Integer;
        FromDocVersionNo: Integer;



    local procedure LookupDocNo()
    begin
        case FromDocType of
            FromDocType::"Transfer Order":
                LookupTransferOrder();
            FromDocType::"Posted Transfer Shipments":
                LookupPostedTransferShipment();
            FromDocType::"Posted Transfer Receipt":
                LookupPostedTransferReceipt();
        end;
    end;

    local procedure LookupTransferOrder()
    var
        TransferHeader_L: Record "Transfer Header";
    begin
        TransferHeader_L.Reset();
        TransferHeader_L.SetFilter("No.", '<>%1', TransferHeader."No.");
        //TransferHeader_L.SetRange("Transfer-from Code", TransferHeader."Transfer-from Code");
        If TransferHeader_L.FindSet() then
            if PAGE.RunModal(5742, TransferHeader_L) = ACTION::LookupOK then
                FromDocNo := TransferHeader_L."No.";
    end;

    local procedure LookupPostedTransferShipment()
    Var
        TransferShipmentHeader_L: Record "Transfer Shipment Header";
    begin
        TransferShipmentHeader_L.Reset();
        //TransferShipmentHeader_L.SetRange("Transfer-from Code", TransferHeader."Transfer-from Code");
        If TransferShipmentHeader_L.FindSet() then
            if PAGE.RunModal(5752, TransferShipmentHeader_L) = ACTION::LookupOK then
                FromDocNo := TransferShipmentHeader_L."No.";
    end;

    local procedure LookupPostedTransferReceipt()
    Var
        TransferReceiptHeader_L: Record "Transfer Receipt Header";
    begin
        TransferReceiptHeader_L.Reset();
        //TransferReceiptHeader_L.SetRange("Transfer-from Code", TransferHeader."Transfer-from Code");
        If TransferReceiptHeader_L.FindSet() then
            if PAGE.RunModal(5753, TransferReceiptHeader_L) = ACTION::LookupOK then
                FromDocNo := TransferReceiptHeader_L."No.";
    end;

    local procedure CreatetransferOrderline()
    Begin
        case FromDocType of
            FromDocType::"Transfer Order":
                CreatetransferlineFromTransferOrder;
            FromDocType::"Posted Transfer Shipments":
                CreatetransferlineFromPostedTransferShipment;
            FromDocType::"Posted Transfer Receipt":
                CreatetransferlineFromPostedTransferReceipt;
        end;
    End;

    local procedure CreatetransferlineFromTransferOrder()
    var
        TransferLine_L: Record "Transfer Line";
        TransferLine_L2: Record "Transfer Line";
    Begin
        TransferLine_L.Reset();
        TransferLine_L.SetRange("Document No.", TransferHeader."No.");
        if not TransferLine_L.FindFirst() then begin
            TransferLine_L2.Reset();
            TransferLine_L2.SetRange("Document No.", FromDocNo);
            TransferLine_L2.SetRange("Transfer-from Code", TransferHeader."Transfer-from Code");
            If TransferLine_L2.FindSet() then
                repeat
                    TransferLine_L.Init();
                    TransferLine_L."Document No." := TransferHeader."No.";
                    TransferLine_L."Line No." := TransferLine_L2."Line No.";
                    TransferLine_L.Validate("Item No.", TransferLine_L2."Item No.");
                    TransferLine_L.Validate(Quantity, TransferLine_L2.Quantity);
                    TransferLine_L.Insert();
                Until TransferLine_L2.Next() = 0;
        end;
    end;

    local procedure CreatetransferlineFromPostedTransferShipment()
    var
        TransferLine_L: Record "Transfer Line";
        TransferShipmentLine_L: Record "Transfer Shipment Line";
    Begin
        TransferLine_L.Reset();
        TransferLine_L.SetRange("Document No.", TransferHeader."No.");
        if not TransferLine_L.FindFirst() then begin
            TransferShipmentLine_L.Reset();
            TransferShipmentLine_L.SetRange("Document No.", FromDocNo);
            TransferShipmentLine_L.SetRange("Transfer-from Code", TransferHeader."Transfer-from Code");
            If TransferShipmentLine_L.FindSet() then
                repeat
                    TransferLine_L.Init();
                    TransferLine_L."Document No." := TransferHeader."No.";
                    TransferLine_L."Line No." := TransferShipmentLine_L."Line No.";
                    TransferLine_L.Validate("Item No.", TransferShipmentLine_L."Item No.");
                    TransferLine_L.Validate(Quantity, TransferShipmentLine_L.Quantity);
                    TransferLine_L.Insert();
                Until TransferShipmentLine_L.Next() = 0;
        end;
    End;

    local procedure CreatetransferlineFromPostedTransferReceipt()
    var
        TransferLine_L: Record "Transfer Line";
        TransferReceiptLine_L: Record "Transfer Receipt Line";
    Begin
        TransferLine_L.Reset();
        TransferLine_L.SetRange("Document No.", TransferHeader."No.");
        if not TransferLine_L.FindFirst() then begin
            TransferReceiptLine_L.Reset();
            TransferReceiptLine_L.SetRange("Document No.", FromDocNo);
            TransferReceiptLine_L.SetRange("Transfer-from Code", TransferHeader."Transfer-from Code");
            If TransferReceiptLine_L.FindSet() then
                repeat
                    TransferLine_L.Init();
                    TransferLine_L."Document No." := TransferHeader."No.";
                    TransferLine_L."Line No." := TransferReceiptLine_L."Line No.";
                    TransferLine_L.Validate("Item No.", TransferReceiptLine_L."Item No.");
                    TransferLine_L.Validate(Quantity, TransferReceiptLine_L.Quantity);
                    TransferLine_L.Insert();
                Until TransferReceiptLine_L.Next() = 0;
        end;
    End;

    procedure SetTransferHeader(var NewTransferHeader: Record "Transfer Header")
    begin
        NewTransferHeader.TestField("No.");
        TransferHeader := NewTransferHeader;
    end;
}

