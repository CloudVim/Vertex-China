//Task_ID= CAS-02422-V7C5H9
report 50006 "Sales Commission Payable"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
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
            dataitem(Customer; Customer)
            {
                DataItemLinkReference = SalespersonPurchaser;
                DataItemLink = "Salesperson Code" = field(Code);

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
                    column(Unit_Cost; Customer."Commission Percentage") { }
                    column(Comission; Comission) { }
                    column(ExtPriceVal; ExtPriceVal) { }
                    column(Rate; Rate) { }

                    trigger OnPreDataItem()
                    var
                    begin
                        TotalNoOfRecord := 0;
                        TotalNoOfRecord := NoOfRecords();
                        SetFilter(Number, '%1..%2', 1, TotalNoOfRecord);

                        SalesInvLine.Reset();
                        SalesCrMemoLine.Reset();
                        SalesInvLine.SetRange("Posting Date", StartDate, EndDate);
                        SalesInvLine.SetRange("Sell-to Customer No.", Customer."No.");
                        IF SalesInvLine.FindSet() then;

                        SalesCrMemoLine.SetRange("Posting Date", StartDate, EndDate);
                        SalesCrMemoLine.SetRange("Sell-to Customer No.", Customer."No.");
                        If SalesCrMemoLine.FindSet() then;
                    end;

                    trigger OnAfterGetRecord()
                    var
                        Item_L: Record Item;
                        Customer_L: Record Customer;
                        SalesPersonPurchaser_L: Record "Salesperson/Purchaser";
                    begin
                        ClearVariable();
                        If Number <= NoOfSI then begin
                            If SalesInvHeader.get(SalesInvLine."Document No.") then;
                            Customer_No := SalesInvHeader."Sell-to Customer No.";
                            Customer_Name := SalesInvHeader."Sell-to Customer Name";
                            InvoiceNo := SalesInvHeader."No.";
                            Document_Date := SalesInvHeader."Document Date";
                            If SalesInvLine.Type = SalesInvLine.Type::Item then
                                ItemNo := SalesInvLine."No.";
                            Description := SalesInvLine.Description;
                            Quantity := SalesInvLine.Quantity;
                            Unit_Price := SalesInvLine."Unit Price";
                            ExtPriceVal := SalesInvLine.Quantity * SalesInvLine."Unit Price";
                            // If SalesInvLine."Commission Rate" <> 0 then
                            //     Rate := SalesInvLine."Commission Rate"
                            // Else
                            if SalesInvHeader."Commission Rate" <> 0 then
                                Rate := SalesInvHeader."Commission Rate"
                            //     Else
                            //         if Item_L.Get(SalesInvLine."No.") then
                            //             Rate := Item_L."Commission Percentage"
                            //         else
                            //             If Customer_L.get(SalesInvHeader."Sell-to Customer No.") then
                            //                 Rate := Customer_L."Commission Percentage"
                            //             else
                            // IF SalesPersonPurchaser_L.Get(SalesInvHeader."Salesperson Code") then
                            //     Rate := SalesPersonPurchaser_L."Commission %"
                            Else
                                Rate := 0;
                            If ExtPriceVal <> 0 then
                                Comission := (ExtPriceVal / 100) * Rate;
                            SalesInvLine.Next();
                        end else begin
                            if SalesCrMemoHeader.get(SalesCrMemoLine."Document No.") then;
                            Customer_No := SalesCrMemoHeader."Sell-to Customer No.";
                            Customer_Name := SalesCrMemoHeader."Sell-to Customer Name";
                            InvoiceNo := SalesCrMemoHeader."No.";
                            Document_Date := SalesCrMemoHeader."Document Date";
                            if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then
                                ItemNo := SalesCrMemoLine."No.";
                            Description := SalesCrMemoLine.Description;
                            Quantity := -SalesCrMemoLine.Quantity;
                            Unit_Price := SalesCrMemoLine."Unit Price";
                            ExtPriceVal := -(SalesCrMemoLine.Quantity * SalesCrMemoLine."Unit Price");
                            // if Item_L.Get(SalesCrMemoLine."No.") then
                            //     Rate := Item_L."Commission Percentage"
                            // else
                            //     If Customer_L.get(SalesCrMemoHeader."Sell-to Customer No.") then
                            //         Rate := Customer_L."Commission Percentage"
                            //     else
                            // IF SalesPersonPurchaser_L.Get(SalesCrMemoHeader."Salesperson Code") then
                            //     Rate := SalesPersonPurchaser_L."Commission %"
                            If SalesCrMemoHeader."Commission Rate" <> 0 then
                                Rate := SalesCrMemoHeader."Commission Rate"
                            Else
                                Rate := 0;
                            SalesCrMemoLine.Next();
                            If ExtPriceVal <> 0 then
                                Comission := (ExtPriceVal / 100) * Rate;
                        end;
                    end;
                }
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

    local procedure NoOfRecords() myInteger: Integer;
    var
        TotalNo: Integer;
        SIH: Record "Sales Invoice Header";
        SIL: Record "Sales Invoice Line";
        SCM: Record "Sales Cr.Memo Header";
        SCL: Record "Sales Cr.Memo Line";
    begin
        NoOfSI := 0;
        NoOfCM := 0;
        TotalNo := 0;
        SIL.Reset();
        SIL.SetRange("Sell-to Customer No.", Customer."No.");
        SIL.SetRange("Posting Date", StartDate, EndDate);
        NoOfSI := SIL.Count;

        SCL.Reset();
        SCL.SetRange("Sell-to Customer No.", Customer."No.");
        SCL.SetRange("Posting Date", StartDate, EndDate);
        NoOfCM := SCL.Count;

        TotalNo := NoOfSI + NoOfCM;
        exit(TotalNo);

    end;

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
    end;
}