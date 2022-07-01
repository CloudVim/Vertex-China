tableextension 50001 "ExtendSalesLine_CBR" extends "Sales Line" //37
{
    fields
    {
        field(50000; "No. of Cases"; Integer)
        {
            Caption = 'No. of Cases';
            DataClassification = ToBeClassified;
        }
        field(50001; "No. of Cases Ship"; Integer)
        {
            Caption = 'No. of Cases Ship';
            DataClassification = ToBeClassified;
        }
        field(50002; "Stock-333"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock-333';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50003; "Stock-888"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock-888';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50004; "Stock-999"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock-999';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50005; "Stock-666-W"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock-666-W';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50006; "Stock-666-E"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock-666-E';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50007; Status; Enum "Sales Document Status")
        {
            Caption = 'Status';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup("Sales Header".Status WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No.")));
        }
        field(50008; "Qty Available"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                GetItemDataFosSales("No.");
            end;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                GetItemDataFosSales("No.");
            end;
        }
    }
    procedure GetItemDataFosSales(ItemNo: Code[20])
    begin
        if recItem.Get(ItemNo) then begin
            recItem.CalcFields(Inventory, "Qty. on Sales Order");
            "Qty Available" := (recItem.Inventory - recItem."Qty. on Sales Order");
        end;
    end;

    var
        recItem: Record Item;
}
