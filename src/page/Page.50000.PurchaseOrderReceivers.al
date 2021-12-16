page 50000 "Purchase Order Receivers"
{
    PageType = List;
    Caption = 'Purchase Order Receivers';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Purch. Rcpt. Line";
    SourceTableView = order(ascending) where("Order No." = FILTER(<> ''));

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Caption = 'PO Number';
                }
                field("Receiver No"; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Receiver No';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Item Description';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Extended Amount"; (Rec.Quantity * Rec."Unit Cost"))
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

    trigger OnAfterGetRecord()
    var
        recPurchaseHeader: Record "Purchase Header";
    begin

    end;
}