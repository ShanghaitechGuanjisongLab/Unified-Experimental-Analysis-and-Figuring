classdef OirRegisterStream2<ParallelComputing.BlockRWStream
	methods(Access=protected)
		function NextObject(obj)
			Index=obj.ObjectsRead+1;
			if Index<=obj.NumObjects
				fprintf('%s 文件%u/%u：%s\n',datetime,Index,obj.NumObjects,obj.RWObjects(Index).OirPaths);
				while true
					try
						obj.NextObject@ParallelComputing.BlockRWStream;
						break
					catch ME
						if ME.identifier=="Image5D:Image5DException:Tiff_file_creation_failed")&&ME.Detail==MATLAB.WindowsErrorCode.ERROR_DISK_FULL
							NewOutput=input('输出目录磁盘已满。直接回车以选择新的输出目录，或输入c以取消本次任务。',"s");
							if NewOutput=="c"
								ME.rethrow;
							end
							NewOutput=uigetdir;
							while isequal(NewOutput,0)
								NewOutput=input('未选择新目录。直接回车以选择新的输出目录，或输入c以取消本次任务。',"s");
								if NewOutput=="c"
									ME.rethrow;
								end
								NewOutput=uigetdir;
							end
							for I=Index:obj.NumObjects
								[~,Filename]=fileparts(obj.RWObjects(I).TiffPaths);
								obj.RWObjects(I).TiffPaths=fullfile(NewOutput,Filename+".tif");
							end
						else
							ME.rethrow;
						end
					end
				end
			end
		end
	end
	methods
		function LocalWriteBlock(obj,Data,BlockIndex)
			%在单线程环境下，写出一个数据块。
			%此方法只能在构造该对象的进程上调用，多线程环境下则会发生争用，因此通常用于单线程环境，退化为读入-计算-写出的简单流程。
			%# 语法
			% obj.LocalWriteBlock(Data,BlockIndex)
			%# 输入参数
			% Data，数据块处理后的计算结果。可以用元胞数组包含多个复杂的结果。此参数将被直接交给读写器的Write方法。
			% BlockIndex，数据块的唯一标识符，从LocalReadBlock获取，以确保读入数据块和返回计算结果一一对应。
			%See also ParallelComputing.BlockRWStream.LocalReadBlock
			ObjectIndex=obj.BlockTable.ObjectIndex(BlockIndex);
			Writer=obj.ObjectTable.RWer{ObjectIndex};
			EndPiece=obj.BlockTable.EndPiece(BlockIndex);
			obj.BlockTable.ReturnData{BlockIndex}=obj.WriteReturn(Data,obj.BlockTable.StartPiece(BlockIndex),EndPiece,Writer);
			fprintf('%s 文件%u/%u 帧%u/%u\n',datetime,ObjectIndex,obj.NumObjects,EndPiece,Writer.NumPieces);
			BlocksWritten=obj.ObjectTable.BlocksWritten(ObjectIndex)+1;
			if BlocksWritten==obj.ObjectTable.BlocksRead(ObjectIndex)&&obj.ObjectsRead>=ObjectIndex
				delete(Writer);
			end
			obj.ObjectTable.BlocksWritten(ObjectIndex)=BlocksWritten;
		end
	end
	methods
		function obj = OirRegisterStream2(Paths,GetRWer)
			obj@ParallelComputing.BlockRWStream(Paths,GetRWer);
		end
	end
end