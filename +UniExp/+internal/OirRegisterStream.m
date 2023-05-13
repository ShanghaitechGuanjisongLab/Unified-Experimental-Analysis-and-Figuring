classdef OirRegisterStream<UniExp.internal.VerboseStream
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
	methods
		function obj = OirRegisterStream(OirPath,Translation,OutputDirectory,varargin)
			obj@UniExp.internal.VerboseStream(table2struct(table(OirPath,Translation)),@(S)UniExp.internal.OirRegisterRW2(S.OirPath,S.Translation,OutputDirectory,varargin{:}));
		end
	end
end