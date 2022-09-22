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
        //AGT_YK_200922++
        field(50015; "Case Pack"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Case Pack';
            Editable = false;
        }
        //AGT_YK_200922--


    }
    var
        myInt: Integer;
}
