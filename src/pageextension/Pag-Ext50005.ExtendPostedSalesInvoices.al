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
    }
    var
        myInt: Integer;
}
