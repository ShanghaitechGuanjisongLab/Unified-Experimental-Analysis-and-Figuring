function [DateTimes,Blocks] = MteFiles2Tables(MteFilenames)
FileTable=MATLAB.IOFun.DelimitedStrings2Table(MteFilenames,["Mouse","Design"],".",TimeField=2);
DateTimes=table;
DateTimes.DateTime=FileTable.Time;
UD=unique(DateTimes);
Blocks=table;
NumFiles=height(FileTable);
Blocks.DateTime=FileTable.Time;
Blocks.Design=categorical(FileTable.Design);
if height(UD)==height(DateTimes)
	DateTimes.Mouse=categorical(FileTable.Mouse);
	Blocks.BlockIndex(:)=0x1;
else
	UniExp.Exception.DateTime_primary_key_has_duplicate_values.Warn('输入日期时间有重复值，将根据输入顺序排列BlockIndex');
	DateTimes=UD;
	Blocks.FileIndex=(0x1:NumFiles)';
	Blocks=sortrows(Blocks,["DateTime","FileIndex"]);
	Blocks.BlockIndex(1)=0x1;
	for B=2:NumFiles
		if Blocks.DateTime(B)==Blocks.DateTime(B-1)
			Blocks.BlockIndex(B)=Blocks.BlockIndex(B-1)+1;
		else
			Blocks.BlockIndex(B)=0x1;
		end
	end
	Blocks=sortrows(Blocks,"FileIndex");
	Blocks.FileIndex=[];
end