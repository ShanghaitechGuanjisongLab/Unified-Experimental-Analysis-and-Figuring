classdef TiffTransformer<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize double
		NumPieces double
		ProcessData
	end
	properties(SetAccess=protected)
		CollectData
	end
	properties(Access=protected)
		Reader
		Writer
	end
	properties(SetAccess=immutable,GetAccess=protected)
		ReaderGetFun
		GpuLimit
		WriterIsReader
	end
	methods
		function obj=TiffTransformer(TiffPath,TransMatrix,OutputDirectory)
			import Image5D.*
			[FirstDirectory,Filename,Extension]=fileparts(TiffPath);
			switch Extension
				case ".tif"
					if exist('OutputDirectory','var')
						obj.ReaderGetFun=@()OmeTiffRWer.OpenRead(TiffPath);
						obj.Reader=obj.ReaderGetFun();
						obj.Writer=OmeTiffRWer.Create(fullfile(OutputDirectory,Filename+".变换.tif"),obj.Reader.ImageDescription);
						obj.WriterIsReader=false;
					else
						obj.ReaderGetFun=@()OmeTiffRWer.OpenRW(TiffPath);
						obj.Reader=obj.ReaderGetFun();
						obj.Writer=obj.Reader;
						obj.WriterIsReader=true;
					end
					PieceElements=prod([uint32(obj.Reader.SizeX),obj.Reader.SizeY,obj.Reader.SizeC,obj.Reader.SizeZ]);
					obj.PieceSize=PieceElements*uint32(obj.Reader.SizeP);
				case ".oir"
					if ~exist('OutputDirectory','var')
						OutputDirectory=FirstDirectory;
					end
					obj.ReaderGetFun=@()OirReader(TiffPath);
					obj.Reader=obj.ReaderGetFun();
					obj.Writer=OmeTiffRWer.Create(fullfile(OutputDirectory,Filename+".变换.tif"),PixelType.UINT16,obj.Reader.SizeX,obj.Reader.SizeY,ChannelColor.FromOirColors(obj.Reader.DeviceColors.Color),obj.Reader.SizeZ,obj.Reader.SizeT,DimensionOrder.XYCZT);
					obj.WriterIsReader=false;
					PieceElements=prod([uint32(obj.Reader.SizeX),obj.Reader.SizeY,obj.Reader.SizeC,obj.Reader.SizeZ]);
					obj.PieceSize=PieceElements*2;
				otherwise
					UniExp.Exceptions.Unexpected_file_extension.Throw(TiffPath);
			end
			if obj.Reader.SizeZ~=numel(TransMatrix)
				UniExp.Exceptions.ZLayers_of_the_moving_ROI_and_file_do_not_match.Throw(Filename);
			end
			obj.NumPieces=obj.Reader.SizeT;
			obj.ProcessData=TransMatrix;
			obj.CollectData=obj.NumPieces;
			obj.GpuLimit=floor(double(intmax('int32'))/double(PieceElements));
		end
		function [Data,PiecesRead]=Read(obj,Start,End,~)
			if nargin>3
				End=min(End,Start+obj.GpuLimit);
			end
			[Data,obj.Reader]=TryRead(obj.Reader,obj.ReaderGetFun,Start-1,End-Start+1);
			if obj.WriterIsReader
				obj.Writer=obj.Reader;
			end
			PiecesRead=size(Data,5);
		end
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data{1},Start-1,End-Start+1);
			Data(1)=[];
		end
	end
end