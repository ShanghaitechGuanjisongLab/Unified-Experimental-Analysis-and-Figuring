function [DateTimes,Blocks,Duplicate] = MteFiles2Tables(MteFilenames)
FileTable=MATLAB.IOFun.DelimitedStringsToTable(MteFilenames,["Mouse","Design"],".",TimeField=2);
DateTimes=table;
DateTimes.DateTime=FileTable.Time;
Blocks=table;
Blocks.DateTime=FileTable.Time;
Blocks.Design=categorical(FileTable.Design);
DateTimes.Mouse=categorical(FileTable.Mouse);
Blocks.BlockIndex(:)=0x1;
Duplicate=height(unique(DateTimes))<height(DateTimes);
if Duplicate
	UniExp.Exception.DateTime_primary_key_has_duplicate_values.Throw('输入文件名中的日期时间字段有重复值，将从OIR文件内读取日期时间');
end