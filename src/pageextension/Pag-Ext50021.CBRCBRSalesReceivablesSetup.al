pageextension 50021 "CBR_CBRSalesReceivablesSetup" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Document Default Line Type")
        {
            field(DailyInvoicing_Mail; Rec.DailyInvoicing_Mail)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the DailyInvoicing_Mail field.';
                Caption = 'Daily Invoicing Mail';
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