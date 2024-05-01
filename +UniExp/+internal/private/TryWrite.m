function Writer = TryWrite(Writer,WriterGetFun,Data,varargin)
Wait=0x001;
TryCount=0x1;
while true
	try
		Writer.ReadPixels(Data,varargin{:});
		break;
	catch ME
		if strcmp(ME.identifier,'Image5D:Exceptions:Memory_copy_failed')
			warning('文件写出失败，可能是持有文件的设备断开了连接，请检查设备。将在%u秒后重试。',Wait);
			pause(Wait);
			Wait=bitshift(Wait,1);
			TryCount=TryCount+1;
			warning('第%u次尝试：',TryCount);
			delete(Writer);
			while true
				try
					Writer=WriterGetFun();
					break;
				catch ME
					if strcmp(ME.identifier,'Image5D:Exceptions:Memory_copy_failed')
						warning('文件打开失败，可能是持有文件的设备断开了连接，请检查设备。将在%u秒后重试。',Wait);
						pause(Wait);
						Wait=bitshift(Wait,1);
						TryCount=TryCount+1;
						warning('第%u次尝试：',TryCount);
					else
						rethrow(ME);
					end
				end
			end
		else
			rethrow(ME);
		end
	end
end