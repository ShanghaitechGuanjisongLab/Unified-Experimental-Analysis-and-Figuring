classdef TiffTransformer<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize double
		NumPieces double
		ProcessData
	end
	properties(SetAccess=protected)
		CollectData
	end
	properties
		Reader Image5D.OmeTiffRWer
		Writer Image5D.OmeTiffRWer
	end
	properties(SetAccess=immutable,GetAccess=protected)
		GpuLimit
	end
	methods
		function obj=TiffTransformer(TiffPath,TransMatrix,OutputDirectory)
			import Image5D.*
			[~,Filename]=fileparts(TiffPath);
			if exist('OutputDirectory','var')
				obj.Reader=OmeTiffRWer.OpenRead(TiffPath);
				obj.Writer=OmeTiffRWer.Create(fullfile(OutputDirectory,Filename+".变换.tif"),obj.Reader.ImageDescription);
			else
				obj.Reader=OmeTiffRWer.OpenRW(TiffPath);
				obj.Writer=obj.Reader;
			end
			if obj.Reader.SizeZ~=numel(TransMatrix)
				UniExp.Exceptions.ZLayers_of_the_moving_ROI_and_file_do_not_match.Throw(Filename);
			end
			PieceElements=prod([uint32(obj.Reader.SizeX),obj.Reader.SizeY,obj.Reader.SizeC,obj.Reader.SizeZ]);
			obj.PieceSize=PieceElements*uint32(obj.Reader.SizeP);
			obj.NumPieces=obj.Reader.SizeT;
			obj.ProcessData=TransMatrix;
			obj.CollectData=obj.NumPieces;
			obj.GpuLimit=floor(double(intmax('int32'))/double(PieceElements));
		end
		function [Data,PiecesRead]=Read(obj,Start,End,~)
			if nargin>3
				End=min(End,Start+obj.GpuLimit);
			end
			Data=obj.Reader.ReadPixels(Start-1,End-Start+1);
			PiecesRead=size(Data,5);
		end
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data{1},Start-1,End-Start+1);
			Data(1)=[];
		end
	end
end