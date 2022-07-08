classdef UniExpException
	enumeration
		Wrong_number_of_arguments
		Image_size_does_not_match
	end
	methods
		function Throw(obj)
			error(sprintf('UniExp:%s',obj),string(obj));
		end
	end
end