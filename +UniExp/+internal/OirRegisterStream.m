classdef OirRegisterStream<UniExp.internal.VerboseStream
	properties(Access=protected)
		OutputDirectory
	end
	methods(Access=protected)
		function NextObject(obj)
			while true
				try
					obj.NextObject@UniExp.internal.VerboseStream
					break
				catch ME
					if ME.identifier=="Image5D:Image5DException:Tiff_file_creation_failed"&&ME.Detail==MATLAB.Lang.WindowsErrorCode.ERROR_DISK_FULL
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
						obj.OutputDirectory.Value=NewOutput;
					else
						ME.rethrow;
					end
				end
			end
		end
	end
	methods
		function obj = OirRegisterStream(LogLevel,OirPath,Translation,OutputDirectory,varargin)
			Arguments=table(OirPath,Translation);
			OutputDirectory=MATLAB.Lang.Optional(OutputDirectory);
			Arguments.OutputDirectory(:)=OutputDirectory;
			obj@UniExp.internal.VerboseStream(LogLevel,table2struct(Arguments),@(S)UniExp.internal.OirRegisterRW2(S.OirPath,S.Translation,S.OutputDirectory,varargin{:}));
			obj.OutputDirectory=OutputDirectory;
		end
	end
end