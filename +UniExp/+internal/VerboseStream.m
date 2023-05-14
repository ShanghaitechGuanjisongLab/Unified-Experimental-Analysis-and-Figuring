classdef VerboseStream<ParallelComputing.BlockRWStream
	properties
		LogLevel
	end
	properties(Access=private)
		LastObject=0
		LastPiece=0
	end
	methods
		function LocalWriteBlock(obj,Data,BlockIndex)
			ObjectIndex=obj.BlockTable.ObjectIndex(BlockIndex);
			EndPiece=obj.BlockTable.EndPiece(BlockIndex);
			NumPieces=obj.ObjectTable.RWer{ObjectIndex}.NumPieces;
			switch(obj.LogLevel)
				case UniExp.Flags.EachBlock
					fprintf('%s 文件%u/%u 帧%u/%u\n',datetime,ObjectIndex,obj.NumObjects,EndPiece,NumPieces);
				case UniExp.Flags.LinearReduce
					if ObjectIndex>obj.LastObject||ObjectIndex==obj.LastObject&&EndPiece>obj.LastPiece+sqrt(single(min(EndPiece,NumPieces-EndPiece)))
						fprintf('%s 文件%u/%u 帧%u/%u\n',datetime,ObjectIndex,obj.NumObjects,EndPiece,NumPieces);
						obj.LastObject=ObjectIndex;
						obj.LastPiece=EndPiece;
					end
				case UniExp.Flags.EachFile
					if ObjectIndex>obj.LastObject
						fprintf('%s 文件%u/%u',datetime,ObjectIndex,obj.NumObjects);
						obj.LastObject=ObjectIndex;
					end
			end
			obj.LocalWriteBlock@ParallelComputing.BlockRWStream(Data,BlockIndex);
		end
	end
	methods
		function obj = VerboseStream(LogLevel,varargin)
			obj@ParallelComputing.BlockRWStream(varargin{:});
			obj.LogLevel=LogLevel;
		end
	end
end