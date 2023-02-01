pageextension 50007 "ExtendSalesOrder" extends "Sales Order List"
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
            field("Commission Rate"; Rec."Commission Rate")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Commission Rate field.';
            }

        }
    }
    actions
    {
        addafter(Dimensions)
        {
            action("Back Order Report")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back Order Report';
                RunObject = page "Back Order Report";
                Promoted = true;
                PromotedIsBig = true;
                Image = ViewPostedOrder;
                PromotedCategory = Process;
            }
            action("NJ Shipping Instructions")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'NJ Shipping Instructions';
                RunObject = page "NJ Shipping Instructions";
                Promoted = true;
                PromotedIsBig = true;
                Image = ShipmentLines;
                PromotedCategory = Process;
            }
        }
        addafter(AttachAsPDF)
        {
            action(ProFormaInvoice)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Pro Forma Invoice';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Category8;
                Ellipsis = true;

                trigger OnAction()
                var
                    salesHeader: Record "Sales Header";
                begin
                    salesHeader.Reset();
                    CurrPage.SetSelectionFilter(salesHeader);
                    Report.Run(50009, true, false, salesHeader);
                end;
            }
            action(packingslip)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Packing Slip';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Category8;
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
            // action(packingsli_Workorder)
            // {
            //     ApplicationArea = Basic, Suite;
            //     Caption = 'Packing Slip_Workorder';
            //     Image = PrintReport;
            //     Promoted = true;
            //     PromotedCategory = Category8;
            //     Ellipsis = true;

            //     trigger OnAction()
            //     var
            //         salesHeader: Record "Sales Header";
            //     begin
            //         salesHeader.Reset();
            //         CurrPage.SetSelectionFilter(salesHeader);
            //         Report.Run(50001, true, false, salesHeader);
            //     end;
            // }
            action(BillofLading)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bill Of Lading';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Category8;
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
            action(SentEmail)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'SentEMail';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Category8;
                Ellipsis = true;

                trigger OnAction()
                var
                    SendMail: Codeunit SendMail;
                begin
                    SendMail.Run();
                end;
            }
        }
    }
    var
        myInt: Integer;
}
