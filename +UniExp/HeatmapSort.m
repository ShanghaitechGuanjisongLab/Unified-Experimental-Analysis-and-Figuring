%[text] 在作热图LanearHeatmap之前对细胞进行分群排序。
%[text] 通过排序，可以将在每个组中响应较高或较低的细胞聚集在一起，在热图上形成一致的色块，方便观察。
%[text] # 语法
%[text] ```matlabCodeExample
%[text] GroupNtats=UniExp.HeatmapSort(GroupNtats);
%[text] %使用回合内极差作为排序标准，对每组内细胞进行一致排序
%[text] 
%[text] Array=UniExp.HeatmapSort(Tensor);
%[text] %对任意三维张量进行排序
%[text] 
%[text] ___=UniExp.HeatmapSort(___,SortCriteria);
%[text] %与上述任意语法组合使用，额外指定排序标准
%[text] 
%[text] ___=UniExp.HeatmapSort(___,SortDirection);
%[text] %与上述任意语法组合使用，额外指定排序方向
%[text] 
%[text] ___=UniExp.HeatmapSort(___,SortGroups);
%[text] %与上述任意语法组合使用，额外指定参与排序的分组名称或序号
%[text] ```
%[text] # 输入参数
%[text] GroupNtats table，NTATS分组，每行一个细胞，通常从DataSet.QueryNTATS取得，至少包含以下列：
%[text] - NTATS(:,:,:)MATLAB.DataTypes.NDTable或数值类型，第2维时间，第3维分组。
%[text] - CellUID(:,1)uint16，每个细胞的UID \
%[text] Tensor(:,:,:)，第1维细胞，第2维时间，第3维分组，直接输入原始张量
%[text] SortDirection(1,:)char='descend'，排序方向，可选'ascend'或'descend'，详见sort文档
%[text] SortGroups，参与分群排序的组名或序号。默认所有组都参与分群排序
%[text] ## SortCriteria
%[text] 可以是以下两种类型二选一：
%[text] ### (1,1)UniExp.Flags
%[text] =UniExp.Flags.Sum，指定排序标准（从小到大）。可选以下枚举：
%[text] - Sum，总和
%[text] - Median，中位数
%[text] - Min，最小值
%[text] - Max，最大值
%[text] - Range，极差
%[text] - Std，标准差
%[text] - PeakTime，峰值时点
%[text] - AbsMax，绝对最大值 \
%[text] ### function\_handle
%[text] 指定排序标准计算函数，必须沿第2维对数据张量进行规约
%[text] #### 语法
%[text] ```matlabCodeExample
%[text] function C=SortCriteria(Tensor);
%[text] ```
%[text] #### 输入参数
%[text] Tensor(:,:,:)，即输入HeatmapSort的张量
%[text] #### 返回值
%[text] C(:,1,:)，沿第2维规约后的运算结果
%[text] # 返回值
%[text] GroupNtats table，排序后的输入GroupNtats，排序后细胞（表行）顺序可能发生改变，其它数据不变
%[text] Tensor(:,:,:)，排序后的数组
%[text] **See also** [UniExp.LanearHeatmap](<matlab:doc UniExp.LanearHeatmap>) [UniExp.DataSet.QueryNTATS](<matlab:doc UniExp.DataSet.QueryNTATS>) [UniExp.Flags](<matlab:edit UniExp.Flags>) [MATLAB.DataTypes.NDTable](<matlab:doc MATLAB.DataTypes.NDTable>) [sort](<matlab:doc sort>)
function Data = HeatmapSort(Data,varargin)
import UniExp.Flags
persistent SCDict
if isempty(SCDict)
	SCDict=dictionary( ...
		Flags.Sum,@(A)sum(A,2), ...
		Flags.Median,@(A)median(A,2), ...
		Flags.Min,@(A)min(A,[],2), ...
		Flags.Max,@(A)max(A,[],2), ...
		Flags.Range,@(A)range(A,2), ...
		Flags.Std,@(A)std(A,[],2), ...
		Flags.PeakTime,@MaxIndex,...
		Flags.AbsMax,@(A)max(abs(A),[],2));
end
SortCriteria=Flags.Sum;
SortDirection='descend';
for V=1:numel(varargin)
	Arg=varargin{V};
	if isa(Arg,'UniExp.Flags')
		SortCriteria=SCDict(Arg);
	elseif isa(Arg,'function_handle')
		SortCriteria=Arg;
	elseif isequal('ascend',Arg)||isequal('descend',Arg)
		SortDirection=Arg;
	else
		SortGroups=Arg;
	end
end
TabularData=istabular(Data);
if exist('SortGroups','var')
	if TabularData
		Raw=Data.NTATS{:,:,SortGroups};
	else
		Raw=Data(:,:,SortGroups);
	end
else
	if TabularData
		Raw=Data.NTATS;
		if isa(Raw,'MATLAB.DataTypes.NDTable')
			Raw=Raw.Data;
		end
	else
		Raw=Data;
	end
end
[Max,Group]=max(SortCriteria(Raw),[],3);
Filter=1;
Larger=Group>Filter;
while any(Larger)
	if ~any(Group==Filter)
		GL=Group(Larger);
		Group(Larger)=GL-min(GL)+Filter;
	end
	Filter=Filter+1;
	Larger=Group>Filter;
end
SortIndex=splitapply(@(Index,Vector)SortBy(Index,Vector,SortDirection),(1:numel(Max))',Max,Group);
SortIndex=vertcat(SortIndex{:});
if TabularData
	Data=Data(SortIndex,:);
else
	Data=Data(SortIndex,:,:);
end
end
%%
function SortIndex=SortBy(SortIndex,SortVector,SortDirection)
[~,SortVector]=sort(SortVector,SortDirection);
SortIndex={SortIndex(SortVector)};
end
function Index=MaxIndex(Data)
[~,Index]=max(Data,[],2);
end

%[appendix]{"version":"1.0"}
%---
