classdef UniExpException
	enumeration
		Wrong_number_of_arguments
	end
	methods
		function Throw(obj)
			error(sprintf('UniExp:%s',obj),string(obj));
		end
	end
end