pageextension 50020 "CBR_AppliedCustomerEntries" extends "Apply Customer Entries"
{
    layout
    {
        addafter(Description)
        {

            field(REFERENCE; Rec.REFERENCE)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the REFERENCE field.';
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