pageextension 50005 "ExtendPostedSalesInvoices" extends "Posted Sales Invoices"
{
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
    }
    var myInt: Integer;
}
