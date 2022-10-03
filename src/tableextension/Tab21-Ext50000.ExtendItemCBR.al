tableextension 50000 "ExtendItem_CBR" extends Item //21
{
    fields
    {
        field(50000; "Case Pack"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Case Pack';
        }
        field(50001; "Factory"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Factory';
        }
        field(50002; "Group Code"; Enum GroupCode)
        {
            DataClassification = ToBeClassified;
            Caption = 'Group Code';
            //TableRelation = "Customer Discount Group";
        }
        field(50003; BinInventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("No."),
                                                                  "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                  "Location Code" = FIELD("Location Filter"),
                                                                  "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                  "Variant Code" = FIELD("Variant Filter"),
                                                                  "Lot No." = FIELD("Lot No. Filter"),
                                                                  "Serial No." = FIELD("Serial No. Filter"),
                                                                  "Unit of Measure Code" = FIELD("Unit of Measure Filter"),
                                                                  "Package No." = FIELD("Package No. Filter")));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }
}
