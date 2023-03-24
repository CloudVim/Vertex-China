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
        field(50009; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
            //Editable = false;
        }
        field(50010; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        //AGT_YK_200922++
        field(50015; "Case Pack"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Case Pack';
            Editable = false;
        }
        field(50016; "CBR_Unit Price Line Discount"; Decimal)
        {
            Caption = 'Unit Price Line Discount';
            Editable = false;

        }
        field(50017; CasestoShip; Decimal)
        {
            Caption = 'Cases To Ship';
            DataClassification = ToBeClassified;
        }
        modify("Line Discount %")
        {
            trigger OnAfterValidate()
            begin
                if ("Line Discount %" > 0) AND ("Unit Price" > 0) AND ("CBR_Unit Price Line Discount" = 0) then
                    "CBR_Unit Price Line Discount" := "Unit Price" - ("Unit Price" * "Line Discount %") / 100;
            End;
        }
        //AGT_YK_200922--
        // modify(Quantity)
        // {
        //     trigger OnAfterValidate()
        //     begin
        //         GetItemDataFosSales("No.", "Sell-to Customer No.");
        //     end;
        // }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                ItemL: Record Item;         //AGT_YK_200922

            begin
                GetItemDataFosSales("No.", "Sell-to Customer No.");
                UpdatedSalesperson();
                //AGT_YK_200922++
                if (Rec."Document Type" = Rec."Document Type"::Quote) OR (Rec."Document Type" = Rec."Document Type"::Order) then begin
                    if ItemL.Get(Rec."No.") then
                        if ItemL."Base Unit of Measure" = 'DZ' then //AGT.YK.090223
                            Rec."Case Pack" := ItemL."Case Pack"
                        else//AGT.YK.090223
                            Rec."Case Pack" := 1;//AGT.YK.090223
                end;
                //AGT_YK_200922--
            end;
        }

    }
    procedure GetItemDataFosSales(ItemNo: Code[20]; CustomerNo: Code[20])
    var
        //Item_L: Record Item;
        Customer_L: Record Customer;
        CustomerDiscountGroup: Record "Customer Discount Group";
    begin
        if RecItem.Get(ItemNo) then begin
            If RecItem."Group Code" <> 0 then begin
                If Customer_L.get(CustomerNo) then
                    if Customer_L."Customer Disc. Group" <> '' then begin
                        CustomerDiscountGroup.SetRange(Code, Customer_L."Customer Disc. Group");
                        if CustomerDiscountGroup.FindFirst() then begin
                            if RecItem."Group Code" = 1 then
                                "Commission Rate" := CustomerDiscountGroup."Group 1 Commission"
                            Else
                                if RecItem."Group Code" = 2 then
                                    "Commission Rate" := CustomerDiscountGroup."Group 2 Commission"
                                Else
                                    if RecItem."Group Code" = 3 then
                                        "Commission Rate" := CustomerDiscountGroup."Group 3 Commission";
                        end;
                    end;
            end;
        end else
            "Commission Rate" := 0;
    End;

    procedure UpdatedSalesperson()
    var
        Salesheader_L: Record "Sales Header";
    begin
        If (rec."Salesperson Code" = '') AND (Rec.Type <> Type::" ") then
            If Salesheader_L.Get(Rec."Document Type", Rec."Document No.") then
                rec."Salesperson Code" := Salesheader_L."Salesperson Code";
    end;

    procedure UpdateTotalWeightForOrder(var RecSalesLine: Record "Sales Line")
    var
        recItem: Record Item;
    // recSalesLine: Record "Sales Line";
    begin
        //AGT-DS 10192022++
        if (RecSalesLine."Line Discount %" > 0) AND (recSalesLine."Unit Price" > 0) then
            recSalesLine."CBR_Unit Price Line Discount" := recSalesLine."Unit Price" - (recSalesLine."Unit Price" * recSalesLine."Line Discount %") / 100;
        if recSalesLine."Line Discount %" = 0 then
            recSalesLine."CBR_Unit Price Line Discount" := recSalesLine."Unit Price";
        //AGT-SS 11-Aug-22--
        //AGT-DS 10192022--

        //AGT_VS_032323++
        if RecSalesLine."Unit of Measure Code" = 'EA' then begin
            RecSalesLine."Line Discount %" := 0;
            RecSalesLine."CBR_Unit Price Line Discount" := 0;
            //AGT_VS_032323--
        end;
    end;

    var
        RecItem: Record Item;
        CustomerDiscGroup: Record "Customer Discount Group";
}
