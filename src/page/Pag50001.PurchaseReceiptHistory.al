page 50001 "Purchase Receipt History"
{
    PageType = List;
    Caption = 'Purchase Receipt History';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Purch. Rcpt. Line";
    SourceTableView = order(ascending)where("Order No."=FILTER(<>''));

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(VendorNo;Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor No.';
                }
                field(VendorName;VendorName)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Name';
                }
                field("Document No.";Rec."Order No.")
                {
                    ApplicationArea = All;
                    Caption = 'PO Number';
                }
                field(OrderDate;Rec."Order Date")
                {
                    ApplicationArea = All;
                    Caption = 'PO Date';
                }
                field("Posting Date";Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Actual Receipt Date';
                }
                field("Location Code";Rec."Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                }
                field("No.";Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                }
                field(Description;Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Item Description';
                }
                field(Quantity;Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Qty Received';
                }
                field("Unit Cost";Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Caption = 'Unit Cost';
                }
                field("Extended Amount";(Rec.Quantity * Rec."Unit Cost"))
                {
                    ApplicationArea = All;
                    Caption = 'Extended Amount';
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
    var VendorName: text[100];
    trigger OnAfterGetRecord()var recVendor: Record Vendor;
    begin
        if recVendor.Get(Rec."Buy-from Vendor No.")then VendorName:=recVendor.Name;
    end;
}
