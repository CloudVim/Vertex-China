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
                Caption = 'Daily Invoicing E-Mail';
            }

            field(AutoSendSalesInvoice_Email; Rec.AutoSendSalesInvoice_Email)
            {
                ApplicationArea = All;
                ToolTip = 'Enables the auto-sending function of Sales Invoice Report to the customer as soon as the sales order is posted';
                Caption = 'Enable Auto Send Invoice Email';
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