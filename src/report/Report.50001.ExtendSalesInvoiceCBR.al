reportextension 50001 ExtendSalesInovice_CBR extends "Standard Sales - Invoice" //1306
{

    dataset
    {
        add(Line)
        {
            column(No__of_Cases; Line."No. of Cases")
            {

            }
            column(No__of_Cases_Ship; "No. of Cases Ship")
            {

            }
        }
    }

}