tableextension 50019 "CBR_SalesReceivablesSetup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50000; DailyInvoicing_Mail; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}