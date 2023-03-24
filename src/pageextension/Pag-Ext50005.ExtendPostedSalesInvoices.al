pageextension 50005 "ExtendPostedSalesInvoices" extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Salesperson Code")
        {

            field("Commission Rate"; Rec."Commission Rate")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Commission Rate field.';
            }
        }
        addafter("Sell-to Customer Name")
        {

            field("CBR Customer Price Group"; Rec."CBR Customer Price Group")
            {
                Caption = 'Customer Price Group';
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Customer Price Group field.';
            }
            //AGT_VS_032223++
            field("Customer E-Mail"; rec."Customer E-Mail")
            {
                ApplicationArea = all;
                Caption = 'Customer E-Mail';
                ToolTip = 'Specifies Customer Email address';
            }
            //AGT_VS_032223--

        }
    }
    actions
    {
        addafter("&Invoice")
        {
            action("Sales Invoice Detail")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Invoice Detail Page';
                RunObject = page "Sales Invoice Detail";
                Promoted = true;
                PromotedIsBig = true;
                Image = ViewPostedOrder;
                PromotedCategory = Process;
            }
        }


        addafter(AttachAsPDF)
        {//AGT_DS_022823 Commemt the report as discussed by christoph
            action(Itemusagebylocation)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item usage by location';
                RunObject = report "Item Usage Location";
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Ellipsis = true;
            }

            //AGT_VS_031823++
            action("Batch PostedSalesInvReport")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Batch Posted Sales Invoice';
                Image = Print;
                Promoted = true;
                PromotedCategory = Category7;
                Ellipsis = true;

                trigger OnAction()
                var
                    SalesInvHeaderVar: Record "Sales Invoice Header";
                    ReportPrintConfirmation: Report PostedSalesInvoice;
                begin
                    SalesInvHeaderVar.Reset();
                    CurrPage.SetSelectionFilter(SalesInvHeaderVar);
                    Report.Run(50003, true, false, SalesInvHeaderVar);
                end;
            }
            //AGT_VS_031823--

        }
    }
    var
        myInt: Integer;
}
