function [Cx,Cy,Rx,Ry] = ImageJRoiReadout(RoiSetPath)
[~,~,Extension]=fileparts(RoiSetPath);
if Extension==".zip"
	NET.addAssembly("System.IO.Compression");
	Stream=System.IO.File.OpenRead(RoiSetPath);
	RoiSet=System.IO.Compression.ZipArchive(Stream).Entries;
	NoRois=RoiSet.Count;
	Positions=zeros(NoRois,4,"uint16");
	Buffer=NET.createArray("System.Byte",16);
	for a=1:NoRois
		RoiSet.Item(a-1).Open().Read(Buffer,0,16);
		if Buffer(7)~=2
			warning("ROI不是圆形。将当作圆形处理。");
		end
		Position=uint8(Buffer);
		Positions(a,:)=typecast(Position(9:end),"uint16");
	end
	Stream.Close;
	Positions=double(swapbytes(Positions));
else
	Fid=fopen(RoiSetPath,"r","b");
	fseek(Fid,6,"bof");
	if fread(Fid,1,"uint8=>uint8")~=2
		warning("ROI不是圆形。将当作圆形处理。");
	end
	fseek(Fid,1,"cof");
	Positions=fread(Fid,[1 4],"uint16=>double");
end
Tops=Positions(:,1);
Lefts=Positions(:,2);
Bottoms=Positions(:,3);
Rights=Positions(:,4);
Cx=(Lefts+Rights+1)/2;
Cy=(Tops+Bottoms+1)/2;
Rx=(Rights-Lefts)/2;
Ry=(Bottoms-Tops)/2;