pageextension 50012 ExtendSalesQuoteSubform_CBR extends "Sales Quote Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter(Quantity)
        {

            field("Commission Rate"; Rec."Commission Rate")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Commission Rate field.';
            }
        }
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