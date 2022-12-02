pageextension 50006 "ExtendPostedPurchaseInvoices" extends "Posted Purchase Invoices"
{

    actions
    {
        addafter("&Invoice")
        {
            action("Purchase Receipt History")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Receipt History Page';
                RunObject = page "Purchase Receipt History";
                Promoted = true;
                PromotedIsBig = true;
                Image = ViewPostedOrder;
                PromotedCategory = Process;
            }
        }
    }
    var
        myInt: Integer;
}
