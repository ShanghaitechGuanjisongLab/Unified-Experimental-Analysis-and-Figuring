%[text] 使用查询表，查询多组归一化回合信号值 (Normalized Trial Signals, NTS)
%[text] 不同于UniExp.DataSet.QueryNTATS，此函数不检查各组细胞是否相同。如果TrialSignals表中包含NormalizedSignal列，将优先从此列取得数据，否则从TrialSignal列取得数据。NormalizedSignal一般从SampleNormalize方法生成，保证所有回合信号长度相同。
%[text] 此函数会记住查询结果。如果数据库发生更新，查询结果不会自动更新，请将Memoize设为false，或者清理返回的Memoizer。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] GroupNts=obj.QueryNTS(QueryStruct);
%[text] %根据查询结构体查询单组NTATS
%[text] 
%[text] GroupNts=obj.QueryNTS(QueryTable);
%[text] %根据查询表查询多组NTATS
%[text] 
%[text] GroupNts=obj.QueryNTS(___,Normalize,F0Samples);
%[text] %与上述任意语法组合使用，额外指定归一化操作和基线时间范围
%[text] 
%[text] [___,Memoizer]=obj.QueryNTS(___);
%[text] %与上述任意语法组合使用，额外返回记忆对象
%[text] 
%[text] [___]=obj.QueryNTS(___,Memoize);
%[text] %与上述任意语法组合使用，额外指定是否使用记住的查询结果
%[text] 
%[text] [___]=obj.QueryNTS(___,Name=Value);
%[text] %与上述任意语法组合使用，额外指定名称值参数
%[text] ```
%[text] ## 示例
%[text] 查询结构体的字段值可以是向量，表示匹配其中任意一个值。例如指定DateTime为多个时间戳的向量，可一次查出所有会话的数据，而非循环逐个查询。所有匹配行将合并在同一个组（cell元素）中返回，不会按字段值自动拆分。
%[text] 如需在查询后按会话拆分，使用ExtraColumns返回关联列（如DateTime），然后在返回的表中按该列分组。
%[text] ```matlabCodeExample
%[text] % 避免循环逐会话查询（慢）：
%[text] for i = 1:numel(dts)
%[text]     ntsCell = DS.QueryNTS(struct('Stimulus','LightWater','DateTime',dts(i)), UniExp.Flags.ZScore, 1:24);
%[text] end
%[text] 
%[text] % 改为一次批量查询（快）：
%[text] q = struct('Stimulus', 'LightWater', 'DateTime', allDateTimes);
%[text] ntsCell = DS.QueryNTS(q, UniExp.Flags.ZScore, 1:24, 'ExtraColumns', ["DateTime"]);
%[text] nts = ntsCell{1};  % 所有会话的数据合并在一张表中
%[text] % nts.DateTime 列可用于按会话拆分
%[text] uDTs = unique(nts.DateTime);
%[text] for i = 1:numel(uDTs)
%[text]     sessRows = nts(nts.DateTime == uDTs(i), :);
%[text]     % ... 处理每个会话
%[text] end
%[text] ```
%[text] 注意：不同数据源（DataSet对象）之间无法合并为一次调用，每个数据源至少需要调用一次QueryNTS。
%[text] ## 输入参数
%[text] QueryStruct(1,1)struct，查询结构体，此函数调用TableQuery方法执行表查询，此参数将被直接传递给TableQuery，详见TableQuery文档。
%[text] QueryTable tabular，查询条件，此函数调用TableQuery方法执行表查询，此参数将被直接传递给TableQuery，详见TableQuery文档。特别地，如果使用GroupName设置分组名，不允许有名为“CellUID”的组名。
%[text] Normalize(1,1)UniExp.Flags=UniExp.Flags.No\_special\_operation，归一化方法，默认不做归一化，可选 dFdF0 log2FdF0 ZScore，详见UniExp.F0Normalize的Method参数
%[text] F0Samples(1,:)uint16，用作基线的信号索引。例如采样率为8、回合前2s作为基线时，F0Samples设为1:16。详见UniExp.F0Normalize的F0Index参数
%[text] Memoize(1,1)logical=true，是否使用记住的查询结果（如果有）。
%[text] ### 名称值参数
%[text] ExtraColumns(1,:)string，需要额外返回的关联信息列名。将从数据库中查询这些列，附加到每组的结果表中。
%[text] ## 返回值
%[text] #### GroupNts
%[text] 为每个组返回一个查询结果table，包含以下列：
%[text] - CellUID(:,1)uint16
%[text] - TrialUID(:,1)uint16
%[text] - TrialSignal(:,:)，要求每组所有细胞回合信号长度相同，否则出错。第2维是时间。注意，即使数据来自NormalizedSignal列，此返回表仍然将数据列命名为TrialSignal，因此不能通过此列名称判断数据来源。
%[text] - ExtraColumns要求的其它列 \
%[text] 如果查询表中指定了各组名称（GroupName），将返回(1,1)struct，每个字段对应组名，字段值为该组的查询结果表；否则，返回(:,1)cell，按照GroupIndex顺序排列，元胞内是该组的查询结果表。
%[text] #### Memoizer
%[text] (1,1)matlab.lang.MemoizedFunction，记忆对象，可用于控制记住查询结果的刷新。如果Memoize设为false，不会返回此值。使用clearCache方法清理记住的查询结果。此对象可以重复使用，不必每次调用QueryNTS都收集此对象。
%[text] **See also** [UniExp.Flags](<matlab:edit UniExp.Flags>) [UniExp.DataSet.TableQuery](matlab:MATLAB.Doc('UniExp.DataSet.TableQuery');) [UniExp.F0Normalize](<matlab:doc UniExp.F0Normalize>) [UniExp.DataSet.QueryNTATS](<matlab:doc UniExp.DataSet.QueryNTATS>) [matlab.lang.MemoizedFunction](<matlab:doc matlab.lang.MemoizedFunction>)
function [Query,Memoizer] = QueryNTS(obj,Query,varargin)
Normalize=UniExp.Flags.No_special_operation;
F0Samples=[];
Memoize=true;
ExtraColumns=strings(1,0);
V=1;
NumArgs=numel(varargin);
while V<=NumArgs
	Arg=varargin{V};
	if isa(Arg,'UniExp.Flags')
		Normalize=Arg;
		F0Samples=varargin{V+1};
		V=V+2;
	elseif islogical(Arg)
		Memoize=Arg;
		V=V+1;
	elseif Arg=="ExtraColumns"
		ExtraColumns=varargin{V+1};
		break;
	end
end
persistent PersistentMemoizer
if isempty(PersistentMemoizer)||~isvalid(PersistentMemoizer)
	PersistentMemoizer=memoize(@RealQueryNts);
	PersistentMemoizer.CacheSize=100;
end
if Memoize
	Memoizer=PersistentMemoizer;
else
	PersistentMemoizer.clearCache;
end
Query=PersistentMemoizer(obj,Query,Normalize,F0Samples,ExtraColumns);
end
function Query=RealQueryNts(obj,Query,Normalize,F0Samples,ExtraColumns)
SignalColumn=obj.GetSignalColumn;
Query=obj.TableQuery([SignalColumn,"CellUID","TrialUID",ExtraColumns],Query);
if istable(Query)
	Query={Query};
end
HasGroupNames=isstruct(Query);
if HasGroupNames
	FieldNames=fieldnames(Query);
	Query=struct2cell(Query);
end
NumQueries=numel(Query);
if HasGroupNames
	GroupID=string(FieldNames);
else
	GroupID=compose("第%u组",1:NumQueries);
end
%经测试发现并行计算提升不大，不并行
for Q=1:NumQueries
	SignalData=Query{Q}.(SignalColumn);
	if iscell(SignalData)
		try
			SignalData=vertcat(SignalData{:});
		catch ME
			switch ME.identifier
				case "MATLAB:catenate:dimensionMismatch"
					UniExp.Exception.Lengths_of_TrialSignals_within_the_query_group_is_different.Throw(sprintf('%s内%s长度不同，考虑使用<a href="matlab:doc UniExp.DataSet.SampleNormalize">UniExp.DataSet.SampleNormalize</a>',GroupID(Q),SignalColumn));
				otherwise
					ME.rethrow;
			end
		end
	end
	NTS=UniExp.F0Normalize(SignalData,Normalize,F0Samples);
	NanIndex=find(any(isnan(NTS),2));
	if ~isempty(NanIndex)
		UniExp.Exception.NaN_appears_after_normalization.Throw(sprintf('%s：归一化数据出现NaN，这通常是因为细胞圈出了配准范围之外，导致基线信号为0。涉事细胞UID：%s',GroupID(Q),join(string(Query{Q}.CellUID(NanIndex)),',')));
	end
	Query{Q}.TrialSignal=NTS;
	if SignalColumn~="TrialSignal"
		Query{Q}.(SignalColumn)=[];
	end
end
if HasGroupNames
	Query=cell2struct(Query,FieldNames);
end
end

%[appendix]{"version":"1.0"}
%---
