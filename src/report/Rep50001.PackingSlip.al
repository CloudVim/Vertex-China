report 50001 "PackingSlip"
{
    DefaultLayout = RDLC;
    RDLCLayout = './PackingSlip.rdl';
    Caption = 'Packing Slip';


    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            column(CompanyInfo_Picture; CompanyInfo.Picture)
            { }
            column(OrderNo; "No.")
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
            column(PONumber; "External Document No.")
            { }
            column(Order_Date; "Order Date")
            { }
            column(Shipment_Date; "Shipment Date")
            { }
            column(Salesperson_Code; "Salesperson Code")
            { }
            column(Sell_to_Customer_No_; "Sell-to Customer No.")
            { }
            // column(User_ID; "User ID")
            // { }
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
            dataitem(SalesLine; "Sales Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = SalesHeader;
                DataItemTableView = SORTING("Document No.", "Line No.");

                column(ItemNo; "No.")
                { }
                column(Description; Description)
                { }
                column(Quantity; Quantity)
                { }
                column(Unit_of_Measure; "Unit of Measure")
                { }
                column(Unit_Price; "Unit Price")
                { }
                column(Line_Discount__; "Line Discount %")
                { }
                column(Amount; Amount)
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
                column(LBSWeight; LBSWeight)
                { }
                column(CubeAmount; CubeAmount)
                { }
                column(Bin_Code; "Bin Code")
                { }
                trigger OnAfterGetRecord()
                var
                    SalesLine_L: Record "Sales Line";
                    SalesLineArchive_L: Record "Sales Line Archive";
                    Item_L: Record Item;
                begin
                    NoofRows := 0;
                    NoofRows := Count;
                    BOQtycasepack := 0;
                    Qtycasepack := 0;
                    BOQty := 0;
                    OrderQty := 0;
                    Clear(ItemUOM);
                    SalesLine_L.Reset();
                    SalesLine_L.SetRange("Document No.", "Document No.");
                    SalesLine_L.SetRange("Line No.", "Line No.");
                    If SalesLine_L.FindFirst() then begin
                        BOQty := SalesLine_L.Quantity - SalesLine_L."Quantity Shipped";
                        OrderQty := SalesLine_L.Quantity;
                    end else begin
                        SalesLineArchive_L.Reset();
                        SalesLineArchive_L.SetRange("Document Type", SalesLineArchive_L."Document Type"::Order);
                        SalesLineArchive_L.SetRange("Document No.", "Document No.");
                        SalesLineArchive_L.SetRange("Line No.", "Line No.");
                        SalesLineArchive_L.SetRange("No.", "No.");
                        If SalesLineArchive_L.FindFirst() then begin
                            BOQty := SalesLineArchive_L.Quantity - SalesLineArchive_L."Quantity Shipped";
                            OrderQty := SalesLineArchive_L.Quantity;
                        end;
                    end;
                    Item_L.reset;
                    If Item_L.Get("No.") then begin
                        If Item_L."Case Pack" <> 0 then begin
                            If OrderQty <> 0 then
                                Qtycasepack := OrderQty / Item_L."Case Pack";
                            IF BOQty <> 0 then
                                BOQtycasepack := BOQty / Item_L."Case Pack";
                            ItemUOM := Item_L."Base Unit of Measure";
                        end;
                    end;
                    //AGT_DS

                    CubeAmount := 0;
                    LBSWeight := 0;
                    If Type = Type::Item then begin
                        If Item_L.get("No.") then begin
                            If Item_L."Unit Volume" <> 0 then
                                CubeAmount := Quantity * "Unit Volume"
                            else
                                CubeAmount := Quantity;

                            If Item_L."Gross Weight" <> 0 then
                                LBSWeight := Quantity * Item_L."Gross Weight"
                            Else
                                LBSWeight := Quantity;
                        end;
                    end

                    //AGT_DS
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
                BillTo[2] := "Bill-to Name 2";
                BillTo[3] := "Bill-to Contact";
                BillTo[4] := "Bill-to Address";
                BillTo[5] := "Bill-to Address 2";
                BillTo[6] := "Bill-to City" + ' ' + "Bill-to County" + ' ' + "Bill-to Post Code";
                CompressArray(BillTo);

                ShipTo[1] := "Ship-to Name";
                ShipTo[2] := "Ship-to Name 2";
                ShipTo[3] := "Ship-to Contact";
                ShipTo[4] := "Ship-to Name";
                ShipTo[5] := "Ship-to Name 2";
                ShipTo[6] := "Ship-to City" + ' ' + "Ship-to County" + ' ' + "Ship-to Post Code";
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



    labels
    {

        UPCCaption = 'UPC';
        InvoiceDateInvoiceCaption = 'ORDER DATE';
        ORDERNOCaption = 'ORDER NO.';
        PODateCaption = 'P.O.DATE';
        PONumberCaption = 'P.O.Number';
        PageNoCaption = 'PAGE NO.';
        CustCaption = 'CUST #:';
        BilltoCaption = 'BILL TO:';
        ShiptoCaption = 'SHIP TO:';
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
        LBSWeight: Decimal;
        CubeAmount: Decimal;
}