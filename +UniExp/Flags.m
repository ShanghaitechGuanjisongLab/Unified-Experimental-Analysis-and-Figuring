classdef Flags
	%为UniExp中的多个函数提供功能选项旗帜。
	enumeration
		%无特殊操作
		No_special_operation

		%% BarScatterCompare选项
		%连接散点
		Connect_scatters

		%% BlockVideoMeasure测量算法
		%平均像素值
		Average_pixel_value
		%高于平均的像素数占比
		Bright_area_ratio

		%% TrialSignal2Behavior命中判断算法
		%响应均值大于基线最大值
		Average_greater_than_max
		%响应值t检验显著大于基线
		T_test_significant

		%% LinearPca归一化
		%将基线均值记为F0，计算F/F0-1为归一化数据
		dFdF0
		%将基线均值记为F0，计算log2(F/F0)为归一化数据
		log2FdF0
		%将基线均值记为μ，标准差记为σ，计算(F-μ)/σ为归一化数据
		ZScore
	end
end