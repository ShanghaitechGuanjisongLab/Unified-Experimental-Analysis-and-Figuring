function [Data,Reader] = TryRead(Reader,OirPath,Start,Size,varargin)
Wait=0x001;
TryCount=0x1;
while true
	try
		Data=Reader.ReadPixels(Start,Size,varargin{:});
		break;
	catch ME
		if ME.identifier=="Image5D:Image5DException:Memory_copy_failed"
			warning('文件读入失败，可能是持有文件的设备断开了连接，请检查设备。将在%u秒后重试。',Wait);
			pause(Wait);
			Wait=bitshift(Wait,1);
			TryCount=TryCount+1;
			warning('第%u次尝试读入：',TryCount);
			delete(Reader);
			Reader=Image5D.OirReader(OirPath);
		else
			rethrow(ME);
		end
	end
end