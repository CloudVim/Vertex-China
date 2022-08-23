report 50006 "Sales Commission Payable"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    Caption = 'Sales Commission Payable';
    RDLCLayout = './SalesCommissionPayable.rdl';

    dataset
    {
        dataitem(SalespersonPurchaser; "Salesperson/Purchaser")
        {
            RequestFilterFields = Code;
            column(SalesPersonCode; Code) { }
            column(CompanyInfo_Picture; CompanyInfo.Picture) { }
            column(StartDate; StartDate) { }
            column(EndDate; EndDate) { }

            dataitem(Records; Integer)
            {
                DataItemTableView = SORTING(Number);
                column(Customer_No; Customer_No) { }
                column(Customer_Name; Customer_Name) { }
                column(InvoiceNo; InvoiceNo) { }
                column(Document_Date; Document_Date) { }
                column(ItemNo; ItemNo) { }
                column(Description; Description) { }
                column(Quantity; Quantity) { }
                column(Unit_Price; Unit_Price) { }
                column(Unit_Cost; CommissionPercentage) { }
                column(Comission; Comission) { }
                column(ExtPriceVal; ExtPriceVal) { }
                column(Rate; Rate) { }

                trigger OnPreDataItem()
                var
                begin
                    TotalNoOfRecord := 0;
                    TotalNoOfRecord := NoOfRecords();
                    SetFilter(Number, '%1..%2', 1, TotalNoOfRecord);

                    SalesInvoiceLine_G.MarkedOnly(true);
                    if SalesInvoiceLine_G.FindSet() then;

                    SalesCrMemoLine_G.MarkedOnly(true);
                    if SalesCrMemoLine_G.FindSet() then;
                end;

                trigger OnAfterGetRecord()
                var
                    Item_L: Record Item;
                    Customer_L: Record Customer;
                    SalesPersonPurchaser_L: Record "Salesperson/Purchaser";
                begin
                    ClearVariable();
                    If Number <= NoOfSI then begin
                        If SalesInvHeader.get(SalesInvoiceLine_G."Document No.") then;
                        Customer_No := SalesInvHeader."Sell-to Customer No.";
                        Customer_Name := SalesInvHeader."Sell-to Customer Name";
                        InvoiceNo := SalesInvHeader."No.";
                        Document_Date := SalesInvHeader."Document Date";
                        CommissionPercentage := SalesInvoiceLine_G."Commission Rate";
                        If SalesInvoiceLine_G.Type = SalesInvoiceLine_G.Type::Item then
                            ItemNo := SalesInvoiceLine_G."No.";
                        Description := SalesInvoiceLine_G.Description;
                        Quantity := SalesInvoiceLine_G.Quantity;
                        Unit_Price := SalesInvoiceLine_G."Unit Price";
                        ExtPriceVal := SalesInvoiceLine_G.Quantity * SalesInvoiceLine_G."Unit Price";
                        // If SalesInvoiceLine_G."Commission Rate" <> 0 then
                        //    Rate := SalesInvoiceLine_G."Commission Rate"
                        //Else
                        if SalesInvHeader."Commission Rate" <> 0 then
                            Rate := SalesInvHeader."Commission Rate"
                        //  Else
                        //    if Item_L.Get(SalesInvoiceLine_G."No.") then
                        //      Rate := Item_L."Commission Percentage"
                        //else
                        //  If Customer_L.get(SalesInvHeader."Sell-to Customer No.") then
                        //    Rate := Customer_L."Commission Percentage"
                        //else
                        //  IF SalesPersonPurchaser_L.Get(SalesInvHeader."Salesperson Code") then
                        // Rate := SalesPersonPurchaser_L."Commission %"
                        Else
                            Rate := 0;
                        If ExtPriceVal <> 0 then
                            Comission := (ExtPriceVal / 100) * Rate;
                        SalesInvoiceLine_G.Next();
                    end else begin
                        if SalesCrMemoHeader.get(SalesCrMemoLine_G."Document No.") then;
                        Customer_No := SalesCrMemoHeader."Sell-to Customer No.";
                        Customer_Name := SalesCrMemoHeader."Sell-to Customer Name";
                        InvoiceNo := SalesCrMemoHeader."No.";
                        Document_Date := SalesCrMemoHeader."Document Date";
                        // CommissionPercentage := SalesCrMemoLine_G.c need to be add
                        if SalesCrMemoLine_G.Type = SalesCrMemoLine_G.Type::Item then
                            ItemNo := SalesCrMemoLine_G."No.";
                        Description := SalesCrMemoLine_G.Description;
                        Quantity := -SalesCrMemoLine_G.Quantity;
                        Unit_Price := SalesCrMemoLine_G."Unit Price";
                        ExtPriceVal := -(SalesCrMemoLine_G.Quantity * SalesCrMemoLine_G."Unit Price");
                        // if Item_L.Get(SalesCrMemoLine_G."No.") then
                        //     Rate := Item_L."Commission Percentage"
                        // else
                        //     If Customer_L.get(SalesCrMemoHeader."Sell-to Customer No.") then
                        //         Rate := Customer_L."Commission Percentage"
                        //     else
                        //         IF SalesPersonPurchaser_L.Get(SalesCrMemoHeader."Salesperson Code") then
                        //         Rate := SalesPersonPurchaser_L."Commission %"
                        If SalesCrMemoHeader."Commission Rate" <> 0 then
                            Rate := SalesCrMemoHeader."Commission Rate"
                        Else
                            Rate := 0;
                        SalesCrMemoLine_G.Next();
                        If ExtPriceVal <> 0 then
                            Comission := (ExtPriceVal / 100) * Rate;
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }
    trigger OnPreReport()
    var
        myInt: Integer;
    begin
        CompanyInfo.get();
        CompanyInfo.CalcFields(Picture);
        IF (StartDate = 0D) AND (EndDate = 0D) then
            Error('Please Enter the date filter')
        Else
            if (StartDate <> 0D) AND (EndDate = 0D) then
                EndDate := Today;

    end;

    var
        CompanyInfo: Record "Company Information";
        StartDate: Date;
        EndDate: Date;
        ExtPriceVal: Decimal;
        TotalNoOfRecord: Integer;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        NoOfSI: Integer;
        NoOfCM: Integer;
        Customer_No: Text;
        Customer_Name: Text;
        InvoiceNo: Text;
        ItemNo: Text;
        Description: Text;
        Document_Date: Date;
        Quantity: Decimal;
        Unit_Price: Decimal;
        Unit_Cost: Decimal;
        Comission: Decimal;
        Rate: Decimal;
        CommissionPercentage: Decimal;
        SalesInvoiceLine_G: Record "Sales Invoice Line";
        SalesCrMemoLine_G: Record "Sales Cr.Memo Line";

    local procedure NoOfRecords() myInteger: Integer;
    var
        TotalNo: Integer;
        SIH: Record "Sales Invoice Header";
        SIL: Record "Sales Invoice Line";
        SCMH: Record "Sales Cr.Memo Header";
        SCML: Record "Sales Cr.Memo Line";
    begin
        NoOfSI := 0;
        NoOfCM := 0;
        TotalNo := 0;
        SIH.Reset();
        SIH.SetRange("Posting Date", StartDate, EndDate);
        SIH.SetRange("Salesperson Code", SalespersonPurchaser.Code);
        SIH.SetCurrentKey("Sell-to Customer No.", "No.");
        If SIH.FindSet() then
            repeat
                SIL.Reset();
                SIL.SetRange("Document No.", SIH."No.");
                //SIL.SetRange(Type, SIL.Type::Item);
                NoOfSI += SIL.Count;
                If SIL.FindSet() then
                    repeat
                        If SalesInvoiceLine_G.get(SIL."Document No.", SIL."Line No.") then
                            SalesInvoiceLine_G.Mark(true);
                    until SIL.Next() = 0;
            Until SIH.Next() = 0;


        SCMH.Reset();
        SCMH.SetRange("Posting Date", StartDate, EndDate);
        SCMH.SetRange("Salesperson Code", SalespersonPurchaser.Code);
        SCMH.SetCurrentKey("Sell-to Customer No.", "No.");
        If SCMH.FindSet() then
            repeat
                SCML.Reset();
                SCML.SetRange("Document No.", SCMH."No.");
                NoOfCM += SCML.Count;
                If SCML.FindSet() then
                    repeat
                        If SalesCrMemoLine_G.get(SCML."Document No.", SCML."Line No.") then
                            SalesCrMemoLine_G.Mark(true);
                    until SCML.Next() = 0;
            Until SCMH.Next() = 0;

        TotalNo := NoOfSI + NoOfCM;
        exit(TotalNo);
    End;

    local procedure ClearVariable()
    begin
        Clear(Customer_No);
        Clear(Customer_Name);
        Clear(InvoiceNo);
        Clear(ItemNo);
        Clear(Description);
        Document_Date := 0D;
        Quantity := 0;
        Unit_Price := 0;
        Unit_Cost := 0;
        Comission := 0;
        ExtPriceVal := 0;
        Rate := 0;
        CommissionPercentage := 0;
    end;
}