%[text] 合并内存或文件中的多个UniExp数据库
%[text] 为了方便处理来自多个文件的UniExp数据库，必须要进行合并。合并就涉及到UID冲突的问题，此时有两种解决方法：
%[text] 1. 将UID相同的对象视为相同，取最新值
%[text] 2. 根据唯一识别码认定对象是否相同，相同的取最新值，不同的则赋予一个新的UID，并更新其它表中的该UID \
%[text] 本函数同时支持两种方法。但实际上第2种方法更常用，因为UID本身不包含任何信息，不能用来唯一识别对象，一般不应认为是相同对象，而仅用于数据库内部的索引，不跨数据库使用。但是，如果新表值本质上是对旧表值的更新，特别是更新了码的情况下，应当使用方法1。
%[text] 如果输入的任何一个数据库不包含其引用的所有UID的定义表（例如，Blocks表定义了BlockUID），不能使用方法2，只能方法1，即ChangeUID必须设为false。因为其中含有未定义的UID，无法将其映射到正确的对象。
%[text] 如果某个数据库某表某行的某个字段为空或missing值，该值将不会成为合并后的最终值，即使它是最新；除非所有数据库中该处皆为空或missing值。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] Merged=UniExp.DataSet.Merge(DataSet1,DataSet2,…,Name=Value);
%[text] ```
%[text] ## 输入参数
%[text] DataSet1,DataSet2,…，要合并的UniExp数据库。可以是UniExp.DataSet对象、结构体、结构体数组、结构体元胞数组或数据库文件路径。每个重复参数的类型无需相同。
%[text] ### 名称值参数
%[text] OutputPath(1,1)string，输出文件路径。如不指定此参数，将不输出文件。
%[text] ChangeUID(1,1)logical=true，是否允许修改UID。若true，将应用方法2进行合并；否则应用方法1。
%[text] MergeOutput(1,1)logical=true，如果输出路径已存在一个UniExp数据库，是否也将其加入合并。若设为false，已存在的文件将被覆盖，其中数据将丢失。
%[text] ## 返回值
%[text] Merged(1,1)UniExp.DataSet，合并的单个UniExp数据库，包含Commits的并集，重复数据项优先取排在后面的值。
%[text] ## 异常说明
%[text] 对于常见异常，例如损坏的数据库，异常信息会提示是第几个输入数据库出错。如果合并还包括输出位置现存的数据库，将那个现存的数据库作为“第1个”数据库，然后才轮到输入数据库。
function Merged = Merge(Inputs,options)
arguments(Repeating)
	Inputs
end
arguments
	options.OutputPath
	options.ChangeUID=true
	options.MergeOutput=true
end
HasOutput=isfield(options,'OutputPath');
if HasOutput&&options.MergeOutput
	try
		%原有数据库应当放在最前面作为最旧版被覆盖
		Inputs=[{UniExp.DataSet(options.OutputPath)},Inputs];
	catch
	end
end
Inputs=ParseInputs(Inputs);
persistent TableSpecification Dependencies AllDependencyNames ValidTableNames
if isempty(TableSpecification)
	TableSpecification={
		"DateTimes"		strings(0,1)			missing			"DateTime"
		"Blocks"		strings(0,1)			"BlockUID"		["DateTime";"BlockIndex"]
		"Trials"		"BlockUID"				"TrialUID"		["BlockUID";"TrialIndex"]
		"Cells"			strings(0,1)			"CellUID"		["Mouse";"ZLayer";"CellType";"CellIndex"]
		"BlockSignals"	["BlockUID" "CellUID"]	missing			["BlockUID";"CellUID"]
		"TrialSignals"	["TrialUID" "CellUID"]	missing			["TrialUID";"CellUID"]
		"Mice"			strings(0,1)			missing			"Mouse"
		"Manipulation"	strings(0,1)			missing			["Mouse","Brain"]
		};
	ValidTableNames=vertcat(TableSpecification{:,1});
	TableSpecification=cell2table(TableSpecification(:,2:end),RowNames=ValidTableNames,VariableNames=[ ...
		"RequireUID"			"ProvideUID"	"KeyColumns"]);
	%RequireUID是狭义的UID，不是泛指主键。
	Dependencies=struct;
	for T=1:height(TableSpecification)
		[~,Index]=ismember(TableSpecification.RequireUID{T},TableSpecification.ProvideUID);
		if ~isempty(Index)
			Dependencies.(ValidTableNames(T))=ValidTableNames(Index);
		end
	end
	AllDependencyNames=string(fieldnames(Dependencies));
end
NumCommits=numel(Inputs);
[DataSetNotes,Collection]=deal(cell(NumCommits,1));
for C=1:NumCommits
	%排除不是表的字段
	VT=Inputs(C).ValidTableNames;
	if isempty(VT)
		UniExp.Exception.Table_not_found_in_input.Throw(sprintf('第%u个输入中没有找到表',C));
	end
	Collection{C}=VT;
	DataSetNotes{C}=Inputs(C).Note;
end
Names=string(unique(vertcat(Collection{:})))';
ChangeUID=options.ChangeUID;
if ChangeUID
	DependentNames=intersect(Names,AllDependencyNames);
	Flag=true;
	while Flag
		Flag=false;
		for TableName=DependentNames'
			Sequence=[Dependencies.(TableName);TableName];

			%让输入表Names中所有和依赖Sequence重叠的子序列按照依赖Sequence中的顺序排列，以保证依赖项先被处理
			[~,IS,IN]=intersect(Sequence,Names);
			[~,IsMax]=max(IS);
			[~,InMax]=max(IN);
			if IsMax~=InMax
				Flag=true;
				Names(sort(IN))=Sequence(sort(IS));
			end
		end
	end
end
NumMergeTables=numel(Names);
CommitHasTableLogical=false(NumCommits,NumMergeTables);
for C=1:NumCommits
	CommitHasTableLogical(C,:)=any(Names==Collection{C},1);
end
TableSpecifiedMatrix=Names==ValidTableNames;
UIDMap=cell(NumCommits,1);
Merged=UniExp.DataSet;
for T=1:NumMergeTables
	TableCommit=table;
	TableCommit.InputIndex=find(CommitHasTableLogical(:,T));
	NumCommits=height(TableCommit);
	TableName=Names(T);
	TableCommit.CommitTable=cell(NumCommits,1);
	TableSpecificationIndex=find(TableSpecifiedMatrix(:,T),1);
	Flag=~isempty(TableSpecificationIndex);
	SpecifyChange=Flag&&ChangeUID;
	if SpecifyChange
		RequireUID=TableSpecification.RequireUID{TableSpecificationIndex};
		NumRequire=numel(RequireUID);
	end
	for C=1:NumCommits
		CI=TableCommit.InputIndex(C);
		Table=Inputs(CI).(TableName);
		if SpecifyChange
			AbortTable=false;
			for R=1:NumRequire
				UIDName=RequireUID(R);
				if ~any(Table.Properties.VariableNames==UIDName)
					Table.(UIDName)(:)=0x001;
					UniExp.Exception.DataSet_does_not_provide_necessary_UID.Warn(sprintf('第%u个数据库，%s',CI,UIDName));
				end
				try
					NewUID=UIDMap{CI}.(UIDName)(Table.(UIDName));
				catch ME
					if strcmp(ME.identifier,'MATLAB:badsubscript')
						if isempty(UIDMap{CI})
							UniExp.Exception.Some_commits_are_missing_UID_definitions.Warn(sprintf('第%u个数据库缺少%s定义，将跳过其%s表。是否应将ChangeUID参数设为false？',CI,UIDName,TableName));
						else
							UndefinedUIDs=unique(Table.(UIDName)(Table.(UIDName)>numel(UIDMap{CI}.(UIDName))));
							UniExp.Exception.Undefined_UID_found.Warn(sprintf('第%u个数据库的%s表包含未定义的%s：%s，将跳过该表',CI,TableName,UIDName,join(string(UndefinedUIDs),' ')));
						end
						AbortTable=true;
						break;
					else
						ME.rethrow;
					end
				end
				if all(NewUID)
					Table.(UIDName)=NewUID;
				else
					UndefinedUIDs=unique(Table.(UIDName)(~NewUID));
					UniExp.Exception.Undefined_UID_found.Warn(sprintf('第%u个数据库的%s表包含未定义的%s：%s，将跳过该表',CI,TableName,UIDName,join(string(UndefinedUIDs),' ')));
					AbortTable=true;
					break;
				end
			end
			if AbortTable
				continue;
			end
		end
		TableCommit.CommitTable{C}=Table;
	end
	TableCommit(cellfun(@isempty,TableCommit.CommitTable),:)=[];
	NumCommits=height(TableCommit);
	if~NumCommits
		continue;
	end
	MergeTable=table('Size',[1,0]);
	for C=NumCommits:-1:1
		Table=TableCommit.CommitTable{C};
		MergeTable=[MergeTable,Table(1,setdiff(Table.Properties.VariableNames,MergeTable.Properties.VariableNames))];
	end
	MergeTable=TableCategorize(FillMissing(MergeTable));
	TableCommit.CommitTable=cellfun(@(Table)[TableCategorize(Table),MergeTable(ones(height(Table),1),setdiff(MergeTable.Properties.VariableNames,Table.Properties.VariableNames))],TableCommit.CommitTable,UniformOutput=false);
	MergeTable=SafeTableVertCat(TableCommit.CommitTable{:});
	if Flag
		ProvideUID=TableSpecification.ProvideUID(TableSpecificationIndex);
		if ChangeUID
			KeyColumns=TableSpecification.KeyColumns{TableSpecificationIndex};
			HasColumns=ismember(KeyColumns,MergeTable.Properties.VariableNames);
			if all(HasColumns)
				MergeTable=MATLAB.DataFun.MergeDuplicateKeys(MergeTable,KeyColumns,@UpdateMerge);
				if ~ismissing(ProvideUID)
					MergeTable.(ProvideUID)(:)=1:height(MergeTable);
					MergeKeyTable=MergeTable(:,KeyColumns);
					for C=1:NumCommits
						Table=TableCommit.CommitTable{C};
						[Logical,Index]=ismember(Table(:,KeyColumns),MergeKeyTable);
						if ~all(Logical)
							UniExp.Exception.Bad_table_keys.Throw(sprintf('第%u个输入，表%s\n%s',C,TableName,formattedDisplayText(Table(~Logical,KeyColumns))));
						end
						CommitUIDs=Table.(ProvideUID);
						if isequaln(CommitUIDs,0)
							CommitUIDs=0x001;
							UniExp.Exception.DataSet_does_not_provide_necessary_UID.Warn(sprintf('第%u个数据库，%s',C,ProvideUID));
						end
						Map=zeros(max(CommitUIDs),1,'uint16');
						try
							Map(CommitUIDs)=MergeTable.(ProvideUID)(Index);
						catch ME
							if ME.identifier=="MATLAB:badsubscript"
								UniExp.Exception.Bad_UID.Throw(sprintf('第%u个输入，表%s',C,TableName));
							else
								ME.rethrow;
							end
						end
						UIDMap{TableCommit.InputIndex(C)}.(ProvideUID)=Map;
					end
				end
			else
				UniExp.Exception.Table_is_missing_key_column.Throw(sprintf('表%s缺少键列%s，无法合并数据库',TableName,join(KeyColumns(~HasColumns),' ')));
			end
		elseif ~ismissing(ProvideUID)
			MergeTable=MATLAB.DataFun.MergeDuplicateKeys(MergeTable,ProvideUID,@UpdateMerge);
		end
	end
	Merged.(TableName)=MergeTable;
end
Merged.Note=unique(vertcat(DataSetNotes{:}));
if HasOutput
	save(options.OutputPath,'Merged','-nocompression');
end
end
%%
function Inputs=ParseInputs(Inputs)
%必须始终以全员元胞向上传递，以保证输入顺序不变，这样才能确保"后输入的数据库作为优先更新版本覆盖老版本"的原则
if isstruct(Inputs)
	Inputs=arrayfun(@UniExp.DataSet,Inputs);
elseif iscellstr(Inputs)||isstring(Inputs)||ischar(Inputs)
	Inputs=arrayfun(@UniExp.DataSet,reshape(string(Inputs),1,[]));
elseif iscell(Inputs)
	Inputs=cellfun(@ParseInputs,Inputs,UniformOutput=false);
	Inputs=[Inputs{:}];
end
end
function Array=FillMissing(Array)
if iscell(Array)
	Array(:)={[]};
elseif istabular(Array)
	for V=1:width(Array)
		Array{:,V}=FillMissing(Array{:,V});
	end
else
	try
		Array(:)=missing;
	catch ME
		if ME.identifier=="MATLAB:UnableToConvert"
			try
				Array(:)=0;
			catch
			end
		else
			ME.rethrow;
		end
	end
end
end
function Table=SafeTableVertCat(varargin)
for V=1:nargin
	Table=varargin{V};
	if any(Table.Properties.VariableNames=="SeriesInterval")&&~isduration(Table.SeriesInterval)
		varargin{V}.SeriesInterval=milliseconds(Table.SeriesInterval);
	end
end
try
	Table=vertcat(varargin{:});
catch ME
	if ME.identifier=="MATLAB:table:vertcat:VertcatMethodFailed"
		for T=1:nargin
			Table=varargin{T};
			for C=string(Table.Properties.VariableNames)
				if iscategorical(Table.(C))
					Table.(C)=string(Table.(C));
				end
			end
			varargin{T}=Table;
		end
		Table=TableCategorize(vertcat(varargin{:}));
	else
		ME.rethrow;
	end
end
end

%[appendix]{"version":"1.0"}
%---
