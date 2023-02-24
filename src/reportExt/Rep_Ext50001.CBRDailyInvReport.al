reportextension 50001 "DailyInvoicingReportExt" extends "Daily Invoicing Report"
{
    dataset
    {
        add("Sales Invoice Header")
        {
            column(InvNetSalesCaption; NetSalesCaption) { }
            column(InvNetSales; NetSales) { }
        }

        modify("Sales Invoice Header")
        {
            trigger OnAfterAfterGetRecord()
            var
                salesInvoiceLineRec: Record "Sales Invoice Line";
                itemRec: Record Item;
            begin
                Clear(NetSales);
                itemRec.Reset();
                salesInvoiceLineRec.Reset();
                salesInvoiceLineRec.SetRange("Document No.", "Sales Invoice Header"."No.");
                if salesInvoiceLineRec.FindSet() then
                    repeat
                        if itemRec.get(salesInvoiceLineRec."No.") then
                            if (itemRec.Type = itemRec.Type::Inventory) then begin
                                NetSales += salesInvoiceLineRec."Amount Including VAT";
                            end;
                    until salesInvoiceLineRec.Next() = 0;
            end;
        }

        add("Sales Cr.Memo Header")
        {
            column(CrNetSalesCaption; NetSalesCaption) { }

            column(CrNetSales; CRNetSales) { }
        }
        modify("Sales Cr.Memo Header")
        {
            trigger OnAfterAfterGetRecord()
            var
                SalesCrMemoLineRec: Record "Sales Cr.Memo Line";
                itemRec: Record Item;
            begin
                Clear(CRNetSales);
                itemRec.Reset();
                SalesCrMemoLineRec.Reset();
                SalesCrMemoLineRec.SetRange("Document No.", "Sales Cr.Memo Header"."No.");
                if SalesCrMemoLineRec.FindSet() then
                    repeat
                        if itemRec.get(SalesCrMemoLineRec."No.") then
                            if (itemRec.Type = itemRec.Type::Inventory) then begin
                                CRNetSales += SalesCrMemoLineRec."Amount Including VAT";
                            end;
                    until SalesCrMemoLineRec.Next() = 0;
            end;
        }
    }

    requestpage
    {

    }
    var
        NetSalesCaption: Label 'Net Sales';
        NetSales: Decimal;
        CRNetSales: Decimal;

}