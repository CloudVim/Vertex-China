page 50003 "Back Order report"
{
    PageType = List;
    Caption = 'Back Order report';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sales Line";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document No.";Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Order #';
                }
                field("Bill-to Customer No.";Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                }
                field(CustomerName;CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                }
                field(CustomerPO;recSalesHeader."Your Reference")
                {
                    ApplicationArea = All;
                    Caption = 'Customer PO #';
                }
                field(ExternalDocumentNo;recSalesHeader."External Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'External Document No';
                }
                field("No.";Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item #';
                }
                field("Location Code";Rec."Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                }
                field("Ship-to Name";recSalesHeader."Ship-to Name")
                {
                    ApplicationArea = All;
                    Caption = 'Ship-to Name';
                }
                field("Ship-to State";recSalesHeader."Ship-to County")
                {
                    ApplicationArea = All;
                    Caption = 'Ship-to State';
                }
                field("Customer PO Date";recSalesHeader."Document Date")
                {
                    ApplicationArea = All;
                    Caption = 'Customer PO Date';
                }
                field("Requested Delivery Date";Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                    Caption = 'Requested Delivery Date';
                }
                field(Quantity;Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Qty Ordered';
                }
                field("Quantity Shipped";Rec."Quantity Shipped")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Shipped';
                }
                field("Qty. to Ship";Rec."Qty. to Ship")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. to Ship';
                }
                field("Planned Shipment Date";Rec."Planned Shipment Date")
                {
                    ApplicationArea = All;
                    Caption = 'Planned Shipment Date';
                }
                field("Stock-333";Rec."Stock-333")
                {
                    ApplicationArea = All;
                    Caption = 'Stock-333';
                }
                field("Stock-888";Rec."Stock-888")
                {
                    ApplicationArea = All;
                    Caption = 'Stock-888';
                }
                field("Stock-999";Rec."Stock-999")
                {
                    ApplicationArea = All;
                    Caption = 'Stock-999';
                }
                field("Stock-666-W";Rec."Stock-666-W")
                {
                    ApplicationArea = All;
                    Caption = 'Stock-666-W';
                }
                field("Stock-666-E";Rec."Stock-666-E")
                {
                    ApplicationArea = All;
                    Caption = 'Stock-666-E';
                }
            }
        }
        area(Factboxes)
        {
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin
                end;
            }
        }
    }
    var reCustomer: Record Customer;
    CustomerName: text[100];
    recSalesHeader: Record "Sales Header";
    trigger OnOpenPage()var begin
        Rec.CalcFields(Status);
        Rec.SetFilter(Status, '%1', Rec.Status::Open);
        Rec.SetFilter("Document Type", '%1', Rec."Document Type"::Order);
    end;
    trigger OnAfterGetRecord()var recILE: Record "Item Ledger Entry";
    recSalesLine: Record "Sales Line";
    StockQty1: Decimal;
    QtyOnSales1: Decimal;
    begin
        if recSalesHeader.Get(Rec."Document Type", Rec."Document No.")then;
        if reCustomer.Get(Rec."Bill-to Customer No.")then CustomerName:=reCustomer.Name;
        CASE Rec."Location Code" of '333': begin
            recILE.reset;
            recILE.SetRange("Item No.", rec."No.");
            recILE.SetRange("Global Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recILE.SetRange("Global Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recILE.SetRange("Location Code", '333');
            recILE.CalcSums(Quantity);
            StockQty1:=recILE.Quantity;
            recSalesLine.Reset();
            recSalesLine.SetRange("Document Type", recSalesLine."Document Type"::Order);
            recSalesLine.SetRange(Type, Rec.Type);
            recSalesLine.SetRange("No.", Rec."No.");
            recSalesLine.SetRange("Shortcut Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recSalesLine.SetRange("Shortcut Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recSalesLine.SetRange("Location Code", '333');
            recSalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSales1:=recSalesLine."Outstanding Qty. (Base)";
            Rec."Stock-333":=StockQty1 - QtyOnSales1;
        end;
        '888': begin
            recILE.reset;
            recILE.SetRange("Item No.", rec."No.");
            recILE.SetRange("Global Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recILE.SetRange("Global Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recILE.SetRange("Location Code", '888');
            recILE.CalcSums(Quantity);
            StockQty1:=recILE.Quantity;
            recSalesLine.Reset();
            recSalesLine.SetRange("Document Type", recSalesLine."Document Type"::Order);
            recSalesLine.SetRange(Type, Rec.Type);
            recSalesLine.SetRange("No.", Rec."No.");
            recSalesLine.SetRange("Shortcut Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recSalesLine.SetRange("Shortcut Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recSalesLine.SetRange("Location Code", '888');
            recSalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSales1:=recSalesLine."Outstanding Qty. (Base)";
            Rec."Stock-888":=StockQty1 - QtyOnSales1;
        end;
        '999': begin
            recILE.reset;
            recILE.SetRange("Item No.", rec."No.");
            recILE.SetRange("Global Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recILE.SetRange("Global Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recILE.SetRange("Location Code", '999');
            recILE.CalcSums(Quantity);
            StockQty1:=recILE.Quantity;
            recSalesLine.Reset();
            recSalesLine.SetRange("Document Type", recSalesLine."Document Type"::Order);
            recSalesLine.SetRange(Type, Rec.Type);
            recSalesLine.SetRange("No.", Rec."No.");
            recSalesLine.SetRange("Shortcut Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recSalesLine.SetRange("Shortcut Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recSalesLine.SetRange("Location Code", '999');
            recSalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSales1:=recSalesLine."Outstanding Qty. (Base)";
            Rec."Stock-999":=StockQty1 - QtyOnSales1;
        end;
        '666': begin
            recILE.reset;
            recILE.SetRange("Item No.", rec."No.");
            recILE.SetRange("Global Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recILE.SetRange("Global Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recILE.SetRange("Location Code", '666');
            recILE.CalcSums(Quantity);
            StockQty1:=recILE.Quantity;
            recSalesLine.Reset();
            recSalesLine.SetRange("Document Type", recSalesLine."Document Type"::Order);
            recSalesLine.SetRange(Type, Rec.Type);
            recSalesLine.SetRange("No.", Rec."No.");
            recSalesLine.SetRange("Shortcut Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recSalesLine.SetRange("Shortcut Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recSalesLine.SetRange("Location Code", '666');
            recSalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSales1:=recSalesLine."Outstanding Qty. (Base)";
            Rec."Stock-666-W":=StockQty1 - QtyOnSales1;
        end;
        '666-1': begin
            recILE.reset;
            recILE.SetRange("Item No.", rec."No.");
            recILE.SetRange("Global Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recILE.SetRange("Global Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recILE.SetRange("Location Code", '666-1');
            recILE.CalcSums(Quantity);
            StockQty1:=recILE.Quantity;
            recSalesLine.Reset();
            recSalesLine.SetRange("Document Type", recSalesLine."Document Type"::Order);
            recSalesLine.SetRange(Type, Rec.Type);
            recSalesLine.SetRange("No.", Rec."No.");
            recSalesLine.SetRange("Shortcut Dimension 1 Code", Rec."Shortcut Dimension 1 Code");
            recSalesLine.SetRange("Shortcut Dimension 2 Code", Rec."Shortcut Dimension 2 Code");
            recSalesLine.SetRange("Location Code", '666-1');
            recSalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSales1:=recSalesLine."Outstanding Qty. (Base)";
            Rec."Stock-666-E":=StockQty1 - QtyOnSales1;
        end;
        end;
        Rec.Modify();
    end;
}
