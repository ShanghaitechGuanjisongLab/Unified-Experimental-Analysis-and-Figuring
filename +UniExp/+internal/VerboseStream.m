classdef VerboseStream<ParallelComputing.BlockRWStream
	properties
		LogLevel
	end
	properties(Access=private)
		LastObject=0
		NumLogs
	end
	methods
		function LocalWriteBlock(obj,Data,BlockIndex)
			ObjectIndex=obj.BlockTable.ObjectIndex(BlockIndex);
			EndPiece=obj.BlockTable.EndPiece(BlockIndex);
			NumPieces=obj.ObjectTable.RWer{ObjectIndex}.NumPieces;
			import UniExp.Flags
			switch(obj.LogLevel)
				case Flags.EachBlock
					fprintf('%s 文件%u/%u 帧%u/%u\n',datetime,ObjectIndex,obj.NumObjects,EndPiece,NumPieces);
				case Flags.LinearReduce
					%sqrt不接受整数，必须先转double；整数不能和single一起使用，因此也只能转double
					if ObjectIndex>obj.LastObject
						fprintf('%s 文件%u/%u 帧%u/%u\n',datetime,ObjectIndex,obj.NumObjects,EndPiece,NumPieces);
						obj.LastObject=ObjectIndex;
						obj.NumLogs=1;
					elseif ObjectIndex==obj.LastObject
						NewNL=obj.NumLogs+1;
						if randi(NewNL)==1
							fprintf('%s 文件%u/%u 帧%u/%u\n',datetime,ObjectIndex,obj.NumObjects,EndPiece,NumPieces);
							obj.NumLogs=NewNL;
						end
					end
				case Flags.EachFile
					if ObjectIndex>obj.LastObject
						fprintf('%s 文件%u/%u',datetime,ObjectIndex,obj.NumObjects);
						obj.LastObject=ObjectIndex;
					end
				case {Flags.No_special_operation,Flags.NoLogs}
				otherwise
					UniExp.Exceptions.Unexpected_LogLevel.Throw(obj.LogLevel);

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