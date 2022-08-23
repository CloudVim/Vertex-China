tableextension 50008 ExtCustomerDiscgroupCode extends "Customer Discount Group"
{
    fields
    {
        // Add changes to table fields here
        field(50001; "Group 1 Commission"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Group 1 Commission';
        }
        field(50002; "Group 2 Commission"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Group 2 Commission';
        }
        field(50003; "Group 3 Commission"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Group 3 Commission';
        }
    }

    var
        myInt: Integer;
}