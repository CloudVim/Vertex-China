pageextension 50008 "ExtendSalesOrder_CBR" extends "Sales Order"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Shipper Acct No.";Rec."Shipper Acct No.")
            {
                ApplicationArea = All;
                Caption = 'Shipper Acct No.';
            }
        }
    }
    var myInt: Integer;
}
