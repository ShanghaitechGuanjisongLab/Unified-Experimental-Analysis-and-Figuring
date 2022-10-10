classdef BlockVideoReader<ParallelComputing.IBlockRWer&VideoReader
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		CollectData
		ProcessData={}
	end
	methods
		function obj = BlockVideoReader(VideoPath)
			obj@VideoReader(VideoPath);
			Sample=obj.readFrame;
			obj.PieceSize=numel(typecast(Sample(:),'uint8'));
			obj.NumPieces=obj.NumFrames;
		end
		function Data = Read(obj,Start,End)
			Data=obj.read([Start,End]);
		end
	end
end