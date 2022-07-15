pageextension 50008 "ExtendSalesOrder_CBR" extends "Sales Order"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Shipper Acct No."; Rec."Shipper Acct No.")
            {
                ApplicationArea = All;
                Caption = 'Shipper Acct No.';
            }
        }
    }
    actions
    {
        addafter(AttachAsPDF)
        {
            action(packingslip)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Packing Slip';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Category11;
                Ellipsis = true;

                trigger OnAction()
                var
                    salesHeader: Record "Sales Header";
                begin
                    salesHeader.Reset();
                    CurrPage.SetSelectionFilter(salesHeader);
                    Report.Run(50001, true, false, salesHeader);
                end;
            }
            action(BillofLading)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bill Of Lading';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Category11;
                Ellipsis = true;

                trigger OnAction()
                var
                    salesHeader: Record "Sales Header";
                begin
                    salesHeader.Reset();
                    CurrPage.SetSelectionFilter(salesHeader);
                    Report.Run(50002, true, false, salesHeader);
                end;
            }
        }
    }
    var
        myInt: Integer;
}
