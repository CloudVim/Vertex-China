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
                column(ItemNo; "Item No.")
                {
                }
                column(Item_Category_Code; "Item Category Code") { }

                // column(LocationCode; locationCode)
                // {
                // }
                column(QtyInHand_333; QtyInHand_333) { }
                column(QtyInHand_666; QtyInHand_666) { }
                column(QtyInHand_888; QtyInHand_888) { }

                //column(QtyReserved_G; QtyReserved_G) { }

                column(CompanyInformation_Name; CompInfo.Name)
                { }
                //column(QtyInTrans_G; QtyInTrans_G) { }
                column(QtyonWater_333; QtyonWater_333) { }
                column(QtyonWater_666; QtyonWater_666) { }
                column(QtyonWater_888; QtyonWater_888) { }
                column(QtyCommit_G; QtyCommit_G) { }
                column(QtyOnOrder_G; QtyOnOrder_G) { }
                column(AvgSales_G; AvgSales_G) { }
                trigger OnPreDataItem()
                var
                //ILE
                begin
                    QtyInHand_333 := 0;
                    QtyInHand_666 := 0;
                    QtyInHand_888 := 0;
                    QtyonWater_333 := 0;
                    QtyonWater_666 := 0;
                    QtyonWater_888 := 0;
                    // If Location_L <> Location_L::" " then Begin
                    //     If Location_L = Location_L::"333" then
                    //         SetFilter("Location Code", '%1|%2', '333', 'OW-333')
                    //     Else
                    //         If Location_L = Location_L::"666" then
                    //             SetFilter("Location Code", '%1|%2', '666', 'OW-CST')
                    //         else
                    //             If Location_L = Location_L::"888" then
                    //                 SetFilter("Location Code", '%1|%2', '888', 'OW-888')
                    // End;
                End;

                trigger OnAfterGetRecord()
                var
                begin
                    // Clear(locationCode);
                    // Clear(LocationCodeReserved);
                    // If ("Location Code" = '333') Or ("Location Code" = 'OW-333') then
                    //     locationCode := '333'
                    // Else
                    //     If ("Location Code" = '888') Or ("Location Code" = 'OW-888') then
                    //         locationCode := '888'
                    //     else
                    //         If ("Location Code" = '666') Or ("Location Code" = 'OW-CST') then
                    //             locationCode := '666';

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

                    QtyCommit_G := 0;
                    AvgSales_G := 0;
                    QtyOnOrder_G := 0;
                    //If Location_L <> Location_L::" " then begin
                    // If locationCode = '333' then begin
                    //     If not SalesLine_333 then
                    //         GetsalesLine333(Item);
                    //     IF not AVGSalesLine_333 then
                    //         GetPostedsalesLine333(Item);
                    //     If not PurchaseLine_333 then
                    //         GetPurchaseLine333(Item);
                    // end;
                    // If locationCode = '666' then begin
                    //     If not SalesLine_666 then
                    //         GetsalesLine666(Item);
                    //     If Not AVGSalesLine_666 then
                    //         GetPostedsalesLine666(Item);
                    //     If not PurchaseLine_666 then
                    //         GetPurchaseLine666(Item);
                    // end;
                    // If locationCode = '888' then begin
                    //     If not SalesLine_888 then
                    //         GetsalesLine888(Item);
                    //     If Not AVGSalesLine_888 then
                    //         GetPostedsalesLine888(Item);
                    //     If not PurchaseLine_888 then
                    //         GetPurchaseLine888(Item);
                    // end;
                    // End
                    //Else begin
                    If not SalesLine_1 then
                        GetsalesLine(Item);
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
                SalesLine_1 := false;
                SalesLine_333 := false;
                SalesLine_666 := false;
                SalesLine_888 := false;
                PurchaseLine_1 := false;
                PurchaseLine_333 := false;
                PurchaseLine_666 := false;
                PurchaseLine_888 := false;
                AVGSalesLine_1 := false;
                AVGSalesLine_333 := false;
                AVGSalesLine_666 := false;
                AVGSalesLine_888 := false;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        //layout
        // {
        //     area(content)
        //     {
        //         group("Filter")
        //         {
        //             Caption = 'Filter';

        //             field(Location_L; Location_L)
        //             {
        //                 ApplicationArea = All;
        //                 Caption = 'Location';
        //                 OptionCaption = ' ,333,666,888';
        //             }
        //         }
        //     }
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
        //QtyInTrans_G: Decimal;
        // QtyReserved_G: Decimal;
        QtyCommit_G: Decimal;
        QtyOnOrder_G: Decimal;
        AvgSales_G: Decimal;
        //locationCode: Text;
        //LocationCodeReserved: Text;
        SalesLine_1: Boolean;
        SalesLine_333: Boolean;
        SalesLine_666: Boolean;
        SalesLine_888: Boolean;
        PurchaseLine_1: Boolean;
        PurchaseLine_333: Boolean;
        PurchaseLine_666: Boolean;
        PurchaseLine_888: Boolean;
        AVGSalesLine_1: Boolean;
        AVGSalesLine_333: Boolean;
        AVGSalesLine_666: Boolean;
        AVGSalesLine_888: Boolean;

    local procedure GetsalesLine333(var Item_L: Record Item)
    var
        SalesLine_L: Record "Sales Line";
    Begin
        //QtyCommit_G := 0;
        SalesLine_L.Reset();
        SalesLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        SalesLine_L.SetRange("Document Type", SalesLine_L."Document Type"::Order);
        SalesLine_L.SetRange("No.", Item_L."No.");
        SalesLine_L.SetFilter("Location Code", '%1', '333');//AGT_DS_02172023 new requirement
        SalesLine_L.CalcSums("Outstanding Quantity");
        If not SalesLine_L.IsEmpty then begin
            QtyCommit_G := SalesLine_L."Outstanding Quantity";
            SalesLine_333 := true;
        end;

    End;

    local procedure GetsalesLine666(var Item_L: Record Item)
    var
        SalesLine_L: Record "Sales Line";
    Begin
        //QtyCommit_G := 0;
        SalesLine_L.Reset();
        SalesLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        SalesLine_L.SetRange("Document Type", SalesLine_L."Document Type"::Order);
        SalesLine_L.SetRange("No.", Item_L."No.");
        SalesLine_L.SetFilter("Location Code", '%1', '666');//AGT_DS_02172023 new requirement
        SalesLine_L.CalcSums("Outstanding Quantity");
        If not SalesLine_L.IsEmpty then begin
            QtyCommit_G := SalesLine_L."Outstanding Quantity";
            SalesLine_666 := true;
        end;
    End;

    local procedure GetsalesLine888(var Item_L: Record Item)
    var
        SalesLine_L: Record "Sales Line";
    Begin
        //QtyCommit_G := 0;
        SalesLine_L.Reset();
        SalesLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        SalesLine_L.SetRange("Document Type", SalesLine_L."Document Type"::Order);
        SalesLine_L.SetRange("No.", Item_L."No.");
        SalesLine_L.SetFilter("Location Code", '%1', '888');//AGT_DS_021723
        SalesLine_L.CalcSums("Outstanding Quantity");
        If not SalesLine_L.IsEmpty then begin
            QtyCommit_G := SalesLine_L."Outstanding Quantity";
            SalesLine_888 := true;
        end;
    End;

    local procedure GetsalesLine(var Item_L: Record Item)
    var
        SalesLine_L: Record "Sales Line";
    Begin
        //QtyCommit_G := 0;
        SalesLine_L.Reset();
        SalesLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        SalesLine_L.SetRange("Document Type", SalesLine_L."Document Type"::Order);
        SalesLine_L.SetRange("No.", Item_L."No.");
        //SalesLine_L.SetFilter("Location Code", '%1', '888');//AGT_DS_021723
        SalesLine_L.CalcSums("Outstanding Quantity");
        If not SalesLine_L.IsEmpty then begin
            QtyCommit_G := SalesLine_L."Outstanding Quantity";
            SalesLine_1 := true;
        end;
    End;

    local procedure GetPurchaseLine333(var Item_L: Record Item)
    var
        PurchaseLine_L: Record "Purchase Line";
    Begin
        //QtyCommit_G := 0;
        PurchaseLine_L.Reset();
        PurchaseLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        PurchaseLine_L.SetRange("Document Type", PurchaseLine_L."Document Type"::Order);
        PurchaseLine_L.SetRange("No.", Item_L."No.");
        PurchaseLine_L.SetFilter("Location Code", '%1', '333');//AGT_DS_021723
        PurchaseLine_L.CalcSums("Outstanding Quantity");
        If not PurchaseLine_L.IsEmpty then begin
            QtyOnOrder_G := PurchaseLine_L."Outstanding Quantity";
            PurchaseLine_333 := true;
        end;
    End;

    local procedure GetPurchaseLine666(var Item_L: Record Item)
    var
        PurchaseLine_L: Record "Purchase Line";
    Begin
        //QtyCommit_G := 0;
        PurchaseLine_L.Reset();
        PurchaseLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        PurchaseLine_L.SetRange("Document Type", PurchaseLine_L."Document Type"::Order);
        PurchaseLine_L.SetRange("No.", Item_L."No.");
        PurchaseLine_L.SetFilter("Location Code", '%1', '666');//AGT_DS_021723
        PurchaseLine_L.CalcSums("Outstanding Quantity");
        If not PurchaseLine_L.IsEmpty then begin
            QtyOnOrder_G := PurchaseLine_L."Outstanding Quantity";
            PurchaseLine_666 := true;
        end;
    End;

    local procedure GetPurchaseLine888(var Item_L: Record Item)
    var
        PurchaseLine_L: Record "Purchase Line";
    Begin
        //QtyCommit_G := 0;
        PurchaseLine_L.Reset();
        PurchaseLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        PurchaseLine_L.SetRange("Document Type", PurchaseLine_L."Document Type"::Order);
        PurchaseLine_L.SetRange("No.", Item_L."No.");
        PurchaseLine_L.SetFilter("Location Code", '%1', '888');//AGT_DS_021723
        PurchaseLine_L.CalcSums("Outstanding Quantity");
        If not PurchaseLine_L.IsEmpty then begin
            QtyOnOrder_G := PurchaseLine_L."Outstanding Quantity";
            PurchaseLine_888 := true;
        end;
    End;

    local procedure GetPurchaseLine(var Item_L: Record Item)
    var
        PurchaseLine_L: Record "Purchase Line";
    Begin
        //QtyCommit_G := 0;
        PurchaseLine_L.Reset();
        PurchaseLine_L.SetCurrentKey("Document Type", "No.", "Location Code");
        PurchaseLine_L.SetRange("Document Type", PurchaseLine_L."Document Type"::Order);
        PurchaseLine_L.SetRange("No.", Item_L."No.");
        //PurchaseLine_L.SetFilter("Location Code", '%1', '888');//AGT_DS_021723
        PurchaseLine_L.CalcSums("Outstanding Quantity");
        If not PurchaseLine_L.IsEmpty then begin
            QtyOnOrder_G := PurchaseLine_L."Outstanding Quantity";
            PurchaseLine_1 := true;
        end;
    End;


    local procedure GetPostedsalesLine333(var Item_L: Record Item)
    var
        SalesInvLine_L: Record "Sales Invoice Line";
        StartDate: Date;
    Begin
        //QtyCommit_G := 0;
        StartDate := 0D;
        StartDate := CalcDate('-6M', WorkDate());
        SalesInvLine_L.Reset();
        SalesInvLine_L.SetCurrentKey("No.", "Location Code");
        SalesInvLine_L.SetRange("No.", Item_L."No.");
        SalesInvLine_L.SetFilter("Location Code", '%1', '333');//AGT_DS_021723
        SalesInvLine_L.SetFilter("Posting Date", '%1..%2', StartDate, WorkDate());
        SalesInvLine_L.CalcSums(Quantity);
        If not SalesInvLine_L.IsEmpty then begin
            If SalesInvLine_L.Quantity <> 0 then
                AvgSales_G := SalesInvLine_L.Quantity / 6;
            AVGSalesLine_333 := true;
        end;
    End;

    local procedure GetPostedsalesLine666(var Item_L: Record Item)
    var
        SalesInvLine_L: Record "Sales Invoice Line";
        StartDate: Date;
    Begin
        //QtyCommit_G := 0;
        StartDate := 0D;
        StartDate := CalcDate('-6M', WorkDate());
        SalesInvLine_L.Reset();
        SalesInvLine_L.SetCurrentKey("No.", "Location Code");
        SalesInvLine_L.SetRange("No.", Item_L."No.");
        SalesInvLine_L.SetFilter("Location Code", '%1', '666');//AGT_DS_021723
        SalesInvLine_L.SetFilter("Posting Date", '%1..%2', StartDate, WorkDate());
        SalesInvLine_L.CalcSums(Quantity);
        If not SalesInvLine_L.IsEmpty then begin
            If SalesInvLine_L.Quantity <> 0 then
                AvgSales_G := SalesInvLine_L.Quantity / 6;
            AVGSalesLine_666 := true;
        end;
    End;

    local procedure GetPostedsalesLine888(var Item_L: Record Item)
    var
        SalesInvLine_L: Record "Sales Invoice Line";
        StartDate: Date;
    Begin
        //QtyCommit_G := 0;
        StartDate := 0D;
        StartDate := CalcDate('-6M', WorkDate());
        SalesInvLine_L.Reset();
        SalesInvLine_L.SetCurrentKey("No.", "Location Code");
        SalesInvLine_L.SetRange("No.", Item_L."No.");
        SalesInvLine_L.SetFilter("Location Code", '%1', '888');//AGT_DS_021723
        SalesInvLine_L.SetFilter("Posting Date", '%1..%2', StartDate, WorkDate());
        SalesInvLine_L.CalcSums(Quantity);
        If not SalesInvLine_L.IsEmpty then begin
            If SalesInvLine_L.Quantity <> 0 then
                AvgSales_G := SalesInvLine_L.Quantity / 6;
            AVGSalesLine_888 := true;
        end;
    End;

    local procedure GetPostedsalesLine(var Item_L: Record Item)
    var
        SalesInvLine_L: Record "Sales Invoice Line";
        StartDate: Date;
    Begin
        //QtyCommit_G := 0;
        StartDate := 0D;
        StartDate := CalcDate('-6M', WorkDate());
        SalesInvLine_L.Reset();
        SalesInvLine_L.SetCurrentKey("No.", "Location Code");
        SalesInvLine_L.SetRange("No.", Item_L."No.");
        //SalesInvLine_L.SetFilter("Location Code", '%1', '888');//AGT_DS_021723
        SalesInvLine_L.SetFilter("Posting Date", '%1..%2', StartDate, WorkDate());
        SalesInvLine_L.CalcSums(Quantity);
        If not SalesInvLine_L.IsEmpty then begin
            If SalesInvLine_L.Quantity <> 0 then
                AvgSales_G := SalesInvLine_L.Quantity / 6;
            AVGSalesLine_1 := true;
        end;
    End;
}

