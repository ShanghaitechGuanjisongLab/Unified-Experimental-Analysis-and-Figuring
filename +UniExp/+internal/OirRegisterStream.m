classdef OirRegisterStream<ParallelComputing.BlockRWStream
	methods(Access=protected)
		function NextObject(obj)
			Index=obj.ObjectsRead+1;
			if Index<=obj.NumObjects
				fprintf('%s 文件%u/%u：%s\n',datetime,Index,obj.NumObjects,obj.RWObjects(Index).OirPaths);
				obj.NextObject@ParallelComputing.BlockRWStream;
			end
		end
	end
	methods
		function obj = OirRegisterStream(Paths,GetRWer)
			obj@ParallelComputing.BlockRWStream(Paths,GetRWer);
		end
	end
end