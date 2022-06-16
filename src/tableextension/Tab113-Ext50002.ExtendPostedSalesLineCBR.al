tableextension 50002 "ExtendPostedSalesLine_CBR" extends "Sales Invoice Line" //113
{
    fields
    {
        field(50000;"No. of Cases";Integer)
        {
            Caption = 'No. of Cases';
            DataClassification = ToBeClassified;
        }
        field(50001;"No. of Cases Ship";Integer)
        {
            Caption = 'No. of Cases Ship';
            DataClassification = ToBeClassified;
        }
    }
    var myInt: Integer;
}
