tableextension 50010 "CBR_SalesShipmentLine" extends "Sales Shipment Line"
{
    fields
    {
        field(50009; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
            //Editable = false;
        }
        field(50010; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }
        //AGT_YK_200922++
        field(50015; "Case Pack"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Case Pack';
            Editable = false;
        }
        //AGT_YK_200922--
        field(50016; "CBR_Unit Price Line Discount"; Decimal)
        {
            Caption = 'Unit Price Line Discount';
            Editable = false;

        }
        field(50017; CasestoShip; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}