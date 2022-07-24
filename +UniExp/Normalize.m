classdef Normalize
	%服务于LinearPca的归一化算法枚举类，列出可选的归一化算法。
	%归一化发生在任何对原始数据进行的运算之前。
	enumeration
		%不做归一化
		NoNormalize

		%将基线均值记为F0，计算F/F0-1为归一化数据
		dFdF0

		%将基线均值记为F0，计算log(F/F0)为归一化数据
		lnFdF0

		%将基线均值记为μ，标准差记为σ，计算(F-μ)/σ为归一化数据
		ZScore
	end
end