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
        addafter(Status)
        {
            field(Stage; Rec.Stage)
            {
                ApplicationArea = all;
                Caption = 'Stage';
            }
        }
        //..AGT_VS_070323++  
        modify("External Document No.")
        {
            Caption = 'P.O. Number';
        }
        //..AGT_VS_070323--
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

            //AGT_VS_03132023++
            action("Batch Print Confirmation")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Batch Print Confirmation';
                Image = Print;
                Promoted = true;
                PromotedCategory = Category8;
                Ellipsis = true;

                trigger OnAction()
                var
                    SalesHeaderVar: Record "Sales Header";
                    ReportPrintConfirmation: Report SalesOrderConfirmation;
                begin
                    SalesHeaderVar.Reset();
                    CurrPage.SetSelectionFilter(SalesHeaderVar);
                    Report.Run(50004, true, false, SalesHeaderVar);
                end;
            }

            action("Batch Work Order")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Batch Work Order';
                Image = Print;
                Promoted = true;
                PromotedCategory = Category8;
                Ellipsis = true;

                trigger OnAction()
                var
                    SalesHeaderVar: Record "Sales Header";
                    ReportWorkOrder: Report PackingSlip;
                begin
                    SalesHeaderVar.Reset();
                    CurrPage.SetSelectionFilter(SalesHeaderVar);
                    Report.Run(50001, true, false, SalesHeaderVar);
                end;
            }

            action("Batch Pick Instruction")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Batch Pick Instruction';
                Image = Print;
                Promoted = true;
                PromotedCategory = Category8;
                Ellipsis = true;

                trigger OnAction()
                var
                    SalesHeaderVar: Record "Sales Header";
                    ReportPickInstruction: Report PickInstruction_CBR;
                begin
                    SalesHeaderVar.Reset();
                    CurrPage.SetSelectionFilter(SalesHeaderVar);
                    Report.Run(50007, true, false, SalesHeaderVar);
                end;
            }

        }
    }
    var
        myInt: Integer;
}
