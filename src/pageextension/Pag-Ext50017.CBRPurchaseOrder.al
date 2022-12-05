pageextension 50017 "CBR_PurchaseOrder" extends "Purchase Order"
{
    layout
    {
        addafter(Status)
        {

            group("Work Description")
            {
                Caption = 'Work Description';
                field(WorkDescription; WorkDescription)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies the products or service being offered.';

                    trigger OnValidate()
                    begin
                        SetWorkDescription(WorkDescription);
                    end;
                }
            }
        }
    }
    actions
    {
        // Add changes to page actions here
    }

    var
        WorkDescription: Text;

    trigger OnAfterGetRecord()
    var
    begin
        WorkDescription := GetWorkDescription;
    end;
}