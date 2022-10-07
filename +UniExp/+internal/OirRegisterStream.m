classdef OirRegisterStream<ParallelComputing.BlockRWStream
	properties
		Sum=0
		SquareSum=0
		SizeT=0
		ClearGpuForEachObject=false
	end
	methods(Access=private)
		function obj = OirRegisterStream(RWObjects,GetRWer)
			obj@ParallelComputing.BlockRWStream(RWObjects,GetRWer);
		end
	end
	methods(Access=protected)
		function NextObject(obj)
			Index=obj.ObjectsRead+1;
			if Index<=obj.NumObjects
				fprintf('%s 文件%u/%u：%s\n',datetime,Index,obj.NumObjects,obj.RWObjects(Index).OirPaths);
				if obj.ClearGpuForEachObject
					gpuDevice().reset;
				end
				obj.NextObject@ParallelComputing.BlockRWStream;
			end
		end
		function Tags=WriteReturn(obj,Data,StartPiece,EndPiece,Writer)
			[Data,Tags,RSum,RSquareSum,RSizeT]=Data{:};
			Writer.Write(Data,StartPiece,EndPiece);
			obj.Sum=obj.Sum+RSum;
			obj.SquareSum=obj.SquareSum+RSquareSum;
			obj.SizeT=obj.SizeT+RSizeT;
		end
	end
	methods(Static)
		function obj=New(OirPaths,TiffPaths,MovingChannel,ClearGpu,FIOrTM,MemoryOrSampleSize)
			if isnumeric(FIOrTM)
				RWObjects=table2struct(table(OirPaths,TiffPaths));
				GetRWer=@(RWArgs)UniExp.internal.OirRegisterRW(RWArgs.OirPaths,RWArgs.TiffPaths,MovingChannel,ClearGpu,FIOrTM,MemoryOrSampleSize);
			else
				RWObjects=table2struct(table(OirPaths,TiffPaths,FIOrTM));
				GetRWer=@(RWArgs)UniExp.internal.OirRegisterRW(RWArgs.OirPaths,RWArgs.TiffPaths,MovingChannel,ClearGpu,RWArgs.FIOrTM,MemoryOrSampleSize);
			end
			obj=UniExp.internal.OirRegisterStream(RWObjects,GetRWer);
		end
	end
end