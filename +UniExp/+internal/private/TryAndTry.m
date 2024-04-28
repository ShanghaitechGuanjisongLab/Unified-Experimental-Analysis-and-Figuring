function varargout = TryAndTry(Function,RetryIf)
Wait=0x001;
TryCount=0x1;
while true
	try
		[varargout{1:nargout}]=Function();
		break;
	catch ME
		if strcmp(ME.identifier,RetryIf)
			warning(RetryIf,'%s',ME.message);
			pause(Wait);
			Wait=bitshift(Wait,1);
			TryCount=TryCount+1;
			warning('第%u次尝试：',TryCount);
		else
			rethrow(ME);
		end
	end
end