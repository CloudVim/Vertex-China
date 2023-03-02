pageextension 50010 "PostedSalesInvoice_Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addbefore(Closed)
        {
            field("Commission Rate"; Rec."Commission Rate")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {//AGT_DS_022823 Commemt the report as discussed by christoph
        addafter("S&end")
        {
            action(Itemusagebylocation)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item usage by location';
                Image = PrintReport;
                //Promoted = true;
                RunObject = report "Item Usage Location";
                Ellipsis = true;
            }
        }
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}