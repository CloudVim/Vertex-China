table 50001 "Inventory Planning"
{
    Caption = 'Inventory Planning';


    fields
    {
        field(1; "Location Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Collection; Code[20])
        {
            Caption = 'Collection';
            DataClassification = ToBeClassified;
            TableRelation = "Item Category";

        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "UPC Code"; Code[14])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Factory; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Case Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Unit of Measure"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Case Pack"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Unit Cost"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "List Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Qty. on Hand"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Location Code" = FIELD("Location Code")));
            Caption = 'Qty. on Hand';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Gross Requirement"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Net Available"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Qty. in Transit"; Decimal)
        {
            CalcFormula = Sum("Transfer Line"."Qty. in Transit (Base)" WHERE("Derived From Line No." = CONST(0),
                                                                              "Item No." = FIELD("Item No."),
                                                                              "Transfer-to Code" = FIELD("Location Code")));
            Caption = 'Qty. in Transit';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Qty. on Purch. Order"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Purchase Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                               Type = CONST(Item),
                                                                               "No." = FIELD("Item No."),
                                                                               "Location Code" = FIELD("Location Code")));
            Caption = 'Qty. on Purch. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Total Available"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Qty. on Sales Order"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = Sum("Sales Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                            Type = CONST(Item),
                                                                            "No." = FIELD("Item No."),
                                                                               "Location Code" = FIELD("Location Code")));
            Caption = 'Qty. on Sales Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Location Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    procedure UpdateInventoryValues()
    var
        myInt: Integer;
        recItem: Record Item;
        recLocation: Record Location;

    begin
        if recItem.FindSet() then
            repeat
                if recLocation.FindSet() then
                    repeat

                        Rec.Init();
                        Rec."Item No." := recItem."No.";
                        Rec."Location Code" := recLocation.Code;
                        Rec.Collection := recItem."Item Category Code";
                        Rec.Description := recItem.Description;
                        Rec."UPC Code" := recItem.GTIN;
                        Rec.Factory := recItem.Factory;
                        Rec."Case Weight" := recItem."Gross Weight";
                        Rec."Unit of Measure" := UpdateUOM(recItem."Base Unit of Measure");
                        Rec."Case Pack" := recItem."Case Pack";
                        Rec."Unit Cost" := UpdateUnitCost(recItem."No.", recLocation.Code);
                        Rec."List Price" := recItem."Unit Price";
                        if Rec.Insert() then;

                        Rec.CalcFields("Qty. on Hand", "Qty. in Transit", "Qty. on Purch. Order", "Qty. on Sales Order");

                        Rec."Gross Requirement" := (Rec."Qty. on Sales Order" - Rec."Qty. in Transit");
                        Rec."Net Available" := (Rec."Qty. on Hand" - Rec."Gross Requirement");
                        Rec."Total Available" := (Rec."Net Available" + Rec."Qty. in Transit" + Rec."Qty. on Purch. Order");
                        Rec.Modify();

                    until recLocation.Next() = 0;
            until recItem.Next() = 0;
    end;

    local procedure UpdateUOM(UOM: Code[20]): Text[50]
    var
        myInt: Integer;
        recUnitMeasure: Record "Unit of Measure";
    begin
        if recUnitMeasure.Get(UOM) then
            exit(recUnitMeasure.Description);
    end;

    local procedure UpdateUnitCost(ItemNo: code[20]; Location: Code[20]): Decimal
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        StockkeepingUnit.Reset();
        StockkeepingUnit.SetRange("Item No.", ItemNo);
        StockkeepingUnit.SetRange("Location Code", Location);
        if StockkeepingUnit.FindFirst() then
            exit("Unit Cost");
    end;

}

