report 50003 "PostedSalesInvoice"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './PostedSalesInvoice.rdl';


    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            column(CompanyInfo_Picture; CompanyInfo.Picture)
            { }
            column(InvoiceNo; "No.")
            { }
            column(CompanyInfoAdd1; CompanyInfoAdd[1])
            { }
            column(CompanyInfoAdd2; CompanyInfoAdd[2])
            { }
            column(CompanyInfoAdd3; CompanyInfoAdd[3])
            { }
            column(CompanyInfoAdd4; CompanyInfoAdd[4])
            { }
            column(CompanyInfoAdd5; CompanyInfoAdd[5])
            { }
            column(BillTo1; BillTo[1])
            { }
            column(BillTo2; BillTo[2])
            { }
            column(BillTo3; BillTo[3])
            { }
            column(BillTo4; BillTo[4])
            { }
            column(BillTo5; BillTo[5])
            { }
            column(BillTo6; BillTo[6])
            { }
            column(ShipTo1; ShipTo[1])
            { }
            column(ShipTo2; ShipTo[2])
            { }
            column(ShipTo3; ShipTo[3])
            { }
            column(ShipTo4; ShipTo[4])
            { }
            column(ShipTo5; ShipTo[5])
            { }
            column(ShipTo6; ShipTo[6])
            { }
            column(Payment_Terms_Code; "Payment Terms Code")
            { }
            column(Order_No_; "Order No.")
            { }
            column(Order_Date; "Order Date")
            { }
            column(Shipment_Date; "Shipment Date")
            { }
            column(Salesperson_Code; "Salesperson Code")
            { }
            column(Sell_to_Customer_No_; "Sell-to Customer No.")
            { }
            column(User_ID; "User ID")
            { }
            column(Shipment_Method_Code; "Shipment Method Code")
            { }
            column(Shipping_Agent_Code; "Shipping Agent Code")
            { }
            column(Invoice_Discount_Amount; "Invoice Discount Amount")
            { }
            column(Paymenttermdiscount; Paymenttermdiscount)
            { }
            column(Posting_Date; "Posting Date")
            { }
            dataitem(SalesInvoiceLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = SalesInvoiceHeader;
                DataItemTableView = SORTING("Document No.", "Line No.");

                column(ItemNo; "No.")
                { }
                column(Description; Description)
                { }
                column(Quantity; Quantity)
                { }
                column(Unit_of_Measure; UnitofMeasure)
                { }
                column(Unit_Price; "Unit Price")//UnitPrice)
                { }
                column(Line_Discount__; "Line Discount %")
                { }
                column(Amount; NetAmount)
                { }
                column(BOQtycasepack; BOQtycasepack)
                { }
                column(BOQty; BOQty)
                { }
                column(ItemUOM; ItemUOM)
                { }
                column(Qtycasepack; Qtycasepack)
                { }
                column(OrderQty; OrderQty)
                { }
                column(NoofRows; NoofRows)
                { }
                column(InvoiceNoBarode; InvoiceNoBarode)
                { }
                column(SLType; SLType) { }
                column(TotalCube; TotalCube) { }
                column(TotalWeight; TotalWeight) { }
                trigger OnAfterGetRecord()
                var
                    SalesLine_L: Record "Sales Line";
                    SalesLineArchive_L: Record "Sales Line Archive";
                    Item_L: Record Item;
                    Item_L1: Record Item;
                begin
                    UnitPrice := 0;
                    NetAmount := 0;
                    NoofRows := 0;
                    NoofRows := Count;
                    BOQtycasepack := 0;
                    Qtycasepack := 0;
                    BOQty := 0;
                    OrderQty := 0;
                    TotalCube := 0;
                    TotalWeight := 0;
                    CLear(SLType);
                    Clear(ItemUOM);
                    Clear(UnitofMeasure);
                    SalesLine_L.Reset();
                    SalesLine_L.SetRange("Document No.", "Order No.");
                    SalesLine_L.SetRange("Line No.", "Order Line No.");
                    If SalesLine_L.FindFirst() then begin
                        SLType := Format(SalesLine_L.Type);
                        Item_L1.Reset();
                        If Item_L1.Get(SalesLine_L."No.") then begin
                            If Item_L1.Type <> Item_L1.Type::Inventory then begin
                                BOQty := 0;
                                OrderQty := 0;
                                Clear(ItemUOM);
                                //UnitPrice := 0;
                                NetAmount := SalesLineArchive_L.Amount;
                                Clear(UnitofMeasure);
                            end Else Begin
                                NetAmount := SalesLine_L.Amount;
                                //UnitPrice := SalesLine_L."Unit Price";
                                UnitofMeasure := SalesLine_L."Unit of Measure";
                                If Item_L1."Case Pack" <> 0 then
                                    ItemUOM := Item_L1."Base Unit of Measure";
                                TotalCube := Item_L1."Unit Volume" * SalesInvoiceLine.Quantity;
                                TotalWeight := Item_L1."Gross Weight" * SalesInvoiceLine.Quantity;
                                BOQty := SalesLine_L.Quantity - SalesLine_L."Quantity Shipped";
                                OrderQty := SalesLine_L.Quantity;
                            End;
                        end;
                    end else begin
                        SalesLineArchive_L.Reset();
                        SalesLineArchive_L.SetRange("Document Type", SalesLineArchive_L."Document Type"::Order);
                        SalesLineArchive_L.SetRange("Document No.", "Order No.");
                        SalesLineArchive_L.SetRange("Line No.", "Line No.");
                        SalesLineArchive_L.SetRange("No.", "No.");
                        If SalesLineArchive_L.FindFirst() then begin
                            SLType := Format(SalesLineArchive_L.Type);
                            Item_L1.Reset();
                            IF Item_L1.Get(SalesLineArchive_L."No.") then begin
                                If Item_L1.Type <> Item_L1.Type::Inventory then begin
                                    BOQty := 0;
                                    OrderQty := 0;
                                    Clear(ItemUOM);
                                    //UnitPrice := 0;
                                    Clear(UnitofMeasure);
                                    NetAmount := SalesLineArchive_L.Amount;
                                end else Begin
                                    NetAmount := SalesLineArchive_L.Amount;
                                    UnitofMeasure := SalesLineArchive_L."Unit of Measure";
                                    If Item_L1."Case Pack" <> 0 then
                                        ItemUOM := Item_L1."Base Unit of Measure";
                                    //UnitPrice := SalesLineArchive_L."Unit Price";
                                    TotalCube := Item_L1."Unit Volume" * SalesInvoiceLine.Quantity;
                                    TotalWeight := Item_L1."Gross Weight" * SalesInvoiceLine.Quantity;
                                    BOQty := SalesLineArchive_L.Quantity - SalesLineArchive_L."Quantity Shipped";
                                    OrderQty := SalesLineArchive_L.Quantity;
                                End;
                            end
                        end;
                    end;
                    Item_L.reset;
                    If Item_L.Get("No.") then begin
                        If Item_L."Case Pack" <> 0 then begin
                            If OrderQty <> 0 then
                                Qtycasepack := OrderQty / Item_L."Case Pack";
                            IF BOQty <> 0 then
                                BOQtycasepack := BOQty / Item_L."Case Pack";
                            //ItemUOM := Item_L."Base Unit of Measure";//AGT_DS_11292022   Used this field on afterget record
                        end;
                    end;

                end;

            }
            trigger OnAfterGetRecord()
            var
                Paymenterms_L: Record "Payment Terms";
                BarcodeSymbology: Enum "Barcode Symbology";
                BarcodeFontProvider: Interface "Barcode Font Provider";
                BarcodeString: Code[30];
            begin
                Clear(BillTo);
                Clear(ShipTo);
                Clear(InvoiceNoBarode);
                BillTo[1] := "Bill-to Name";
                // BillTo[2] := "Bill-to Name 2";
                // BillTo[3] := "Bill-to Contact";
                BillTo[2] := "Bill-to Address";
                BillTo[3] := "Bill-to Address 2";
                BillTo[4] := "Bill-to City" + ', ' + "Bill-to County" + ' ' + "Bill-to Post Code";
                CompressArray(BillTo);

                ShipTo[1] := "Ship-to Name";
                // ShipTo[2] := "Ship-to Name 2";
                // ShipTo[3] := "Ship-to Contact";
                ShipTo[2] := "Ship-to Address";
                ShipTo[3] := "Ship-to Address 2";
                ShipTo[4] := "Ship-to City" + ', ' + "Ship-to County" + ' ' + "Ship-to Post Code";
                CompressArray(ShipTo);

                If "Payment Terms Code" <> '' then
                    if Paymenterms_L.get("Payment Terms Code") then
                        Paymenttermdiscount := Paymenterms_L."Discount %";


                BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
                BarcodeString := "No.";
                BarcodeFontProvider.ValidateInput(BarcodeString, BarcodeSymbology);
                InvoiceNoBarode := BarcodeFontProvider.EncodeFont(BarcodeString, BarcodeSymbology);

            end;


            trigger OnPreDataItem()
            var
            begin
                Clear(CompanyInfoAdd);
                CompanyInfoAdd[1] := CompanyInfo.Name;
                CompanyInfoAdd[2] := CompanyInfo."Name 2";
                CompanyInfoAdd[3] := CompanyInfo.Address;
                CompanyInfoAdd[4] := CompanyInfo."Address 2";
                CompanyInfoAdd[5] := CompanyInfo.City + ' ' + CompanyInfo.County + ' ' + CompanyInfo."Post Code";
                CompressArray(CompanyInfoAdd);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(Name; SourceExpression)
                    // {
                    //     ApplicationArea = All;

                    // }
                }
            }
        }


    }


    labels
    {
        InvoiceCaption = 'INVOICE';
        UPCCaption = 'UPC';
        InvoiceDateInvoiceCaption = 'INVOICE DATE';
        InvoiceNoInvoiceCaption = 'INVOICE NO.';
        PODateCaption = 'P.O.DATE';
        PONumberCaption = 'P.O.Number';
        PageNoCaption = 'PAGE NO.';
        CustCaption = 'CUST #:';
        BilltoCaption = 'BILL TO:';
        ShiptoCaption = 'SHIP TO:';
        TakenByCaption = 'TAKEN BY';
        TrackingIDCaption = 'TRACKING ID';
        SalesRepCaption = 'SALES REP';
        ShippointCaption = 'SHIP POINT';
        VIACaption = 'VIA';
        ShippedCaption = 'SHIPPED';
        TermsCaption = 'TERMS';
        ProductDescriptionCaption = 'PRODUCT AND DESCRIPTION';
        OrderedCaption = 'ORDERED';
        BOCaption = 'BO';
        UMCaption = 'UM';
        PriceCaption = 'PRICE';
        DiscountCaption = 'DISCOUNT';
        NetAmountCaption = 'NET AMOUNT';
        QtyShippedTotalCaption = 'Qty Shipped Total';
        //Dozens = 'Dozens';
        TotalCaption = 'Total';
        OrderDiscountCaption = 'Order Discount';
        InvoiceTotalCaption = 'Invoice Total';
        TotalCubesCaption = 'Total Cubes';
        TotalWeightCaption = 'Total Weight';
        CashDiscountCaption = 'Cash Discount';
    }
    trigger OnPreReport()
    var
        myInt: Integer;
    begin
        CompanyInfo.get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        myInt: Integer;
        BillTo: array[6] of Text;
        ShipTo: array[6] of Text;
        CompanyInfo: Record "Company Information";
        CompanyInfoAdd: array[5] of Text;
        Qtycasepack: Decimal;
        BOQtycasepack: Decimal;
        OrderQty: Decimal;
        BOQty: Decimal;
        ItemUOM: Text;
        Paymenttermdiscount: Decimal;
        NoofRows: Integer;
        InvoiceNoBarode: Text;
        SLType: Text;
        TotalCube: Decimal;
        TotalWeight: Decimal;
        UnitPrice: Decimal;
        NetAmount: Decimal;
        UnitofMeasure: Text[50];
}