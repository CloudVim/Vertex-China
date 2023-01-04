report 50010 "ItemSales  by Location"
{
    DefaultLayout = RDLC;
    Caption = 'Item usage by location';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    RDLCLayout = './ItemSalesbyLocation.rdl';

    dataset
    {
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Item No.", "Location Code", Open, "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.")
                                WHERE("Entry Type" = FILTER(Sale));
            RequestFilterFields = "Item No.";
            column(ItemNo; "Item Ledger Entry"."Item No.")
            {
            }
            column(Description; Description)
            {
            }
            column(LocationCode; "Item Ledger Entry"."Location Code")
            {
            }

            column(Month1; Month1)
            {
            }
            column(Month2; Month2)
            {
            }
            column(Month3; Month3)
            {
            }
            column(FirstmonthQty; FirstmonthQty)
            {
            }
            column(SecondMonthQty; SecondMonthQty)
            {
            }
            column(ThirdMonthQty; ThirdMonthQty)
            {
            }
            column(AverageQty; AverageQty)
            {
            }
            column(ReportTitle; ReportTitle)
            {
            }
            column(CompanyInformation_Name; CompInfo.Name)
            {
            }

            trigger OnAfterGetRecord();
            begin
                If Item.get("Item Ledger Entry"."Item No.") then begin
                    if Item.Type <> item.Type::Inventory then
                        CurrReport.Skip();
                end;
                If Item.GET("Item Ledger Entry"."Item No.") then
                    Description := Item.Description;
                CLEAR(FirstmonthQty);
                CLEAR(SecondMonthQty);
                CLEAR(ThirdMonthQty);
                IF (("Item Ledger Entry"."Item No." = XItemNo) AND ("Item Ledger Entry"."Location Code" = XLocationCode)) THEN
                    CurrReport.SKIP
                ELSE BEGIN
                    XItemNo := "Item Ledger Entry"."Item No.";
                    XLocationCode := "Item Ledger Entry"."Location Code";
                    ItemLedgerEntry.RESET;
                    ItemLedgerEntry.SETRANGE("Posting Date", CALCDATE('<-CM>', DateFilter), CALCDATE('<CM>', DateFilter));
                    ItemLedgerEntry.SETRANGE("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
                    ItemLedgerEntry.SETRANGE("Item No.", "Item Ledger Entry"."Item No.");
                    IF "Item Ledger Entry"."Location Code" <> '' THEN
                        ItemLedgerEntry.SETRANGE("Location Code", "Item Ledger Entry"."Location Code");
                    IF ItemLedgerEntry.FINDSET THEN BEGIN
                        ItemLedgerEntry.CALCSUMS(Quantity);
                        FirstmonthQty := ABS(ItemLedgerEntry.Quantity);
                    END;
                    ItemLedgerEntry2.RESET;
                    ItemLedgerEntry2.SETRANGE("Posting Date", CALCDATE('<-CM-1M>', DateFilter), CALCDATE('<-CM-1D>', DateFilter));
                    ItemLedgerEntry2.SETRANGE("Entry Type", ItemLedgerEntry2."Entry Type"::Sale);
                    ItemLedgerEntry2.SETRANGE("Item No.", "Item Ledger Entry"."Item No.");
                    IF "Item Ledger Entry"."Location Code" <> '' THEN
                        ItemLedgerEntry2.SETRANGE("Location Code", "Item Ledger Entry"."Location Code");
                    IF ItemLedgerEntry2.FINDSET THEN BEGIN
                        ItemLedgerEntry2.CALCSUMS(Quantity);
                        SecondMonthQty := ABS(ItemLedgerEntry2.Quantity);
                    END;
                    ItemLedgerEntry3.RESET;
                    ItemLedgerEntry3.SETRANGE("Posting Date", CALCDATE('<-CM-2M>', DateFilter), CALCDATE('<-CM-1M-1D>', DateFilter));
                    ItemLedgerEntry3.SETRANGE("Entry Type", ItemLedgerEntry3."Entry Type"::Sale);
                    ItemLedgerEntry3.SETRANGE("Item No.", "Item Ledger Entry"."Item No.");
                    IF "Item Ledger Entry"."Location Code" <> '' THEN
                        ItemLedgerEntry3.SETRANGE("Location Code", "Item Ledger Entry"."Location Code");
                    IF ItemLedgerEntry3.FINDSET THEN BEGIN
                        ItemLedgerEntry3.CALCSUMS(Quantity);
                        ThirdMonthQty := ABS(ItemLedgerEntry3.Quantity);
                    END;
                    IF ((FirstmonthQty = 0) AND (SecondMonthQty = 0) AND (ThirdMonthQty = 0)) THEN
                        CurrReport.SKIP;
                END;
                AverageQty := ABS(FirstmonthQty + SecondMonthQty + ThirdMonthQty) / 3;
            end;

            trigger OnPreDataItem();
            begin
                CompInfo.get();
                Month1 := FORMAT(CALCDATE('<-CM>', DateFilter), 3, '<Month Text>');
                Month2 := FORMAT(CALCDATE('<-1M-CM>', DateFilter), 3, '<Month Text>');
                Month3 := FORMAT(CALCDATE('<-2M-CM>', DateFilter), 3, '<Month Text>');

            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {

            area(content)
            {
                group("Filter")
                {
                    Caption = 'Filter';

                    field(DateFilter; DateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Date Filter';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Month1: Text;
        Month2: Text;
        Month3: Text;
        MonthStartDate: Date;
        FirstmonthQty: Decimal;
        SecondMonthQty: Decimal;
        ThirdMonthQty: Decimal;
        ItemLedgerEntry: Record "Item Ledger Entry";
        XLocationCode: Code[20];
        XItemNo: Code[20];
        AverageQty: Decimal;
        DateFilter: Date;
        ItemLedgerEntry2: Record "Item Ledger Entry";
        ItemLedgerEntry3: Record "Item Ledger Entry";
        ReportTitle: Label 'Item usage by location';
        Description: Text;
        Item: Record Item;
        CompanyInformation_Name: Text;
        CompInfo: Record "Company Information";
}

