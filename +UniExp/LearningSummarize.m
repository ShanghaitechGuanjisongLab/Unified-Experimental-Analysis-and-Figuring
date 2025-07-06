%[text] 生成带有平均值和标准误的学习曲线数据（不作图）和学会天数的总结表
%[text] 本函数可以从命中率得到学习曲线的鼠间平均值、标准误，并自动分组。每只鼠的会话数应当相同；如果不同，将以次数最多的鼠为准，其它鼠缺少的会话数，命中率全部填充最后一个会话的命中率，然后始终在所有鼠之间计算平均
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] import UniExp.LearningSummarize
%[text] 
%[text] Summary=LearningSummarize(SessionTable);
%[text] %生成学习全程的总结表，包含学习曲线和学会天数
%[text] 
%[text] Summary=LearningSummarize(SessionTable,LearnedP);
%[text] %额外指定认为学会的阈值
%[text] 
%[text] [Summary,PValue]=LearningSummarize(___);
%[text] %与上述任意语法组合使用，额外返回组间差异显著性P值。此语法只能在恰好有2组时使用。
%[text] ```
%[text] ## 输入参数
%[text] #### SessionTable(:,4)table
%[text] 会话数据表，一行一个会话，包含以下列：
%[text] - Group(:,1)categorical，可选，会话分组名，同一组内的数据才会合并，不同组会区分为不同的线条。如果不指定，将所有会话视为同一组。
%[text] - Mouse(:,1)categorical，必需，每个会话的鼠名
%[text] - Performance(:,1)double，必需，每个会话的表现分数，用0~1表示，如命中率等 \
%[text] 以下两列必须恰好指定其一：
%[text] - DateTime(:,1)datetime，会话日期时间
%[text] - Index(:,1)，会话序号 \
%[text] #### LearnedP(1,1)double=1
%[text] 表示学会的表现分阈值，大于等于这个表现分时认为学会了
%[text] ## 返回值
%[text] #### Summary(:,4)table
%[text] 学习总结表，每组一行，包含以下列：
%[text] Properties.RowNames(:,1)string，行名称，与SessionTable.Group对应。如果SessionTable没有Group列，Summary也将不含行名称。
%[text] MeanCurve(:,1)cell，每个元胞内是(1,:)double，平均值折线点
%[text] SemCurve(:,1)cell，每个元胞内是(1,:)double，标准误
%[text] LearnedSessions(:,1)cell，每个元胞内是(:,2)table，每只鼠学会所用会话数，包含以下列：
%[text] - Mouse(1,1)categorical，鼠名
%[text] - NumSessions(1,1)double，学会所用会话数，表示每只鼠Performance第一次达到LearnedP的天数。如果始终没有学会，则为Inf。 \
%[text] #### PValue(1,1)double
%[text] 使用方差分析计算两组学习曲线之间是否有显著差异，返回一个P值。此返回值只能在恰好有2组时使用。
function [Summary,PValue]=LearningSummarize(SessionTable,LearnedP)
arguments
	SessionTable
	LearnedP=1
end
HasColumns=ismember(["Index","Group"],SessionTable.Properties.VariableNames);
if HasColumns(1)
	SessionTable.DateTime=SessionTable.Index;
end
if HasColumns(2)
	[GroupG,RowNames]=findgroups(string(SessionTable.Group));
	Summary=table('RowNames',RowNames);
	[Summary.MeanCurve,Summary.SemCurve,Summary.LearnedSessions,SessionTable]=splitapply(@(varargin)ForEachGroup(LearnedP,varargin{:}),SessionTable(:,["Mouse","DateTime","Performance","Group"]),GroupG);
	if nargout>1
		if isscalar(RowNames)
			UniExp.Exceptions.Cannot_LME_on_only_one_group.Throw;
		end
		SessionTable=vertcat(SessionTable{:});
		SessionTable.Performance=double(SessionTable.Performance);
		PValue=UniExp.TabularAnovaN(SessionTable.Performance,SessionTable(:,["Group","BlockIndex"]),Continuous="BlockIndex");
		PValue=PValue(1);
	end
else
	Summary=table;
	[Summary.MeanCurve,Summary.SemCurve,Summary.LearnedSessions]=ForEachGroup(LearnedP,SessionTable.Mouse,SessionTable.DateTime,SessionTable.Performance);
	if nargout>1
		UniExp.Exceptions.Cannot_ANOVA_on_only_one_group.Throw;
	end
end
end
%%
function [MeanCurve,SemCurve,MouseDays,SessionTable]=ForEachGroup(LearnedP,Mouse,BlockIndex,Performance,Group)
[MouseG,UniqueMice]=findgroups(Mouse);
NumMice=numel(UniqueMice);
NumBlocks=max(groupcounts(MouseG));
NumSessions=NaN(NumMice,1);
PerformanceMatrix=NaN(NumMice,NumBlocks);
for M=1:NumMice
	Logical=MouseG==M;
	[~,SortIndex]=sort(BlockIndex(Logical));
	MousePerformance=Performance(Logical);
	MousePerformance=MousePerformance(SortIndex);
	Days=find(MousePerformance>=LearnedP,1);
	if isempty(Days)
		Days=Inf;
	end
	NumSessions(M)=Days;
	MouseNumBlocks=numel(MousePerformance);
	PerformanceMatrix(M,1:MouseNumBlocks)=MousePerformance;
	PerformanceMatrix(M,MouseNumBlocks+1:end)=MousePerformance(end); %填充最后一个会话的命中率
end
[MeanCurve,SemCurve]=MATLAB.DataFun.MeanSem(PerformanceMatrix,1);
MeanCurve={MeanCurve};
SemCurve={SemCurve};
MouseDays={table(UniqueMice,NumSessions,'VariableNames',["Mouse","NumSessions"])};
if nargout>3
	BlockIndex=findgroups(BlockIndex);
	SessionTable={table(Mouse,BlockIndex,Performance,Group)};
end
end

%[appendix]{"version":"1.0"}
%---
