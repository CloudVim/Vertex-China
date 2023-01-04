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
    {
        addafter("S&end")
        {
            action(Itemusagebylocation)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item usage by location';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = report "ItemSales  by Location";
                Ellipsis = true;
            }


        }
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}