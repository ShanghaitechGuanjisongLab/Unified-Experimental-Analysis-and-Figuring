classdef OirRegisterRW2<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		CollectData
		ProcessData={}
	end
	properties(SetAccess=immutable,GetAccess=protected)
		Writer Image5D.OmeTiffRWer
		OirPath
		Translation
		Transform
		DisplacementField
		NontagChannels
		CacheFid
		SizeX
		SizeY
		SizeC
		SizeZ
		MeanWriter Image5D.OmeTiffRWer
		GpuLimit
	end
	properties(Access=protected)
		Reader Image5D.OirReader
	end
	methods
		function obj = OirRegisterRW2(FileArguments,OutputDirectory,CacheDirectory)
			import Image5D.*
			obj.OirPath=FileArguments.OirPath;
			obj.Reader=OirReader(obj.OirPath);
			DeviceColors=obj.Reader.DeviceColors;
			obj.SizeX=obj.Reader.SizeX;
			obj.SizeY=obj.Reader.SizeY;
			obj.SizeC=obj.Reader.SizeC;
			obj.SizeZ=obj.Reader.SizeZ;
			obj.NumPieces=obj.Reader.SizeT;
			PieceElements=prod([uint32(obj.SizeX),obj.SizeY,obj.SizeC,obj.SizeZ]);
			obj.PieceSize=2*PieceElements;
			obj.NontagChannels=find(~startsWith(DeviceColors.Device,'CD'));
			[~,Filename]=fileparts(OirPath);
			Colors=ChannelColor.FromOirColors(DeviceColors.Color(obj.NontagChannels,:));
			obj.Writer=OmeTiffRWer.Create(fullfile(OutputDirectory.Value,Filename+".tif"),PixelType.UINT16,obj.SizeX,obj.SizeY,Colors,obj.SizeZ,obj.NumPieces,DimensionOrder.XYCZT);
			obj.NontagChannels=obj.NontagChannels-1;
			obj.Translation=FileArguments.Translation;
			obj.Transform=FileArguments.Transform;
			obj.DisplacementField=FileArguments.DisplacementField;
			if exist('CacheDirectory','var')
				[~,Filename]=fileparts(OirPath);
				obj.CacheFid=fopen(fullfile(CacheDirectory,Filename+".缓存"));
				obj.SizeC=numel(obj.NontagChannels);
			else
				obj.CacheFid=0;
			end
			obj.GpuLimit=floor(double(intmax('int32'))/double(PieceElements))-1;
			obj.CollectData=struct(Sum=0,SquareSum=0,SizeT=repmat(obj.NumPieces,1,1,1,obj.SizeZ));
		end
		function [Data,PiecesRead]=Read(obj,Start,End,~)
			if nargin>3
				End=min(End,Start+obj.GpuLimit);
			end
			if obj.CacheFid
				Sizes=[obj.SizeX,obj.SizeY,obj.SizeC,obj.SizeZ,End-Start+1];
				Data=reshape(fread(obj.CacheFid,prod(Sizes),'uint16=>uint16'),Sizes);
			else
				[Data,obj.Reader]=TryRead(obj.Reader,obj.OirPath,Start-1,End-Start+1,obj.NontagChannels);
			end
			PiecesRead=size(Data,5);
			Data={Data,obj.Translation(Start:End,:,:),obj.Transform,obj.DisplacementField};
		end
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data{1},Start-1,End-Start+1);
			obj.CollectData.Sum=obj.CollectData.Sum+Data{2};
			obj.CollectData.SquareSum=obj.CollectData.SquareSum+Data{3};
			Data={};
		end
		function delete(obj)
			if obj.CacheFid
				fclose(obj.CacheFid);
			end
		end
	end
end