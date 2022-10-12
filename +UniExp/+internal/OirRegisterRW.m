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
		NontagChannels
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
			obj.NontagChannels=find(~startsWith(Device,'CD'));
			obj.Writer=OmeTiffRWer.Create(TiffPath,PixelType.UINT16,SizeX,SizeY,ChannelColor.FromOirColors(Colors(:,obj.NontagChannels)),SizeZ,obj.NumPieces,DimensionOrder.XYCZT);
			obj.NontagChannels=obj.NontagChannels-1;
			obj.Translation=Translation;
			obj.ProcessData=Transform;
		end
		function Data=Read(obj,Start,End)
			[Data,obj.Reader]=TryRead(obj.Reader,obj.OirPath,Start-1,End-Start+1,obj.NontagChannels);
			Data={Data,obj.Translation(Start:End,:,:)};
		end
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data{1},Start-1,End-Start+1);
			Data(1)=[];
		end
	end
end