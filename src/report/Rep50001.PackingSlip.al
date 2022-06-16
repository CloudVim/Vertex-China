report 50001 "PackingSlip"
{
    DefaultLayout = RDLC;
    RDLCLayout = './PackingSlip.rdl';
    Caption = 'Packing Slip';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(Order));
            RequestFilterFields = "No.", "Sell-to Customer No.";
            RequestFilterHeading = 'Sales Order';
            column(No1_SalesHeader; "Sales Header"."No.")
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName)
            {
            }
            column(BilltoAddr1; BilltoAddr[1])
            {
            }
            column(BilltoAddr2; BilltoAddr[2])
            {
            }
            column(BilltoAddr3; BilltoAddr[3])
            {
            }
            column(BilltoAddr4; BilltoAddr[4])
            {
            }
            column(BilltoAddr5; BilltoAddr[5])
            {
            }
            column(ShiptoAddr1; ShiptoAddr[1])
            {
            }
            column(ShiptoAddr2; ShiptoAddr[2])
            {
            }
            column(ShiptoAddr3; ShiptoAddr[3])
            {
            }
            column(ShiptoAddr4; ShiptoAddr[4])
            {
            }
            column(ShiptoAddr5; ShiptoAddr[5])
            {
            }
            column(Order_Date; "Order Date")
            { }
            column(RefNo; "External Document No.")
            { }
            column(Vendor; "External Document No.")
            { }
            column(Customer; "External Document No.")
            { }
            column(CustomerPO; "External Document No.")
            { }
            column(ShipVia; "External Document No.")
            { }
            column(Mode; "External Document No.")
            { }
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemLinkReference = "Sales Header";
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                column(No_SalesLine; "No.")
                {
                    IncludeCaption = true;
                }
                column(Description_SalesLine; Description)
                {
                    IncludeCaption = true;
                }
                column(Quantity_SalesLine; Quantity)
                {
                    IncludeCaption = true;
                }
                column(UnitofMeasure_SalesLine; "Unit of Measure")
                {
                    IncludeCaption = true;
                }
                column(Type_SalesLine; Type)
                {
                    IncludeCaption = true;
                }

            }

            trigger OnAfterGetRecord()
            begin
                Clear(ShiptoAddr);
                Clear(BilltoAddr);
                ShiptoAddr[1] := "Ship-to Name";
                ShiptoAddr[2] := "Ship-to Name 2";
                ShiptoAddr[3] := "Ship-to Contact";
                ShiptoAddr[4] := "Ship-to Address 2";
                ShiptoAddr[5] := "Ship-to City" + ' ' + "Ship-to Post Code" + ' ' + "Ship-to County";
                CompressArray(ShiptoAddr);
                BilltoAddr[1] := "Bill-to Name";
                BilltoAddr[2] := "Bill-to Name 2";
                BilltoAddr[3] := "Bill-to Contact";
                BilltoAddr[4] := "Bill-to Address 2";
                BilltoAddr[5] := "Bill-to City" + ' ' + "Bill-to Post Code" + ' ' + "Bill-to County";
                CompressArray(BilltoAddr);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        OrderCaption = 'Order#';
        OrderDateCaption = 'Order Date';
        RefNumberCaption = 'Ref. Number';
        VendorCaption = 'Vendor#';
        CustomerCaption = 'Customer#';
        CustPoCaption = 'CustPo#';
        ShippedViaCaption = 'Shipped Via';
        ModeCaption = 'Mode';
        ShipToCaption = 'Ship To:';
        BillToCaption = 'Bill To:';
        SKUCaption = 'SKU';
        DescriptionCaption = 'Description';
        QuantityCaption = 'Quantity';
        UnitCaption = 'Unit';
        Dimqty = 'Dim Qty';
        DimUOMcaption = 'Dim UOM';
        PackageIDcaption = 'PackageID:';
        Notescaption = 'Notes';
        PackingSlipCaption = 'Packing Slip';


    }

    var
        FormatAddr: Codeunit "Format Address";
        BilltoAddr: array[8] of Text[100];
        ShiptoAddr: array[8] of Text[100];

}

