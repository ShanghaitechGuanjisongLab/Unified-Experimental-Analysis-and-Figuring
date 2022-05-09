function [DateTimes,Blocks] = MteFiles2Tables(MteFilenames)
FileTable=MATLAB.IOFun.DelimitedStrings2Table(MteFilenames,["Mouse","Design"],".",TimeField=2);
DateTimes=table;
DateTimes.DateTime=FileTable.Time;
DateTimes.Mouse=FileTable.Mouse;
Blocks=table;
Blocks.BlockUID=(0x001:height(FileTable))';
Blocks.DateTime=FileTable.Time;
Blocks.BlockIndex(:)=0x1;
Blocks.Design=FileTable.Design;