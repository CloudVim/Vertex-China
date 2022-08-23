pageextension 50013 ExtCustomerDiscgroupCode extends "Customer Disc. Groups"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {

            field("Group 1 Commission"; Rec."Group 1 Commission")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Group 1 Commission field.';
            }
            field("Group 2 Commission"; Rec."Group 2 Commission")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Group 2 Commission field.';
            }
            field("Group 3 Commission"; Rec."Group 3 Commission")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Group 3 Commission field.';
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