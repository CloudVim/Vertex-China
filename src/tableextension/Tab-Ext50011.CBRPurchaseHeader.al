tableextension 50011 "CBR_PurchaseHeader" extends "Purchase Header"
{
    fields
    {
        field(50000; "Work Description"; BLOB)
        {
            Caption = 'Work Description';
        }
    }
    procedure SetWorkDescription(NewWorkDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Rec."Work Description");
        Rec."Work Description".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewWorkDescription);
        Rec.Modify;
    end;

    // procedure GetWorkDescValue(var WorkDesc: Text)
    // var
    //     inStr: InStream;
    // begin
    //     CalcFields("Work Description");
    //     if "Work Description".HasValue() then begin
    //         "Work Description".CreateInStream(inStr);
    //         inStr.ReadText(WorkDesc);
    //     end
    // end;

    procedure GetWorkDescription() WorkDescription: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Work Description");
        "Work Description".CreateInStream(InStream, TEXTENCODING::UTF8);
        if not TypeHelper.TryReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator(), WorkDescription) then
            Message(ReadingDataSkippedMsg, FieldCaption("Work Description"));
    end;

    var
        myInt: Integer;
        ReadingDataSkippedMsg: Label 'Loading field %1 will be skipped because there was an error when reading the data.\To fix the current data, contact your administrator.\Alternatively, you can overwrite the current data by entering data in the field.', Comment = '%1=field caption';

}