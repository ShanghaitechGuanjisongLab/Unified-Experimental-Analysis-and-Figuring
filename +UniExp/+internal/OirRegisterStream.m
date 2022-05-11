classdef OirRegisterStream<ParallelComputing.BlockRWStream
	methods(Access=protected)
		function NextObject(obj)
			Index=obj.ObjectsRead+1;
			if Index<=obj.NumObjects
				fprintf('文件%u/%u：%s\n',Index,obj.NumObjects,obj.RWObjects{Index}(1));
				obj.NextObject@ParallelComputing.BlockRWStream;
			end
		end
	end
	methods
		function obj = OirRegisterStream(OirPaths,TiffPaths,FixedImage,Memory)
			obj@ParallelComputing.BlockRWStream(num2cell([OirPaths,TiffPaths],2),@(RWPath)UniExp.internal.OirRegisterRW(RWPath{1}(1),RWPath{1}(2),FixedImage,Memory))
		end
	end
end