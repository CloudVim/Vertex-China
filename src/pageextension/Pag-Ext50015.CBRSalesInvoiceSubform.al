pageextension 50015 "CBR_SalesInvoiceSubform" extends "Sales Invoice Subform"
{
    layout
    {
        addafter("Location Code")
        {
            field("Salesperson Code"; Rec."Salesperson Code")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}