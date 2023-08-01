classdef BlockVideoReader<ParallelComputing.IBlockRWer&VideoReader
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		CollectData
		ProcessData={}
	end
	properties(SetAccess=immutable,GetAccess=protected)
		GpuLimit
	end
	methods
		function obj = BlockVideoReader(VideoPath)
			obj@VideoReader(VideoPath);
			Sample=obj.readFrame;
			obj.PieceSize=numel(typecast(Sample(:),'uint8'));
			obj.NumPieces=obj.NumFrames;
			obj.GpuLimit=floor(double(intmax('int32'))/numel(Sample))-1;
		end
		function [Data,PiecesRead]=Read(obj,Start,End,~)
			if nargin>3
				End=min(End,Start+obj.GpuLimit);
			end
			Data=obj.read([Start,End]);
			PiecesRead=size(Data,4);
		end
	end
end