%[text] 从一群ImageJ ROI中减去另一群ImageJ ROI，即作差集。仅比较每个ROI的文件名，文件名相同即认为ROI相同。
%[text] ### 名称-值对组参数
%[text] RoiAPath(1,1)string，被减的ImageJ RoiSet。如不指定，将打开文件选择对话框。
%[text] RoiBPath(1,1)string，要减去的ImageJ RoiSet。如不指定，将打开文件选择对话框。
%[text] RoiCPath(1,1)string，输出文件路径。这个路径要求不一定能完全实现：
%[text] - 如果集合A被减光了，将不输出任何文件
%[text] - 如果只剩1个，则将在此处指定的目录下放置那个剩下的.roi文件，文件名保留那个原本的文件名
%[text] - 如果剩余多个，则按照此文件名放置一个.zip文件 \
%[text] ### 返回值
%[text] RoiCPath(1,1)string，实际输出的文件路径，不一定与输入的该参数相同。如果没有输出任何文件，返回""。
function RoiCPath=ImageJRoiDiff(options)
arguments
	options.RoiAPath(1,1)string=MATLAB.UITools.OpenFileDialog(Filter="RoiSet文件|*.roi;*.zip",Title="选择被减的RoiSet")
	options.RoiBPath(1,1)string=MATLAB.UITools.OpenFileDialog(Filter="RoiSet文件|*.roi;*.zip",Title="选择减去的RoiSet")
	options.RoiCPath(1,1)string=MATLAB.UITools.SaveFileDialog(Filter="RoiSet文件|*.zip",Title="选择保存位置")
end
RoiAPath=options.RoiAPath;
RoiBPath=options.RoiBPath;
RoiCPath=options.RoiCPath;
[Directory,CName,Extension]=fileparts(RoiCPath);
NET.addAssembly("System.IO.Compression");
import System.IO.File.*;
import System.IO.Compression.*;
[~,ANames,AExtension]=fileparts(RoiAPath);
[~,BNames,BExtension]=fileparts(RoiBPath);
if AExtension==".zip"
	RoiSetA=ZipArchive(OpenRead(RoiAPath)).Entries;
	CountA=RoiSetA.Count;
	ANames=strings(CountA,1);
	for a=1:CountA
		ANames(a)=RoiSetA.Item(a-1).Name;
	end
	[~,ANames]=fileparts(ANames);
	if BExtension==".zip"
		RoiSetB=ZipArchive(OpenRead(RoiBPath)).Entries;
		CountB=RoiSetB.Count;
		BNames=strings(CountB,1);
		for b=1:CountB
			BNames(b)=RoiSetB.Item(b-1).Name;
		end
		[~,BNames]=fileparts(BNames);
	end
	[~,DiffIndices]=setdiff(ANames,BNames);
	DiffIndices=DiffIndices-1;
	NoDI=numel(DiffIndices);
	if NoDI==0
		RoiCPath="";
	elseif NoDI==1
		Entry=RoiSetA.Item(DiffIndices);
		RoiCPath=fullfile(Directory,Entry.Name);
		Entry.Open().CopyTo(OpenWrite(RoiCPath));
	else
		ArchiveC=ZipArchive(OpenWrite(fullfile(Directory,CName+Extension)),ZipArchiveMode.Create);
		for c=1:NoDI
			Entry=RoiSetA.Item(DiffIndices(c));
			NewEntry=ArchiveC.CreateEntry(Entry.Name).Open;
			Entry.Open().CopyTo(NewEntry);
			NewEntry.Close;
		end
		ArchiveC.Dispose;
	end
else
	ANames=ANames+AExtension;
	if BExtension==".zip"
		RoiSetB=ZipArchive(OpenRead(RoiBPath)).Entries;
		CountB=RoiSetB.Count;
		for b=1:CountB
			if RoiSetB.Item(b-1).Name==ANames
				RoiCPath="";
				return;
			end
		end
		copyfile(RoiAPath,Directory);
	end
end
end

%[appendix]{"version":"1.0"}
%---
