classdef OirRegisterRW<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		CollectData
		ProcessData
	end
	properties(SetAccess=immutable,GetAccess=private)
		Writer Image5D.OmeTiffRWer
		OirPath
		Translation
	end
	properties(Access=private)
		Reader Image5D.OirReader
	end
	methods
		function obj = OirRegisterRW(OirPath,TiffPath,Translation,Transform)
			import Image5D.*
			obj.OirPath=OirPath;
			obj.Reader=OirReader(OirPath);
			[Device,Colors]=obj.Reader.DeviceColors;
			SizeX=obj.Reader.SizeX;
			SizeY=obj.Reader.SizeY;
			SizeC=obj.Reader.SizeC;
			SizeZ=obj.Reader.SizeZ;
			obj.NumPieces=obj.Reader.SizeT;
			obj.PieceSize=2*prod([uint32(SizeX),SizeY,SizeC,SizeZ]);
			obj.Writer=OmeTiffRWer.Create(TiffPath,PixelType.UINT16,obj.Reader.SizeX,obj.Reader.SizeY,ChannelColor.FromOirColors(Colors(:,~startsWith(Device,'CD'))),obj.Reader.SizeZ,obj.Reader.SizeT,DimensionOrder.XYCZT);
			obj.Translation=Translation;
			obj.ProcessData=Transform;
		end
		function Data=Read(obj,Start,End)
			[Data,obj.Reader]=TryRead(obj.Reader,Start-1,End-Start+1,obj.OirPath);
			Data={Data,obj.Translation(Start:End,:)};
		end
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data{1},Start-1,End-Start+1);
			Data(1)=[];
		end
	end
end