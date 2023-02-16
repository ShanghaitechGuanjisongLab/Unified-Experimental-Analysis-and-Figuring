classdef VerboseStream<ParallelComputing.BlockRWStream
	methods
		function LocalWriteBlock(obj,Data,BlockIndex)
			ObjectIndex=obj.BlockTable.ObjectIndex(BlockIndex);
			fprintf('%s 文件%u/%u 帧%u/%u\n',datetime,ObjectIndex,obj.NumObjects,obj.BlockTable.EndPiece(BlockIndex),obj.ObjectTable.RWer{ObjectIndex}.NumPieces);
			obj.LocalWriteBlock@ParallelComputing.BlockRWStream(Data,BlockIndex);
		end
	end
	methods
		function obj = VerboseStream(varargin)
			obj@ParallelComputing.BlockRWStream(varargin{:});
		end
	end
end