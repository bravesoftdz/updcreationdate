{**
Program will update the creation date to
match the date modified to all the files
in a given directory
**}

program UpdCreationDate;
{$APPTYPE CONSOLE}
{$R *.RES}
uses
  SysUtils, Windows,
  ColorUtils in 'ColorUtils.pas';
var
  I: Integer;
  showFiles: Boolean;
  strFolderName: string;

procedure ShowHelp;
begin
  writeln(' ');
  ColorWrite('Update the created date with the values of the date modified.',14,True);
  writeln(' ');
  writeln(' USAGE: UpdCreationDate <Dir-To_Modify> [-d]');
  writeln('   -d to display the file processed');
  writeln(' ');
end;

function SetDateToFile(const FileName: string): Boolean;
var
  hFile: THandle;
  FTimeC, FTimeA, FTimeM : TFileTime;
begin
  Result := False;
  try
    hFile := FileOpen(FileName, fmOpenWrite or fmShareDenyNone);
    if (hFile > 0) then
    begin
      GetFileTime(hFile, @FTimeC, @FTimeA, @FTimeM);
      Result := SetFileTime(hFile, @FTimeM, @FTimeA, @FTimeM);
    end;
  finally
    FileClose(hFile);
  end;
end;

procedure updateCreationDate(strFolderName: String; showFiles: Boolean);
var
  tSR : TSearchRec;
begin
  if FindFirst(strFolderName + '\*.*', $20, tSR) = 0 then
  begin
    repeat
      if showFiles then
        Writeln(intToStr(tSR.Time) + '   ' + strFolderName + '\' + tSR.Name);
      if not SetDateToFile(strFolderName + '\' + tSR.Name) then
      begin
        ColorWrite(' Failed:   ',12); ColorWrite('' + tSR.Name,14,True);
      end;
    until (FindNext(tSR) <> 0);
  end;

  if FindFirst(strFolderName + '\*.*', faDirectory, tSR) = 0 then
  begin
    repeat
      If (Pos('.', tSR.Name) = 0) and (tSR.Attr <> 32) then
      begin
        if showFiles then
          ColorWrite('SubFolder: '+tSR.Name+' '+IntToStr(tSR.Attr),14,True);
        updateCreationDate(strFolderName + '\' + tSR.Name, showFiles);
      end;
    until (FindNext(tSR) <> 0);
  end;
end;

begin
  if (ParamCount = 0) then
    ShowHelp
  else
  begin
    if (Pos(ParamStr(1), '/?') > 0) then
      ShowHelp
    else
    begin
      showFiles := False;
      strFolderName := '';
      for I := 1 to ParamCount do
      begin
        if UpperCase(ParamStr(I)) = '-D' then
          showFiles := True
        else
          if DirectoryExists(ParamStr(I)) then
            strFolderName := ParamStr(I);
      end;
      if strFolderName <> '' then
        updateCreationDate(strFolderName, showFiles)
      else
      begin
        writeln('   -d to display the file processed');
        writeln(' ');
        ShowHelp
      end;

    end;
  end;
end.
