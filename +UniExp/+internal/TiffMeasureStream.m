classdef TiffMeasureStream<ParallelComputing.BlockRWStream
	methods(Access=protected)
		function NextObject(obj)
			Index=obj.ObjectsRead+1;
			if Index<=obj.NumObjects
				fprintf('文件%u/%u：%s\n',Index,obj.NumObjects,obj.RWObjects(Index));
				obj.NextObject@ParallelComputing.BlockRWStream;
			end
		end
	end
	methods
		function obj = TiffMeasureStream(TiffPaths)
			obj@ParallelComputing.BlockRWStream(TiffPaths,UniExp.internal.TiffMeasureReader);
		end
	end
end