function [DateTimes,Blocks] = MteFiles2Tables(MteFilenames)
FileTable=MATLAB.IOFun.DelimitedStrings2Table(MteFilenames,["Mouse","Design"],".",TimeField=2);
DateTimes=table;
DateTimes.DateTime=FileTable.Time;
DT=sort(DateTimes.DateTime);
if any(DT(1:end-1)==DT(2:end))
	UniExp.UniExpException.DateTime_primary_key_has_duplicate_values.Throw;
end
DateTimes.Mouse=FileTable.Mouse;
Blocks=table;
Blocks.BlockUID=(0x001:height(FileTable))';
Blocks.DateTime=FileTable.Time;
Blocks.BlockIndex(:)=0x1;
Blocks.Design=FileTable.Design;