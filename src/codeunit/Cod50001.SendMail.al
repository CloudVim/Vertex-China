codeunit 50001 "SendMail"
{
    trigger OnRun()
    var
        SalesReceivablesSetup_L: Record "Sales & Receivables Setup";
        Email_L: Text;
        Position: Integer;
        FindChar: Text;
        NoOfEmail: Integer;
        I: Integer;
        Strlength1: Integer;
        Strlength2: Integer;
    begin
        Strlength1 := 0;
        Strlength2 := 0;
        Clear(Email_L);
        If SalesReceivablesSetup_L.Get() then
            If SalesReceivablesSetup_L.DailyInvoicing_Mail <> '' then begin
                Body := 'Hi,';
                Body += 'Please find attached Daily Invoicing Report';

                Email_L := SalesReceivablesSetup_L.DailyInvoicing_Mail;
                Position := StrPos(Email_L, ' ');
                If Position <> 0 then begin
                    FindChar := CopyStr(Email_L, Position - 1, 1);
                    If (FindChar = ';') Or (FindChar = ',') then begin
                        Email_L := DelChr(Email_L, '=', ' ');
                        If FindChar = ';' then
                            Email_L := ConvertStr(Email_L, ';', ',');
                        NoOfEmail := ((StrLen(Email_L) - StrLen(DelChr(Email_L, '=', ','))) + 1);
                        For I := 1 to NoOfEmail do begin
                            SendToList.Add(SelectStr(I, Email_L));
                        end;
                    end;
                end Else begin
                    If StrPos(Email_L, ';') > 0 then
                        Email_L := ConvertStr(Email_L, ';', ',');
                    NoOfEmail := ((StrLen(Email_L) - StrLen(DelChr(Email_L, '=', ','))) + 1);
                    For I := 1 to NoOfEmail do begin
                        SendToList.Add(SelectStr(I, Email_L));
                    end;
                end;
                EmailMessage.create(SendToList, 'Daily Invoicing Report ', Body, TRUE, SendToCcList, SendToBccList);
                tmpBlob.CreateOutStream(OutStr);
                Report.SaveAs(Report::"Daily Invoicing Report", '', ReportFormat::Excel, OutStr);
                tmpBlob.CreateInStream(InStr);
                EmailMessage.AddAttachment('Daily Invoicing Report.Xlsx', 'Xlsx', InStr);
                Email.Send(EmailMessage)
            end;
    End;

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
