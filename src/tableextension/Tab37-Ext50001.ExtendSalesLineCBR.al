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
            begin
                GetItemDataFosSales("No.", "Sell-to Customer No.");
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


    var
        RecItem: Record Item;
        CustomerDiscGroup: Record "Customer Discount Group";
}
