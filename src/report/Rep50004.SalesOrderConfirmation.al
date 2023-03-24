report 50004 "SalesOrderConfirmation"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    Caption = 'Sales Order Confirmation';
    RDLCLayout = './SalesOrderConfirmation.rdl';


    dataset
    {
        dataitem(SalesHeader; "Sales Header")
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
            column(CompanyInfoAdd6; CompanyInfoAdd[6]) { }
            column(CompanyInfoAdd7; CompanyInfoAdd[7]) { }
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
            column(Payment_Terms_Code; PaymentTermsDesription)// "Payment Terms Code"
            { }
            column(Order_No_; "External Document No.")
            { }
            column(Order_Date; "Order Date")
            { }
            column(Shipment_Date; "Shipment Date")
            { }
            column(Salesperson_Code; "Salesperson Code")
            { }
            column(Sell_to_Customer_No_; "Sell-to Customer No.")
            { }
            column(User_ID; UserId)
            { }
            column(Shipment_Method_Code; "Shipment Method Code")
            { }
            column(Shipping_Agent_Code; ShippingAgentName)////AGT_VS_030723 Based on the new requirement on trello
            { }
            column(Invoice_Discount_Amount; "Invoice Discount Amount")
            { }
            column(Paymenttermdiscount; Paymenttermdiscount)
            { }
            column(Posting_Date; "Posting Date")
            { }
            column(TotalNoofRows; TotalNoofRows) { }
            column(Location_Name; Location_G.Name) { }
            column(Package_Tracking_No_; "Package Tracking No.") { }
            dataitem(SalesLine; "Sales Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = SalesHeader;
                DataItemTableView = SORTING("Document Type", "Document No.", Type, "Line No.");

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
                column(UnitPriceafterDiscount; "CBR_Unit Price Line Discount") { }
                column(CBRUnitPrice; CBRUnitPrice) { }//AGT.YK.090223++
                column(Amount; NetAmount)
                { }
                column(BOQtycasepack; BOQtycasepack)
                { }
                column(BOQty; BOQty)
                { }
                column(QtyShipped; QtyShipped)  //AGT_VS_032223
                { }
                column(ItemUOM; ItemUOM)
                { }
                column(Qtycasepack; Qtycasepack)
                { }

                column(QtyShippedCasepack; QtyShippedCasepack)  //AGT_VS_032223
                { }
                column(ItemCasePack; ItemCasePack) { }
                column(OrderQty; OrderQty)
                { }
                column(NoofRows; NoofRows)
                { }
                //AGT_YK_12072022
                column(UOMVisible; UOMVisible)
                { }
                //AGT_YK_12072022

                column(InvoiceNoBarode; InvoiceNoBarode)
                { }
                column(CheckNonInventoryItem; CheckNonInventoryItem) { }
                column(TotalCube; TotalCube) { }
                column(TotalWeight; TotalWeight) { }
                column(SLType; Type) { }

                trigger OnAfterGetRecord()
                var
                    SalesLine_L: Record "Sales Line";
                    SalesLine_L1: Record "Sales Line";
                    SalesLineArchive_L: Record "Sales Line Archive";
                    Item_L: Record Item;
                    Item_L1: Record Item;
                begin
                    NetAmount := 0;
                    BOQtycasepack := 0;
                    QtyShippedCasepack := 0;  //AGT_VS_032223
                    Qtycasepack := 0;
                    BOQty := 0;
                    QtyShipped := 0;  //AGT_VS_032223
                    OrderQty := 0;
                    TotalCube := 0;
                    TotalWeight := 0;
                    Clear(ItemUOM);
                    Clear(UnitofMeasure);
                    Clear(CBRUnitPrice);
                    If Type <> Type::" " then
                        NoofRows += 1;
                    If SalesLine_L.get("Document Type", "Document No.", "Line No.") then begin
                        // SLType := Format(SalesLine_L.Type);
                        Item_L1.Reset();
                        If Item_L1.Get(SalesLine_L."No.") then begin
                            If Item_L1.Type <> Item_L1.Type::Inventory then begin
                                BOQty := 0;
                                QtyShipped := 0;  //AGT_VS_032223
                                OrderQty := 0;
                                Clear(ItemUOM);
                                NetAmount := SalesLine_L.Amount;
                                Clear(UnitofMeasure);
                            end Else Begin
                                NetAmount := SalesLine_L.Amount;
                                UnitofMeasure := SalesLine_L."Unit of Measure";
                                If Item_L1."Case Pack" <> 0 then
                                    ItemUOM := Item_L1."Base Unit of Measure";
                                If Item_L1."Unit Volume" <> 0 then
                                    TotalCube := Item_L1."Unit Volume" * SalesLine_L.Quantity
                                Else
                                    TotalCube := SalesLine_L.Quantity;
                                If Item_L1."Gross Weight" <> 0 then
                                    TotalWeight := Item_L1."Gross Weight" * SalesLine_L.Quantity
                                else
                                    TotalWeight := SalesLine_L.Quantity;
                                //AGT_VS_032223++   //BOQty := SalesLine_L.Quantity - SalesLine_L."Quantity Shipped";
                                BOQty := SalesLine_L.Quantity - SalesLine_L."Qty. to Ship";
                                QtyShipped := SalesLine."Qty. to Ship";
                                //  AGT_VS_032223--

                                OrderQty := SalesLine_L.Quantity;
                                //AGT.YK.090223++
                                CBRUnitPrice := SalesLine_L."CBR_Unit Price Line Discount";
                                // CBRUnitPrice := SalesLine_L."CBR_Unit Price Line Discount"; 
                                //AGT.YK.090223++
                            End;
                        end;
                    end else begin
                        SalesLineArchive_L.Reset();
                        SalesLineArchive_L.SetRange("Document Type", SalesLineArchive_L."Document Type"::Order);
                        SalesLineArchive_L.SetRange("Document No.", "Document No.");
                        SalesLineArchive_L.SetRange("Line No.", "Line No.");
                        If SalesLineArchive_L.FindFirst() then begin
                            Item_L1.Reset();
                            IF Item_L1.Get(SalesLineArchive_L."No.") then begin
                                If Item_L1.Type <> Item_L1.Type::Inventory then begin
                                    BOQty := 0;
                                    QtyShipped := 0; //AGT_VS_032223
                                    OrderQty := 0;
                                    Clear(ItemUOM);
                                    Clear(UnitofMeasure);
                                    NetAmount := SalesLineArchive_L.Amount;
                                end else Begin
                                    NetAmount := SalesLineArchive_L.Amount;
                                    UnitofMeasure := SalesLineArchive_L."Unit of Measure";
                                    If Item_L1."Case Pack" <> 0 then
                                        ItemUOM := Item_L1."Base Unit of Measure";
                                    If Item_L1."Unit Volume" <> 0 then
                                        TotalCube := Item_L1."Unit Volume" * SalesLineArchive_L.Quantity
                                    else
                                        TotalCube := SalesLineArchive_L.Quantity;
                                    If Item_L1."Gross Weight" <> 0 then
                                        TotalWeight := Item_L1."Gross Weight" * SalesLineArchive_L.Quantity
                                    else
                                        TotalWeight := Item_L1."Gross Weight" * SalesLineArchive_L.Quantity;
                                    //AGT_VS_032223++       // BOQty := SalesLineArchive_L.Quantity - SalesLineArchive_L."Quantity Shipped";
                                    BOQty := SalesLineArchive_L.Quantity - SalesLineArchive_L."Qty. to Ship";
                                    QtyShipped := SalesLineArchive_L."Qty. to Ship";
                                    //AGT_VS_032223++ 
                                    OrderQty := SalesLineArchive_L.Quantity;
                                End;
                            end
                        end;
                    end;
                    Item_L.reset;
                    If Item_L.Get("No.") then begin
                        //AGT_YK_12072022
                        if Item_L.Type <> Item_L.Type::Inventory then
                            UOMVisible := true
                        else
                            UOMVisible := false;
                        //AGT_YK_12072022

                        If Item_L."Case Pack" <> 0 then begin
                            ItemCasePack := Item_L."Case Pack";

                            If OrderQty <> 0 then begin
                                Qtycasepack := OrderQty / Item_L."Case Pack";
                                //IF BOQty <> 0 then begin ....//AGT_VS_032223
                                BOQtycasepack := "Qty. to Ship" / Item_L."Case Pack"; //BOQty / Item_L."Case Pack";//AGT_VS_032323 As per discussion with Subheshi changed the logic
                                                                                      //AGT_VS_032223
                                                                                      // QtyShippedCasepack := "Qty. to Ship" / Item_L."Case Pack";  //AGT_VS_032223++ 
                                                                                      //ItemUOM := Item_L."Base Unit of Measure";//AGT_DS_11292022   Used this field on afterget record
                            end;
                        end;
                    end;

                    //AGT_VS_031723++
                    if (type = Type::Item) then
                        if Quantity = "Quantity Shipped" then begin
                            if Quantity = "Quantity Invoiced" then
                                CurrReport.Skip();
                        end;
                    //AGT_VS_031723--

                end;

                trigger OnPreDataItem()
                var
                    SalesLine_L1: Record "Sales Line";
                    Item_L1: Record Item;
                begin
                    NoofRows := 0;
                    TotalNoofRows := 0;
                    SalesLine_L1.Reset();
                    SalesLine_L1.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine_L1.SetRange("Document No.", SalesHeader."No.");
                    SalesLine_L1.SetFilter(Type, '<>%1', Type::" ");
                    If SalesLine_L1.FindSet() then
                        repeat
                            TotalNoofRows += 1;
                        Until SalesLine_L1.Next() = 0;
                end;

            }
            trigger OnAfterGetRecord()
            var
                Paymenterms_L: Record "Payment Terms";
                BarcodeSymbology: Enum "Barcode Symbology";
                BarcodeFontProvider: Interface "Barcode Font Provider";
                BarcodeString: Code[30];
                ShipAgent_L: Record "Shipping Agent";
            begin
                Clear(ShippingAgentName);
                Clear(BillTo);
                Clear(ShipTo);
                Clear(InvoiceNoBarode);
                //AGT_VS_030723++
                if ShipAgent_L.Get("Shipping Agent Code") then
                    ShippingAgentName := ShipAgent_L.Name;
                //AGT_VS_030723--
                BillTo[1] := "Bill-to Name";
                BillTo[2] := "Bill-to Address";
                BillTo[3] := "Bill-to Address 2";
                BillTo[4] := "Bill-to City" + ', ' + "Bill-to County" + ' ' + "Bill-to Post Code";
                CompressArray(BillTo);//AGT_DS_09232022 Because they need the 3 lines

                ShipTo[1] := "Ship-to Name";
                ShipTo[2] := "Ship-to Address";
                ShipTo[3] := "Ship-to Address 2";
                ShipTo[4] := "Ship-to City" + ', ' + "Ship-to County" + ' ' + "Ship-to Post Code";
                ShipTo[5] := "Ship-to Contact";
                CompressArray(ShipTo);//AGT_DS_09232022 Because they need the 3 lines

                If "Payment Terms Code" <> '' then
                    if Paymenterms_L.get("Payment Terms Code") then begin
                        PaymentTermsDesription := Paymenterms_L.Description;
                        Paymenttermdiscount := Paymenterms_L."Discount %";
                    end;


                BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
                BarcodeString := "No.";
                BarcodeFontProvider.ValidateInput(BarcodeString, BarcodeSymbology);
                InvoiceNoBarode := BarcodeFontProvider.EncodeFont(BarcodeString, BarcodeSymbology);

                if Location_G.Get("Location Code") then;
            end;


            trigger OnPreDataItem()
            var
            begin
                Clear(CompanyInfoAdd);
                CompanyInfoAdd[1] := CompanyInfo.Name;
                CompanyInfoAdd[2] := CompanyInfo."Name 2";
                CompanyInfoAdd[3] := CompanyInfo.Address;
                CompanyInfoAdd[4] := CompanyInfo."Address 2";
                CompanyInfoAdd[5] := CompanyInfo.City + ', ' + CompanyInfo.County + ' ' + CompanyInfo."Post Code";
                CompanyInfoAdd[6] := CompanyInfo."Phone No.";
                CompanyInfoAdd[7] := CompanyInfo."Fax No.";
                CompressArray(CompanyInfoAdd);
            end;

            trigger OnPostDataItem()
            var
                SalesHeader_L: Record "Sales Header";
            begin

                If SalesHeader_L.get(SalesHeader."Document Type", SalesHeader."No.") then
                    If (SalesHeader_L.Stage = '') then begin
                        SalesHeader_L.Stage := 'Ordered';
                        SalesHeader_L.Modify();
                    end;
            end;
        }
    }



    labels
    {
        InvoiceCaption = 'ACKNOWLEDGEMENT';
        UPCCaption = 'UPC';
        InvoiceDateInvoiceCaption = 'ORDER DATE';
        InvoiceNoInvoiceCaption = 'ORDER NO.';
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
        DiscountCaption = 'Unit Price';
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
        CompanyInfoAdd: array[7] of Text;
        Qtycasepack: Decimal;
        BOQtycasepack: Decimal;
        OrderQty: Decimal;
        BOQty: Decimal;
        ItemUOM: Text;
        Paymenttermdiscount: Decimal;
        NoofRows: Integer;
        TotalNoofRows: Integer;
        InvoiceNoBarode: Text;
        Location_G: Record Location;
        CheckNonInventoryItem: Boolean;
        PaymentTermsDesription: Text;
        ItemCasePack: Integer;
        NetAmount: Decimal;
        UnitofMeasure: Text[50];
        TotalCube: Decimal;
        TotalWeight: Decimal;
        UOMVisible: Boolean;//AGT_YK_12072022
        CBRUnitPrice: Decimal;//AGT.YK.090223
        ShippingAgentName: Text;//AGT_VS_030723
        QtyShipped: Decimal;  //AGT_VS_032223
        QtyShippedCasepack: decimal;
}