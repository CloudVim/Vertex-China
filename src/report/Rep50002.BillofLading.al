report 50002 "Bill of Lading"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './BillofLadingCBR.rdl';
    Caption = 'Bill of Lading';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            column(No_; "No.")
            { }
            column(Ship_to_Name; "Ship-to Name" + ' ' + "Ship-to Name 2")
            { }
            column(Ship_to_Address; "Ship-to Address" + ' ' + "Ship-to Address 2")
            { }
            column(Ship_to_City; "Ship-to City" + ' ' + "Ship-to County" + ' ' + "Ship-to Post Code")
            { }
            column(Bill_to_Name; "Bill-to Name" + ' ' + "Bill-to Name 2")
            { }
            column(Bill_to_Address; "Bill-to Address" + ' ' + "Bill-to Address 2")
            { }
            column(Bill_to_City; "Bill-to City" + ' ' + "Bill-to County" + ' ' + "Bill-to Post Code")
            { }

        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(Name; SourceExpression)
                    // {
                    //     ApplicationArea = All;

                    // }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }
    labels
    {
        BillofLadingCaption = 'BILL OF LADING';
        ShipFromCaption = 'SHIP FROM';
        ShipTOCaption = 'SHIP TO';
        ThirdPartyCaption = 'THIRD PARTY FREIGHT CHARGES BILL TO';
        NameCaption = 'Name:';
        AddressCaption = 'Address:';
        CityStateCaption = 'City/State/Zip:';
        VendorCaption = 'Vendor #:';
        SIDCaption = 'SID #:';
        FOBCaption = 'FOB:';
        TelephoneCaption = 'Telephone#:';
        CIDCaption = 'CID #:';
        SpecialInstructionCaption = 'SPECIAL INSTRUCTIONS';
        BillofLadingNumnberCaption = 'Bill of Lading Number:';
        CarrierNameCaption = 'CARRIER NAME:';
        CustomerPickupCaption = 'CUSTOMER PICKUP';
        TrailernumberCaption = 'TRAILER NUMBER:';
        SealNumberCaption = 'Seal number(s):';
        SCACCaption = 'SCAC:';
        PronumberCaption = 'Pro number:';
        CPUCaption = 'CPU';
        FreightChargeTermsCaption = 'Freight Charge Terms';
        FreightChargePrepaidCaption = 'Freight Charges are Prepaid Unless Marked Otherwise';
        PrepaidCaption = 'Prepaid:';
        CollectCaption = 'Collect:';
        CheckBoxCaption = 'check box';
        MasterbillCaption = 'Master Bill Of Lading: with attached underlying bills of Lading';
        CustomerorderInformationCaption = 'CUSTOMER ORDER INFORMATION';
        CustomerOrderNumberCaption = 'CUSTOMER ORDER NUMBER';
        PKGSCaption = '#PKGS';
        WeightCaption = 'WEIGHT';
        PalletSlipCaption = 'PALLET/SLIP';
        AdditionalShipperInfoCaption = 'ADDITIONAL SHIPPER INFO';
        GrandTotalCaption = 'GRAND TOTAL';
        CarrierInformationCaption = 'CARRIER INFORMATION';
        HandlingUnitCaption = 'HANDLING UNIT';
        PackageCaption = 'PACKAGE';
        LTLOnlyCaption = 'LTL ONLY';
        QtyCaption = 'QTY';
        TypeCaption = 'TYPE';
        HMXCaption = 'H.M.(X)';
        CommodityDescriptionCaption = 'COMMODITY DESCRIPTION';
        NFMCCaption = 'NFMC#';
    }
    var
        myInt: Integer;
}