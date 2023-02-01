codeunit 50001 "SendMail"
{
    trigger OnRun()
    begin
        Body := 'Hi,';
        Body += 'Please find attached Daily Invoicing Report';

        SendToList.Add('deepeshsoni1451@gmail.com');
        EmailMessage.create(SendToList, 'Daily Invoicing Report ', Body, TRUE, SendToCcList, SendToBccList);
        tmpBlob.CreateOutStream(OutStr);
        Report.SaveAs(Report::"Daily Invoicing Report", '', ReportFormat::Excel, OutStr);
        tmpBlob.CreateInStream(InStr);
        EmailMessage.AddAttachment('Daily Invoicing Report.Xlsx', 'Xlsx', InStr);
        If Email.Send(EmailMessage) then
            Message('Mail has been sent');

    end;

    VAR

        SendToList: List of [Text];
        SendToCcList: List of [Text];
        SendToBccList: List of [Text];
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        Body: Text;
        tmpBlob: Codeunit "Temp Blob";
        cnv64: Codeunit "Base64 Convert";
        InStr: InStream;
        OutStr: OutStream;

}
