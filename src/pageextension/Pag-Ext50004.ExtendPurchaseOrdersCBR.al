pageextension 50004 "ExtendPurchaseOrders_CBR" extends "Purchase Order List"
{
    actions
    {
        addafter(Dimensions)
        {
            action("Purchase Order Receivers")
            {
                ApplicationArea = All;
                Caption = 'Purchase Order Receivers';
                Image = Print;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Purchase Order Receivers";
            }
        }
    }
    var myInt: Integer;
}
