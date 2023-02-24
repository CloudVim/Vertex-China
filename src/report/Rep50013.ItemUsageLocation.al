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

            column(Factory; Factory) { }
            column(Case_Pack; "Case Pack") { }
            column(Description; Description)
            {
            }
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = field("No.");
                DataItemTableView = SORTING("Item No.", "Location Code")
                  WHERE("Location Code" = filter('333|OW-333|888|OW-888|666|OW-CST'));
                RequestFilterFields = "Item No.";
                column(ItemNo; "Item No.") { }
                column(Item_Category_Code; "Item Category Code") { }
                column(QtyInHand_333; QtyInHand_333) { }
                column(QtyInHand_666; QtyInHand_666) { }
                column(QtyInHand_888; QtyInHand_888) { }
                column(CompanyInformation_Name; CompInfo.Name) { }
                column(QtyonWater_333; QtyonWater_333) { }
                column(QtyonWater_666; QtyonWater_666) { }
                column(QtyonWater_888; QtyonWater_888) { }
                column(QtyCommit_333; QtyCommit_333) { }
                column(QtyCommit_888; QtyCommit_888) { }
                column(QtyOnOrder_G; QtyOnOrder_G) { }
                column(AvgSales_G; AvgSales_G) { }
                trigger OnPreDataItem()
                var
                begin
                    QtyInHand_333 := 0;
                    QtyInHand_666 := 0;
                    QtyInHand_888 := 0;
                    QtyonWater_333 := 0;
                    QtyonWater_666 := 0;
                    QtyonWater_888 := 0;

                End;

                trigger OnAfterGetRecord()
                var
                begin

                    If "Location Code" = '333' then
                        QtyInHand_333 += "Remaining Quantity";

                    If "Location Code" = '666' then
                        QtyInHand_666 += "Remaining Quantity";

                    If "Location Code" = '888' then
                        QtyInHand_888 += "Remaining Quantity";

                    //QtyInTrans = Qt on water //AGT_DS_021723
                    If "Location Code" = 'OW-333' then
                        QtyonWater_333 += "Remaining Quantity";

                    If "Location Code" = 'OW-CST' then
                        QtyonWater_666 += "Remaining Quantity";

                    If "Location Code" = 'OW-888' then
                        QtyonWater_888 += "Remaining Quantity";

                    QtyCommit_333 := 0;
                    QtyCommit_888 := 0;
                    AvgSales_G := 0;
                    QtyOnOrder_G := 0;

                    If not SalesLine_333 then
                        GetsalesLine_333(Item);
                    If not SalesLine_888 then
                        GetsalesLine_888(Item);
                    If not PurchaseLine_1 then
                        GetPurchaseLine(Item);
                    If Not AVGSalesLine_1 then
                        GetPostedsalesLine(Item);
                    //end;

                end;
            }
            trigger OnAfterGetRecord()
            Var

            begin
                SalesLine_333 := false;
                SalesLine_888 := false;
                PurchaseLine_1 := false;
                AVGSalesLine_1 := false;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        //layout
        // {
        //    
        // }

        // actions
        // {
        // }
    }

    labels
    {
    }

    var
        // Location_L: Option " ","333","666","888";
        CompanyInformation_Name: Text;
        CompInfo: Record "Company Information";
        QtyInHand_333: Decimal;
        QtyInHand_666: Decimal;
        QtyInHand_888: Decimal;
        QtyonWater_333: Decimal;
        QtyonWater_666: Decimal;
        QtyonWater_888: Decimal;
        QtyCommit_333: Decimal;
        QtyCommit_888: Decimal;
        QtyOnOrder_G: Decimal;
        AvgSales_G: Decimal;
        SalesLine_333: Boolean;
        SalesLine_888: Boolean;
        PurchaseLine_1: Boolean;
        AVGSalesLine_1: Boolean;


    local procedure GetsalesLine_333(var Item_L: Record Item)
    var
        SalesLine_L: Record "Sales Line";
    Begin
        SalesLine_L.Reset();
        SalesLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        SalesLine_L.SetRange("Document Type", SalesLine_L."Document Type"::Order);
        SalesLine_L.SetRange("No.", Item_L."No.");
        SalesLine_L.SetRange("Location Code", '333');
        SalesLine_L.CalcSums("Outstanding Quantity");
        If not SalesLine_L.IsEmpty then begin
            QtyCommit_333 := SalesLine_L."Outstanding Quantity";
            SalesLine_333 := true;
        end;
    End;

    local procedure GetsalesLine_888(var Item_L: Record Item)
    var
        SalesLine_L: Record "Sales Line";
    Begin
        SalesLine_L.Reset();
        SalesLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        SalesLine_L.SetRange("Document Type", SalesLine_L."Document Type"::Order);
        SalesLine_L.SetRange("No.", Item_L."No.");
        SalesLine_L.SetRange("Location Code", '888');
        SalesLine_L.CalcSums("Outstanding Quantity");
        If not SalesLine_L.IsEmpty then begin
            QtyCommit_888 := SalesLine_L."Outstanding Quantity";
            SalesLine_888 := true;
        end;
    End;


    local procedure GetPurchaseLine(var Item_L: Record Item)
    var
        PurchaseLine_L: Record "Purchase Line";
    Begin
        PurchaseLine_L.Reset();
        PurchaseLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        PurchaseLine_L.SetRange("Document Type", PurchaseLine_L."Document Type"::Order);
        PurchaseLine_L.SetRange("No.", Item_L."No.");
        PurchaseLine_L.CalcSums("Outstanding Quantity");
        If not PurchaseLine_L.IsEmpty then begin
            QtyOnOrder_G := PurchaseLine_L."Outstanding Quantity";
            PurchaseLine_1 := true;
        end;
    End;

    local procedure GetPostedsalesLine(var Item_L: Record Item)
    var
        SalesInvLine_L: Record "Sales Invoice Line";
        StartDate: Date;
    Begin

        StartDate := 0D;
        StartDate := CalcDate('-6M', WorkDate());
        SalesInvLine_L.Reset();
        SalesInvLine_L.SetCurrentKey("No.", "Location Code");
        SalesInvLine_L.SetRange("No.", Item_L."No.");

        SalesInvLine_L.SetFilter("Posting Date", '%1..%2', StartDate, WorkDate());
        SalesInvLine_L.CalcSums(Quantity);
        If not SalesInvLine_L.IsEmpty then begin
            If SalesInvLine_L.Quantity <> 0 then
                AvgSales_G := SalesInvLine_L.Quantity / 6;
            AVGSalesLine_1 := true;
        end;
    End;
}

