tableextension 50002 "ExtendPostedSalesLine_CBR" extends "Sales Invoice Line" //113
{
    fields
    {
        field(50000; "No. of Cases"; Integer)
        {
            Caption = 'No. of Cases';
            DataClassification = ToBeClassified;
        }
        field(50001; "No. of Cases Ship"; Integer)
        {
            Caption = 'No. of Cases Ship';
            DataClassification = ToBeClassified;
        }
        field(50009; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50010; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }


    }
    var
        myInt: Integer;
}
