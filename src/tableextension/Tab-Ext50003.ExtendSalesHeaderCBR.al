tableextension 50003 "ExtendSalesHeader_CBR" extends "Sales Header"
{
    fields
    {
        field(50000; "Shipper Acct No."; Text[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipper Acct No.';
        }
        field(50001; "Ship-to Phone No."; Text[30])
        {
            Caption = 'Ship to Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(50002; "Ship-to Fax No."; Text[30])
        {
            Caption = 'Ship to Fax';
        }
        field(50003; "Ship-to E-Mail"; Text[80])
        {
            Caption = 'Ship to Email';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                MailManagement.ValidateEmailAddressField("Ship-to E-Mail");
            end;
        }
        field(50004; "Commission Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        modify("Bill-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                Cust: Record Customer;
            begin
                if "Bill-to Customer No." <> '' then
                    IF Cust.get("Bill-to Customer No.") then
                        Rec."Commission Rate" := Cust."Commission Rate";
            end;
        }
    }
    var
        myInt: Integer;
}
