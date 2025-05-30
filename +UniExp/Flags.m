classdef Flags
	%为UniExp中的多个函数提供功能选项旗帜。
	enumeration
		%% 仅限内部使用

		Real
		Table
		Tabular
		Cell
		Struct
		Repeating
		HitMiss_Unified
		HitMiss_ByDesign
		HitMiss_ByStimulus

		%% 无特殊操作
		No_special_operation

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

		%% 基线归一化

		%将基线均值记为F0，计算F/F0-1为归一化数据
		dFdF0
		%将基线均值记为F0，计算log2(F/F0)为归一化数据
		log2FdF0
		%将基线均值记为μ，标准差记为σ，计算(F-μ)/σ为归一化数据
		ZScore
		%仅仅减去基线
		DeltaF

		%% 累积算法

		%
		Mean
		%中位数
		Median
		%最小值
		Min
		%最大值
		Max
		%极差
		Range
		%标准差
		Std
		%峰值时点
		PeakTime
		%绝对最大值
		AbsMax
		%变异系数
		VariationCoefficient

		%% LanearHeatmap

		HideXAxis
		HideYAxis
		ScaleColor
		SymmetricColormap

		%% BatchOirRegisterTiff.Parallel

		%使用MATLAB当前并行池设置
		AsDefault
		%按照UseGpu个数设置并行池尺寸。如果GPU个数<2，不使用并行池
		AsGPU
		%顺序执行，不使用并行池
		Sequential

		%% BatchOirRegisterTiff.LogLevel

		%每个分块都输出一条日志信息
		EachBlock
		%输出频率线性衰减
		LinearReduce
		%每个文件输出一条日志信息
		EachFile
		%不输出任何日志信息
		NoLogs

		%% DataSet.AddBehavior.EventLogCheckLevel

		%抛出异常，终止程序
		Throw
		%发出警告，继续程序
		Warn
		%忽略问题，继续程序
		Ignore

		%% DataSet.struct

		AllProperties

		%% CellTrialVideo.ShowSeconds.Location

		NorthWest
		NorthEast
		SouthWest
		SouthEast

		%% BrainAP.ZeroPoint

		Bregma
		Interaural

		%% HeatmapSort

		Sum
	end
end