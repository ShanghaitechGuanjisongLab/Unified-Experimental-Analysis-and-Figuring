classdef OirRegisterReader<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		CollectData
		ProcessData
	end
	properties(SetAccess=immutable,GetAccess=private)
		OirPath
		BlockStarts
		BlockSizes uint16
	end
	properties(Access=private)
		Reader Image5D.OirReader
		BlocksRead=0
	end
	methods
		function obj = OirRegisterReader(OirPath,BlockSize)
			obj.OirPath=OirPath;
			obj.Reader=Image5D.OirReader(OirPath);
			[Devices,Colors]=obj.Reader.DeviceColors;
			TagLogical=startsWith(Devices,'CD');
			obj.NumPieces=double(obj.Reader.SizeT);%20
			obj.ProcessData=TagLogical;
			NumBlocks=ceil(obj.NumPieces/BlockSize);
			obj.BlockSizes=linspace(0,obj.NumPieces,NumBlocks+1);
			obj.BlockStarts=obj.BlockSizes(1:end-1);
			obj.BlockSizes=obj.BlockSizes(2:end)-obj.BlockStarts;
			obj.CollectData=struct(ChannelColors=Colors,DeviceNames=Devices,SeriesInterval=obj.Reader.SeriesInterval);
		end
		function Data=Read(obj,~,~)
			obj.BlocksRead=obj.BlocksRead+1;
			[Data,obj.Reader]=TryRead(obj.Reader,obj.OirPath,obj.BlockStarts(obj.BlocksRead),obj.BlockSizes(obj.BlocksRead));
		end
	end
end