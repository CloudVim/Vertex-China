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
            column(Payment_Terms_Code; "Payment Terms Code")
            { }
            column(External_Document_No_; "External Document No.")//"Order No."//AGT_DS_12022022_As per mentioned By taylor
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
            column(Shipping_Agent_Code; ShippingAgentName)
            { }
            column(Invoice_Discount_Amount; "Invoice Discount Amount")
            { }
            column(Paymenttermdiscount; Paymenttermdiscount)
            { }
            column(Posting_Date; "Posting Date")
            { }
            column(Package_Tracking_No_; "Package Tracking No.") { }
            dataitem(SalesInvoiceLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = SalesInvoiceHeader;
                //AGT_VS_302323       //DataItemTableView = SORTING("Document No.", "No.", "Line No.");

                column(ItemNo; "No.")
                { }
                column(Description; Description)
                { }
                column(Quantity; Quantity)
                { }
                column(Unit_of_Measure; UnitofMeasure)
                { }
                column(Unit_Price; UnitPrice)//"Unit Price")//UnitPrice)
                { }
                column(Line_Discount__; "Line Discount %")
                { }
                column(Amount; NetAmount)
                { }
                column(FrtAmount; FrtAmount)
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
                column(TotalNoofRows; TotalNoofRows)
                { }
                column(InvoiceNoBarode; InvoiceNoBarode)
                { }
                column(SLType; SLType) { }
                column(TotalCube; TotalCube) { }
                column(TotalWeight; TotalWeight) { }
                column(ItemCasePack; ItemCasePack) { }
                trigger OnAfterGetRecord()
                var
                    SalesLine_L: Record "Sales Line";
                    SalesLineArchive_L: Record "Sales Line Archive";
                    Item_L: Record Item;
                    Item_L1: Record Item;
                    SalesInvLineLoc: Record "Sales Invoice Line";
                begin
                    UnitPrice := 0;
                    NetAmount := 0;
                    FrtAmount := 0;
                    BOQtycasepack := 0;
                    Qtycasepack := 0;
                    BOQty := 0;
                    OrderQty := 0;
                    TotalCube := 0;
                    TotalWeight := 0;
                    CLear(SLType);
                    Clear(ItemUOM);
                    Clear(UnitofMeasure);
                    Clear(ItemCasePack);
                    // SalesInvLineLoc.Reset();
                    // SalesInvLineLoc.SetRange("Document No.", SalesInvoiceLine."Document No.");
                    // SalesInvLineLoc.SetFilter("No.", '%1', 'ZZZ-*');
                    // if SalesInvLineLoc.FindSet() then
                    //     repeat
                    //         FrtAmount := SalesInvLineLoc.Amount;
                    //     until SalesInvLineLoc.Next() = 0;


                    If (Quantity = 0) ANd (Type = Type::Item) Then Begin
                        CurrReport.Skip();
                    End else begin
                        If Type <> Type::" " then
                            NoofRows += 1;
                        //AGT.YK.090223++
                        SLType := Format(Type);
                        Item_L1.Reset();
                        If Item_L1.Get("No.") then begin
                            If Item_L1.Type <> Item_L1.Type::Inventory then begin
                                BOQty := 0;
                                OrderQty := 0;
                                Clear(ItemUOM);
                                Clear(ItemNo);
                                Clear(ItemDescription);
                                UnitPrice := 0;
                                NetAmount := "Amount Including VAT";
                                Clear(UnitofMeasure);
                            end Else Begin
                                NetAmount := "Amount Including VAT";
                                UnitPrice := "Unit Price";
                                UnitofMeasure := "Unit of Measure Code";
                                If Item_L1."Case Pack" <> 0 then
                                    ItemUOM := Item_L1."Base Unit of Measure";
                                If Item_L1."Unit Volume" <> 0 then
                                    TotalCube := Item_L1."Unit Volume" * SalesInvoiceLine.Quantity
                                Else
                                    TotalCube := SalesInvoiceLine.Quantity;
                                If Item_L1."Gross Weight" <> 0 then
                                    TotalWeight := Item_L1."Gross Weight" * SalesInvoiceLine.Quantity
                                else
                                    TotalWeight := SalesInvoiceLine.Quantity;
                                BOQty := Quantity;
                                OrderQty := Quantity;
                                // ItemNo := "No."; 
                                // ItemDescription := Description 
                                // SalesLine_L.Reset();
                                // SalesLine_L.SetRange("Document No.", "Order No.");
                                // SalesLine_L.SetRange("Line No.", "Order Line No.");
                                // SalesLine_L.SetFilter(Quantity, '<>%1', 0);
                                // If SalesLine_L.FindFirst() then
                                //     OrderQty := SalesLine_L.Quantity
                                // else begin
                                //     SalesLineArchive_L.Reset();
                                //     SalesLineArchive_L.SetRange("Document Type", SalesLineArchive_L."Document Type"::Order);
                                //     SalesLineArchive_L.SetRange("Document No.", "Order No.");
                                //     SalesLineArchive_L.SetRange("Line No.", "Line No.");
                                //     SalesLineArchive_L.SetRange("No.", "No.");
                                //     SalesLine_L.SetFilter(Quantity, '<>%1', 0);
                                //     If SalesLineArchive_L.FindFirst() then
                                //         OrderQty := SalesLine_L.Quantity
                                // end;
                            end;
                        end;


                        // SalesLine_L.Reset();
                        // SalesLine_L.SetRange("Document No.", "Order No.");
                        // SalesLine_L.SetRange("Line No.", "Order Line No.");
                        // SalesLine_L.SetFilter(Quantity, '<>%1', 0);
                        // If SalesLine_L.FindFirst() then begin
                        //     SLType := Format(SalesLine_L.Type);
                        //     Item_L1.Reset();
                        //     If Item_L1.Get(SalesLine_L."No.") then begin
                        //         If Item_L1.Type <> Item_L1.Type::Inventory then begin
                        //             BOQty := 0;
                        //             OrderQty := 0;
                        //             Clear(ItemUOM);
                        //             Clear(ItemNo);//AGT_DS_020723
                        //             Clear(ItemDescription);//AGT_DS_020723
                        //             UnitPrice := 0;//AGT_DS_020723
                        //             NetAmount := SalesLine_L.Amount;
                        //             Clear(UnitofMeasure);
                        //         end Else Begin
                        //             NetAmount := SalesLine_L.Amount;
                        //             UnitPrice := "Unit Price"; //AGT_DS_020723
                        //             UnitofMeasure := SalesLine_L."Unit of Measure";
                        //             If Item_L1."Case Pack" <> 0 then
                        //                 ItemUOM := Item_L1."Base Unit of Measure";
                        //             If Item_L1."Unit Volume" <> 0 then
                        //                 TotalCube := Item_L1."Unit Volume" * SalesInvoiceLine.Quantity
                        //             Else
                        //                 TotalCube := SalesInvoiceLine.Quantity;
                        //             If Item_L1."Gross Weight" <> 0 then
                        //                 TotalWeight := Item_L1."Gross Weight" * SalesInvoiceLine.Quantity
                        //             else
                        //                 TotalWeight := SalesInvoiceLine.Quantity;
                        //             BOQty := SalesLine_L.Quantity - SalesLine_L."Quantity Shipped";
                        //             OrderQty := SalesLine_L.Quantity;
                        //             // ItemNo := "No."; //AGT_DS_020723
                        //             // ItemDescription := Description //AGT_DS_020723
                        //         End;
                        //     end;
                        // end else begin
                        //     SalesLineArchive_L.Reset();
                        //     SalesLineArchive_L.SetRange("Document Type", SalesLineArchive_L."Document Type"::Order);
                        //     SalesLineArchive_L.SetRange("Document No.", "Order No.");
                        //     SalesLineArchive_L.SetRange("Line No.", "Line No.");
                        //     SalesLineArchive_L.SetRange("No.", "No.");
                        //     SalesLine_L.SetFilter(Quantity, '<>%1', 0);//AGt_DS020723
                        //     If SalesLineArchive_L.FindFirst() then begin
                        //         SLType := Format(SalesLineArchive_L.Type);
                        //         Item_L1.Reset();
                        //         IF Item_L1.Get(SalesLineArchive_L."No.") then begin
                        //             If Item_L1.Type <> Item_L1.Type::Inventory then begin
                        //                 BOQty := 0;
                        //                 OrderQty := 0;
                        //                 Clear(ItemUOM);
                        //                 Clear(ItemNo);//AGT_DS_020723
                        //                 Clear(ItemDescription);//AGT_DS_020723
                        //                 UnitPrice := 0;//AGT_DS_020723
                        //                 Clear(UnitofMeasure);
                        //                 NetAmount := SalesLineArchive_L.Amount;
                        //             end else Begin
                        //                 NetAmount := SalesLineArchive_L.Amount;
                        //                 UnitofMeasure := SalesLineArchive_L."Unit of Measure";
                        //                 If Item_L1."Case Pack" <> 0 then
                        //                     ItemUOM := Item_L1."Base Unit of Measure";
                        //                 UnitPrice := "Unit Price";//AGT_DS_020723
                        //                 If Item_L1."Unit Volume" <> 0 then
                        //                     TotalCube := Item_L1."Unit Volume" * SalesInvoiceLine.Quantity
                        //                 else
                        //                     TotalCube := SalesInvoiceLine.Quantity;
                        //                 If Item_L1."Gross Weight" <> 0 then
                        //                     TotalWeight := Item_L1."Gross Weight" * SalesInvoiceLine.Quantity
                        //                 else
                        //                     TotalWeight := SalesInvoiceLine.Quantity;
                        //                 BOQty := SalesLineArchive_L.Quantity - SalesLineArchive_L."Quantity Shipped";
                        //                 OrderQty := SalesLineArchive_L.Quantity;
                        //                 // ItemNo := "No."; //AGT_DS_020723
                        //                 // ItemDescription := Description //AGT_DS_020723
                        //             End;
                        //         end
                        //     end;
                        // end;
                        Item_L.reset;
                        If Item_L.Get("No.") then begin
                            If (Item_L."Case Pack" <> 0) and (Item_L.Type = Item_L.Type::Inventory) then begin //AGT.YK.100223 Added the second condtion
                                ItemCasePack := 'CS' + Format(Item_L."Case Pack");
                                If OrderQty <> 0 then
                                    Qtycasepack := OrderQty / Item_L."Case Pack";
                                IF BOQty <> 0 then
                                    BOQtycasepack := BOQty / Item_L."Case Pack";
                                //ItemUOM := Item_L."Base Unit of Measure";//AGT_DS_11292022   Used this field on afterget record
                            end;
                        end;
                    End
                end;

                trigger OnPreDataItem()
                Var
                    SalesInvLine_L1: Record "Sales Invoice Line";
                    Item_L1: Record Item;
                begin
                    NoofRows := 0;
                    TotalNoofRows := 0;
                    SalesInvLine_L1.Reset();
                    //SalesInvLine_L1.SetRange("Document Type", SalesHeader."Document Type");
                    SalesInvLine_L1.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvLine_L1.SetFilter(Type, '<>%1', Type::" ");
                    If SalesInvLine_L1.FindSet() then
                        repeat
                            TotalNoofRows += 1;
                        Until SalesInvLine_L1.Next() = 0;
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
                Clear(BillTo);
                Clear(ShipTo);
                Clear(InvoiceNoBarode);
                Clear(ShippingAgentName);

                //AGT_VS_030723++
                if ShipAgent_L.Get("Shipping Agent Code") then
                    ShippingAgentName := ShipAgent_L.Name;
                //AGT_VS_030723--

                BillTo[1] := "Bill-to Name";
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
                CompanyInfoAdd[6] := CompanyInfo."Phone No.";
                CompanyInfoAdd[7] := CompanyInfo."Fax No.";
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
        OrderedCaption = 'Quantity';
        BOCaption = 'BO';
        UMCaption = 'UM';
        PriceCaption = 'PRICE';
        DiscountCaption = 'DISCOUNT';
        NetAmountCaption = 'NET AMOUNT';
        QtyShippedTotalCaption = 'Total Quantity';
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
        SLType: Text;
        TotalCube: Decimal;
        TotalWeight: Decimal;
        UnitPrice: Decimal;
        NetAmount: Decimal;
        FrtAmount: Decimal;
        UnitofMeasure: Text[50];
        ItemCasePack: Text;
        ItemDescription: Text;
        ItemNo: Text;
        ShippingAgentName: Text;
}