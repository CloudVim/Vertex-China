reportextension 50000 "Extendsalesorderconfirmation" extends "Standard Sales - Order Conf."
{
    dataset
    {
        add(Line)
        {
            column(No__of_Cases;Line."No. of Cases")
            {
            }
            column(No__of_Cases_Ship;"No. of Cases Ship")
            {
            }
        }
    }
}
