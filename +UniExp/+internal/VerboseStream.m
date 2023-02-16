classdef VerboseStream<ParallelComputing.BlockRWStream
	methods(Access=protected)
		function NextObject(obj)
			Index=obj.ObjectsRead+1;
			if Index<=obj.NumObjects
				obj.PiecesRead=0;
				RWer=obj.GetRWer(obj.RWObjects(Index));
				obj.ObjectTable(Index,1:2)={{RWer.CollectData},{RWer}};
				fprintf('%s 文件%u/%u：%s\n',datetime,Index,obj.NumObjects,obj.RWObjects(Index).OirPaths);
			end
		end
	end
	methods
		function LocalWriteBlock(obj,Data,BlockIndex)
			obj.LocalWriteBlock@ParallelComputing.BlockRWStream(Data,BlockIndex);
			ObjectIndex=obj.BlockTable.ObjectIndex(BlockIndex);
			fprintf('%s 文件%u/%u 帧%u/%u\n',datetime,ObjectIndex,obj.NumObjects,obj.BlockTable.EndPiece(BlockIndex),obj.ObjectTable.RWer{ObjectIndex}.NumPieces);
		end
	end
	methods
		function obj = VerboseStream(varargin)
			obj@ParallelComputing.BlockRWStream(varargin{:});
		end
	end
end