page 50004 "Inventory Planning"
{

    PageType = List;
    Caption = 'Inventory Planning';
    SourceTable = "Inventory Planning";
    Editable = false;
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite, Assembly, Service;
    PromotedActionCategories = 'New,Process,Report,Item,History,Prices & Discounts,Request Approval,Periodic Activities,Inventory,Attributes';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Collection"; Rec.Collection)
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("UPC Code"; Rec."UPC Code")
                {
                    ApplicationArea = All;
                }
                field("Factory"; Rec.Factory)
                {
                    ApplicationArea = All;
                }
                field("Case Weight"; Rec."Case Weight")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Case Pack"; Rec."Case Pack")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("List Price"; Rec."List Price")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Hand"; Rec."Qty. on Hand")
                {
                    ApplicationArea = All;
                }
                field("Gross Requirement"; Rec."Gross Requirement")
                {
                    ApplicationArea = All;
                }
                field("Net Available"; Rec."Net Available")
                {
                    ApplicationArea = All;
                }
                field("Qty. in Transit"; Rec."Qty. in Transit")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
                {
                    ApplicationArea = All;
                }
                field("Total  Available"; Rec."Total Available")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
    begin
        Rec.UpdateInventoryValues;
        if Rec.FindFirst() then;
    end;


}

