report 50013 "Item Usage Location"
{
    DefaultLayout = RDLC;
    Caption = 'Item usage Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    RDLCLayout = './ItemUsage.rdl';

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = field("No.");
                DataItemTableView = SORTING("Item No.", "Location Code")
                                WHERE("Location Code" = filter('333|666-333|OW-333|888|666-888|OW-888'));
                RequestFilterFields = "Item No.";
                column(ItemNo; "Item No.")
                {
                }
                column(Description; Description)
                {
                }
                column(LocationCode; locationCode)
                {
                }
                column(QtyInHand_G; "Remaining Quantity") { }
                column(QtyReserved_G; QtyReserved_G) { }

                column(CompanyInformation_Name; CompInfo.Name)
                {
                }
                column(QtyInTrans_G; QtyInTrans_G) { }
                column(QtyCommit_G; QtyCommit_G) { }
                column(QtyOnOrder_G; QtyOnOrder_G) { }
                trigger OnPreDataItem()
                var
                //ILE
                begin
                    QtyReserved_G := 0;
                    If Location_L <> Location_L::" " then Begin
                        If Location_L = Location_L::"333" then
                            SetFilter("Location Code", '%1|%2|%3', '333', '666-333', 'OW-333')
                        Else
                            If Location_L = Location_L::"888" then
                                SetFilter("Location Code", '%1|%2|%3', '888', '666-888', 'OW-888')
                    End;
                End;

                trigger OnAfterGetRecord()
                var

                begin
                    QtyReserved_G := 0;
                    QtyInTrans_G := 0;
                    Clear(locationCode);
                    Clear(LocationCodeReserved);
                    If ("Location Code" = '333') Or ("Location Code" = '666-333') or ("Location Code" = 'OW-333') then
                        locationCode := '333'
                    Else
                        locationCode := '888';

                    If Location_L = Location_L::"333" then
                        If "Location Code" = '666-333' then
                            QtyReserved_G := "Remaining Quantity";
                    If Location_L = Location_L::"333" then
                        If "Location Code" = '666-888' then
                            QtyReserved_G := "Remaining Quantity";

                    If Location_L = Location_L::"333" then
                        If "Location Code" = 'OW-333' then
                            QtyInTrans_G := "Remaining Quantity";
                    If Location_L = Location_L::"333" then
                        If "Location Code" = 'OW-888' then
                            QtyInTrans_G := "Remaining Quantity";

                    QtyCommit_G := 0;
                    If locationCode = '333' then
                        If not SalesLine_333 then
                            GetsalesLine333(Item);
                    If locationCode = '888' then
                        If not SalesLine_888 then
                            GetsalesLine888(Item);

                    QtyOnOrder_G := 0;
                    If locationCode = '333' then
                        If not PurchaseLine_333 then
                            GetPurchaseLine333(Item);
                    If locationCode = '888' then
                        If not PurchaseLine_888 then
                            GetPurchaseLine888(Item);
                end;
            }
            trigger OnAfterGetRecord()
            Var

            begin
                SalesLine_333 := false;
                SalesLine_888 := false;
                PurchaseLine_333 := false;
                PurchaseLine_888 := false;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {

            area(content)
            {
                group("Filter")
                {
                    Caption = 'Filter';

                    field(Location_L; Location_L)
                    {
                        ApplicationArea = All;
                        Caption = 'Location';
                        OptionCaption = ' ,333,888';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Location_L: Option " ","333","888";
        CompanyInformation_Name: Text;
        CompInfo: Record "Company Information";
        QtyInHand_G: Decimal;
        QtyInTrans_G: Decimal;
        QtyReserved_G: Decimal;
        QtyCommit_G: Decimal;
        QtyOnOrder_G: Decimal;
        locationCode: Text;
        LocationCodeReserved: Text;
        SalesLine_333: Boolean;
        SalesLine_888: Boolean;
        PurchaseLine_333: Boolean;
        PurchaseLine_888: Boolean;

    local procedure GetsalesLine333(var Item_L: Record Item)
    var
        SalesLine_L: Record "Sales Line";
    Begin
        //QtyCommit_G := 0;
        SalesLine_L.Reset();
        SalesLine_L.SetRange("No.", Item_L."No.");
        SalesLine_L.SetFilter("Location Code", '%1|%2|%3', '333', '666-333', 'OW-333');
        SalesLine_L.CalcSums("Outstanding Quantity");
        If not SalesLine_L.IsEmpty then begin
            QtyCommit_G := SalesLine_L."Outstanding Quantity";
            SalesLine_333 := true;
        end;

    End;

    local procedure GetsalesLine888(var Item_L: Record Item)
    var
        SalesLine_L: Record "Sales Line";
    Begin
        //QtyCommit_G := 0;
        SalesLine_L.Reset();
        SalesLine_L.SetRange("No.", Item_L."No.");
        SalesLine_L.SetFilter("Location Code", '%1|%2|%3', '888', '666-888', 'OW-888');
        SalesLine_L.CalcSums("Outstanding Quantity");
        If not SalesLine_L.IsEmpty then begin
            QtyCommit_G := SalesLine_L."Outstanding Quantity";
            SalesLine_888 := true;
        end;
    End;

    local procedure GetPurchaseLine333(var Item_L: Record Item)
    var
        PurchaseLine_L: Record "Purchase Line";
    Begin
        //QtyCommit_G := 0;
        PurchaseLine_L.Reset();
        PurchaseLine_L.SetRange("No.", Item_L."No.");
        PurchaseLine_L.SetFilter("Location Code", '%1|%2|%3', '333', '666-333', 'OW-333');
        PurchaseLine_L.CalcSums("Outstanding Quantity");
        If not PurchaseLine_L.IsEmpty then begin
            QtyOnOrder_G := PurchaseLine_L."Outstanding Quantity";
            PurchaseLine_333 := true;
        end;

    End;

    local procedure GetPurchaseLine888(var Item_L: Record Item)
    var
        PurchaseLine_L: Record "Purchase Line";
    Begin
        //QtyCommit_G := 0;
        PurchaseLine_L.Reset();
        PurchaseLine_L.SetRange("No.", Item_L."No.");
        PurchaseLine_L.SetFilter("Location Code", '%1|%2|%3', '888', '666-888', 'OW-888');
        PurchaseLine_L.CalcSums("Outstanding Quantity");
        If not PurchaseLine_L.IsEmpty then begin
            QtyOnOrder_G := PurchaseLine_L."Outstanding Quantity";
            PurchaseLine_888 := true;
        end;
    End;
}

