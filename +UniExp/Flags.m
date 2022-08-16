classdef Flags<uint8
	%为UniExp中的多个函数提供标志位
	enumeration
		%在BarScatterCompare中对应的采样点连接起来
		ScatterLink(0b1)
	end
end