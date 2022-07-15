report 50005 "PurchaseOrder"
{
    DefaultLayout = RDLC;
    RDLCLayout = './PurchaseOrder.rdl';
    Caption = 'Purchase Order';

    dataset
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            column(No_; "No.")
            { }
            column(Order_Date; "Order Date")
            { }
            column(Payment_Terms_Code; "Payment Terms Code")
            { }
            column(CompanyInfo_Picture; CompanyInfo.Picture)
            { }
            column(CompanyInfo_Phone; CompanyInfo."Phone No.")
            { }
            column(CompanyInfo_FaxNo; CompanyInfo."Fax No.")
            { }
            column(CompanyInfoAdd1; CompanyInfoAdd[1])
            { }
            column(CompanyInfoAdd2; CompanyInfoAdd[2])
            { }
            column(CompanyInfoAdd3; CompanyInfoAdd[3])
            { }

            column(ShipToAdd1; ShipToAdd[1])
            { }
            column(ShipToAdd2; ShipToAdd[2])
            { }
            column(ShipToAdd3; ShipToAdd[3])
            { }
            column(ShipToAdd4; ShipToAdd[4])
            { }
            column(ShipToAdd5; ShipToAdd[5])
            { }
            column(PurchaseFrom1; PurchaseFrom[1])
            { }
            column(PurchaseFrom2; PurchaseFrom[2])
            { }
            column(PurchaseFrom3; PurchaseFrom[3])
            { }
            column(PurchaseFrom4; PurchaseFrom[4])
            { }
            column(PurchaseFrom5; PurchaseFrom[5])
            { }
            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = PurchaseHeader;
                DataItemTableView = SORTING("Document No.", "Line No.");

                column(ItemNo; "No.")
                { }
                column(Description; Description)
                { }
                column(Quantity; Quantity)
                { }
                column(Unit_of_Measure; "Unit of Measure")
                { }
                column(Unit_Price__LCY_; "Unit Price (LCY)")
                { }
                column(Line_Discount_Amount; "Line Discount Amount")
                { }
                column(Amount; Amount)
                { }
            }


            trigger OnAfterGetRecord()
            var
            begin
                Clear(ShipToAdd);
                Clear(PurchaseFrom);
                ShipToAdd[1] := "Ship-to Name";
                ShipToAdd[2] := "Ship-to Name 2";
                ShipToAdd[3] := "Ship-to Address";
                ShipToAdd[4] := "Ship-to Address 2";
                ShipToAdd[5] := "Ship-to City" + ' ' + "Ship-to County" + ' ' + "Ship-to Post Code";
                CompressArray(ShipToAdd);

                PurchaseFrom[1] := "Buy-from Vendor Name";
                PurchaseFrom[2] := "Buy-from Vendor Name 2";
                PurchaseFrom[3] := "Buy-from Address";
                PurchaseFrom[4] := "Buy-from Address 2";
                PurchaseFrom[5] := "Buy-from City" + ' ' + "Buy-from County" + ' ' + "Buy-from Post Code";
                CompressArray(PurchaseFrom);

            end;

            trigger OnPreDataItem()
            var
            begin
                Clear(CompanyInfoAdd);
                CompanyInfoAdd[1] := CompanyInfo.Name;
                CompanyInfoAdd[2] := CompanyInfo.Address;
                CompanyInfoAdd[3] := CompanyInfo.City + ' ' + CompanyInfo.County + ' ' + CompanyInfo."Post Code";
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
    end;


    var
        CompanyInfo: Record "Company Information";
        CompanyInfoAdd: array[3] of Text;
        ShipToAdd: array[5] of Text;
        PurchaseFrom: array[5] of Text;
}