classdef DataSet<handle&matlab.mixin.Copyable
	%UniExp数据集大类，包含多种处理、分析方法，是实现统一实验分析作图的通用数据集类型。
	%此类的属性，除Version外，是按照BC范式设计的数据库表。可以从包含这些表的结构体或另一个此类对象构造对象。每个表都可以留空。
	%注意此类是句柄类，必须使用MakeCopy成员函数才能复制对象，直接赋值给其它变量只能取得数据集的一个引用。
	properties
		%主键Mouse，鼠名。本表其它列可选，但应当是与该鼠特定的信息，如实验范式等。
		Mice table

		%主键DateTime，实验进行的时间日期，本表其它列可选，但应当是与该次实验特定的信息，例如鼠、拍摄采样率、元数据等
		DateTimes table

		%主键BlockUID，模块的唯一标识符；码(DateTime,BlockIndex)，因为“一次特定实验的第N个模块”应当可以唯一确定一个模块。主键和码应当一一对应且不能重复。其它可选列应
		% 当是特定于该模块的信息，如模块设计名称、标通道值、事件日志等
		Blocks table

		%主键TrialUID，回合的唯一标识符；码(BlockUID,TrialIndex)，因为“一个特定模块的第N回合”应当可以唯一确定一个回合。其它可选列应当是特定于该回合的信息，如刺激类
		% 型、标通道值、采样时点、动物行为等。
		Trials=table
		%不能限定table类型，因为需要在saveobj中设置为结构体

		%主键CellUID，细胞的唯一标识符；码(Mouse,ZLayer,CellType,CellIndex)，因为“一只鼠某层某种类型的第N个细胞”应当可以唯一确定一个细胞。其它可选列应当是特定于该细
		% 胞的信息，如像素位置等。
		Cells table

		%主键(CellUID,BlockUID)，用模块和细胞的组合唯一标识该细胞在该模块的活动，可选列如BlockSignal等
		BlockSignals=table
		%不能限定table类型，因为需要在saveobj中设置为结构体

		%主键(CellUID,TrialUID)，用回合和细胞的组合唯一标识该细胞在该回合的活动，可选列如TrialSignal等
		TrialSignals=table
		%不能限定table类型，因为需要在saveobj中设置为结构体

		%主键(Mouse,BrainArea)，记录每只鼠操纵了哪些脑区
		Manipulation table

		%产生此对象的UniExp版本
		Version=UniExp.Version

		%其它额外备注信息
		Note(:,1)string
	end
	methods(Static)
		Merged = Merge(Inputs,options)
		varargout=Rename(Column,Old,New,varargin)
		function CM=CheckMouse(CM)
			%设置或获取是否检查鼠名
			persistent Value
			if isempty(Value)
				Value=true;
			end
			if nargin
				Value=CM;
			else
				CM=Value;
			end
		end
	end
	methods(Static,Access=protected)
		function obj=loadobj(obj)
			for StructName=["BlockSignals","TrialSignals","Trials"]
				Struct=obj.(StructName);
				if isstruct(Struct)&&~isempty(Struct)
					ColumnNames=fieldnames(Struct);
					for C=1:numel(ColumnNames)
						Column=Struct.(ColumnNames{C});
						if iscell(Column)
							Column=arrayfun(@(V,NumSplit)mat2cell(V{1},repmat(height(V{1})/NumSplit,NumSplit,1)),Column,Struct.NumSplit,UniformOutput=false);
							Column=vertcat(Column{:});
							Struct.(ColumnNames{C})=Column;
						end
					end
					obj.(StructName)=struct2table(rmfield(Struct,'NumSplit'));
				end
			end
			Struct=obj.Cells;
			if isstruct(Struct)&&~isempty(Struct)
				Struct.PixelXY=mat2cell(Struct.PixelXY,Struct.NumPixels);
				obj.Cells=struct2table(rmfield(Struct,'NumPixels'));
			end
		end
	end
	methods(Access=protected)
		function SC=GetSignalColumn(obj)
			persistent PossibleSignalColumns
			if istable(obj.TrialSignals)
				if isempty(PossibleSignalColumns)
					PossibleSignalColumns=["ResampledSignal","NormalizedSignal","TrialSignal"];
				end
				SC=PossibleSignalColumns(find(ismember(PossibleSignalColumns,obj.TrialSignals.Properties.VariableNames),1));
			else
				UniExp.Exception.DataSet_is_missing_TrialSignals.Throw;
			end
		end
		function obj=saveobj(obj)
			obj=obj.copy;%避免修改影响原本工作区中的变量
			for TableName=["BlockSignals","TrialSignals","Trials"]
				Table=obj.(TableName);
				if istabular(Table)&&~isempty(Table)
					Logical=varfun(@iscell,Table,OutputFormat='uniform');
					if any(Logical)
						[~,~,Groups]=unique(cell2mat(cellfun(@size,Table{:,Logical},UniformOutput=false)),'rows');
						StructValues=cell(1,width(Table));
						[StructValues{:}]=splitapply(@(varargin)LogicalColumnsCat(Logical,varargin),Table,Groups);
						Logical=~Logical;
						StructValues(Logical)=cellfun(@(V)vertcat(V{:}),StructValues(Logical),UniformOutput=false);
						Table=cell2struct(StructValues,Table.Properties.VariableNames,2);
						Table.NumSplit=groupcounts(Groups);
						obj.(TableName)=Table;
					end
				end
			end
		end
		function New=copyElement(Old)
			New=UniExp.DataSet(Old);
		end
	end
	methods
		function obj=DataSet(StructOrPath)
			%构造方法，提供包含表的结构体或mat文件路径
			%# 语法
			% ```
			% obj=UniExp.DataSet(Struct);
			% %从包含表的结构体构造对象
			%
			% obj=UniExp.DataSet(Path);
			% %从包含表或对象的文件构造对象
			% ```
			%# 输入参数
			% Struct(1,1)struct，包含表的结构体
			% Path(1,1)string，包含表或对象的mat文件
			if nargin
				InputPath=ischar(StructOrPath)||isstring(StructOrPath);
				if InputPath
					Path=StructOrPath;
					[~,Filename,Extension]=fileparts(Path);
					FileFields=string(split(Filename,'.'));
					CheckMouse=UniExp.DataSet.CheckMouse&&~isscalar(FileFields);
					FromPath=Path;
					if startsWith(Path,'\\')
						%Samba网络访问优化
						Path=fullfile(tempdir,strcat(Filename,Extension));
						copyfile(FromPath,Path);
					end
					try
						StructOrPath=load(Path);
					catch ME
						if ME.identifier=="MATLAB:load:notBinaryFile"
							UniExp.Exception.Mat_load_failed.Throw(FromPath);
						else
							ME.rethrow;
						end
					end
					Cells=struct2cell(StructOrPath);
					Logical=cellfun(@(C)isa(C,'UniExp.DataSet'),Cells);
					Already=any(Logical);
					if Already
						obj=Cells{Logical};
					end
				else
					CheckMouse=false;
					Already=false;
				end
				if ~Already
					Fields=intersect(fieldnames(StructOrPath),properties(obj));
					if isempty(Fields)
						if InputPath
							UniExp.Exception.Struct_cannot_be_parsed_to_DataSet.Throw(Path);
						else
							UniExp.Exception.Struct_cannot_be_parsed_to_DataSet.Throw;
						end
					end
					for F=1:numel(Fields)
						obj.(Fields{F})=StructOrPath.(Fields{F});
					end
				end
				if CheckMouse
					for TableName=["Mice","DateTimes","Cells"]
						if ~isempty(obj.(TableName))
							CheckMouse=unique(obj.(TableName).Mouse);
							if isscalar(CheckMouse)
								if CheckMouse~=FileFields(1)
									warning('文件“%s”中的鼠名字段似乎和数据库“%s”表内记录的不一致。如果文件名中没有鼠名字段，请忽略本条警告。',Filename,TableName);
									break;
								end
							else
								break;
							end
						end
					end
				end
			end
		end
		function VT=ValidTableNames(obj)
			%取得数据集中不为空的表名称
			%# 语法
			% ```
			% VT=obj.ValidTableNames;
			% ```
			%# 返回值
			% VT(:,1)cell，数据集中不为空的表名称
			TableNames=properties(obj);
			NumTableNames=numel(TableNames);
			VT=false(NumTableNames,1);
			for T=1:NumTableNames
				Property=obj.(TableNames{T});
				VT(T)=istabular(Property)&&~isempty(Property);
			end
			VT=TableNames(VT);
		end
		function RemoveCells(obj,CellUIDs)
			%从数据库中移除一群细胞的一切关联数据
			%处理数据集时经常发现一些细胞的数据存在明显异常，这种异常并非实验事实，而是实验过程引入的假象。这样的异常细胞往往需要从数据集中排除。本函数从所有表中自动
			% 删除与指定UID相关的细胞的所有数据，无需手工排查。
			%# 语法
			% ```
			% obj.RemoveCells(CellUIDs);
			% ```
			%# 输入参数
			% CellUIDs(:,1)uint16，要移除的细胞UID。
			arguments
				obj
				CellUIDs(:,1)uint16
			end
			if istabular(obj.Cells)
				obj.Cells(ismember(obj.Cells.CellUID,CellUIDs),:)=[];
			end
			if ~isempty(obj.BlockSignals)%空表可能缺少CellUID列
				obj.BlockSignals(ismember(obj.BlockSignals.CellUID,CellUIDs),:)=[];
			end
			if istabular(obj.TrialSignals)
				obj.TrialSignals(ismember(obj.TrialSignals.CellUID,CellUIDs),:)=[];
			end
		end
		function AddRepeatIndex(obj)
			%为Blocks和Trials添加重复序数列，便于查询
			%同一只鼠，同样的设计，经常需要重复做个Block。查询数据时，一个常见查询条件就是查"第N次"做该设计的数据。这个"第N次"是按照时间顺序排列的，也就是所谓的重复序
			% 数。同样，对于回合，也存在同一个Block内随机穿插不同的刺激，需要查询"第N次"重复该刺激的数据，这就是回合的重复序数。
			%本函数为数据集的Blocks表添加BlockRI列，指示该Block是该鼠、该设计的第几次重复实验；为Trials表添加TrialRI列，指示该回合是该Block、该刺激的第几次重复。
			%# 语法
			% ```
			% obj.AddRepeatIndex;
			% ```
			Query=MATLAB.DataTypes.Select(["DateTime","Mouse","Design"],{obj.DateTimes,obj.Blocks});
			[RepeatIndex,Index]=splitapply(@GetRepeatIndex,Query.DateTime,findgroups(Query(:,["Mouse","Design"])));
			[~,Index]=ismember(vertcat(Index{:}),obj.Blocks.DateTime);
			obj.Blocks.BlockRI(Index)=vertcat(RepeatIndex{:});
			if istable(obj.Trials)
				if any(obj.Trials.Properties.VariableNames=="Stimulus")
					[RepeatIndex,~,Index]=splitapply(@GetRepeatIndex,obj.Trials(:,["TrialIndex","TrialUID"]),findgroups(obj.Trials(:,["BlockUID","Stimulus"])));
					[~,Index]=ismember(vertcat(Index{:}),obj.Trials.TrialUID);
					obj.Trials.TrialRI(Index)=vertcat(RepeatIndex{:});
				else
					UniExp.Exception.TrialRI_could_not_be_calculated_for_Trials_without_Stimulus.Warn;
				end
			end
		end
		function RemoveDateTimes(obj,DateTimes)
			%从数据库中移除一些日期时间的一切关联数据
			%处理数据集时经常发现一些日期时间的数据存在明显异常，这种异常并非实验事实，而是实验过程引入的假象。这样的异常日期时间往往需要从数据集中排除。本函数从所有
			% 表中自动删除与指定日期时间相关的所有数据，无需手工排查。
			%# 语法
			% ```
			% obj.RemoveDateTimes(DateTimes);
			% ```
			%# 输入参数
			% DateTimes(:,1)datetime，要移除的日期时间。例如`datetime('2022-11-01 10:33:16')`
			HasTables=num2cell(ismember(["DateTimes","Blocks","Trials","BlockSignals","TrialSignals"],obj.ValidTableNames));
			[HasDateTimes,HasBlocks,HasTrials,HasBlockSignals,HasTrialSignals]=HasTables{:};
			if HasDateTimes
				obj.DateTimes(ismember(obj.DateTimes.DateTime,DateTimes),:)=[];
			end
			if HasBlocks
				Logical=ismember(obj.Blocks.DateTime,DateTimes);
				BlockUIDs=obj.Blocks.BlockUID(Logical);
				obj.Blocks(Logical,:)=[];
				if HasTrials
					Logical=ismember(obj.Trials.BlockUID,BlockUIDs);
					TrialUIDs=obj.Trials.TrialUID(Logical);
					obj.Trials(Logical,:)=[];
					if HasTrialSignals
						obj.TrialSignals(ismember(obj.TrialSignals.TrialUID,TrialUIDs),:)=[];
					end
				end
				if HasBlockSignals
					obj.BlockSignals(ismember(obj.BlockSignals.BlockUID,BlockUIDs),:)=[];
				end
			end
		end
		function SetDesignByStimuli(obj,DSTable)
			%根据刺激类型组合自动生成模块设计
			%# 语法
			% ```
			% obj.SetDesignByStimuli(DSTable);
			% ```
			%# 示例
			% ```
			% DataSet.SetDesignByStimuli(cell2table({ ...
			% ["LightOnly","AudioOnly","WaterOnly"]								"LAuW"
			% ["LightOnly","LightWater"]										"LLw"
			% ["AudioOnly","AudioWater"]										"AuAuw"
			% ["LightOnly","AudioOnly","WaterOnly","LightWater","AudioWater"]	"LAuWLwAuw"
			% ["LightOnly","AudioOnly","WaterOnly","LightWater"]				"LAuWLw"
			% "LightWater"														"LightWater"
			% "AudioWater"														"AudioWater"
			% "AirWater"														"AirWater"
			% },VariableNames=["Stimuli","Design"]));
			% ```
			%# 输入参数
			% DSTable table，刺激组合与设计的映射表。必须包含以下列：
			% - Stimuli(1,1)cell，刺激组合，元胞内是(1,:)categorical，表示该组合内包含的所有刺激
			% - Design(1,1)categorical，刺激组合对应的设计。所有恰好包含Stimuli所有刺激类型回合的模块，都会被设置为该Design。
			BlockDesign=groupsummary(obj.Trials,"BlockUID",@(Stimuli)StimuliToDesign(Stimuli,DSTable),"Stimulus");
			BlockDesign(ismissing(BlockDesign.fun1_Stimulus),:)=[];
			[~,Index]=ismember(BlockDesign.BlockUID,obj.Blocks.BlockUID);
			obj.Blocks.Design(Index)=categorical(BlockDesign.fun1_Stimulus);
		end
		function NewTrial(obj,BlockUID,TrialIndex,varargin)
			%手动添加一个新的回合
			%# 语法
			% ```
			% obj.NewTrial(BlockUID,TrialIndex,Name=Value);
			% ```
			%# 输入参数
			% BlockUID(1,1)uint16，新回合所属的BlockUID，必须已存在于Blocks表中
			% TrialIndex(1,1)uint16，新回合的序号，不能与同BlockUID下的其它回合的序号冲突
			% Name=Value，其它名称值参数，将添加到新建回合的对应列下。
			if ~any(obj.Blocks.BlockUID==BlockUID)
				UniExp.Exception.Specified_BlockUID_does_not_exist_in_the_Blocks_table.Throw(BlockUID);
			end
			TrialLogical=obj.Trials.BlockUID==BlockUID;
			if any(obj.Trials.TrialIndex(TrialLogical)==TrialIndex)
				UniExp.Exception.Specified_TrialIndex_already_exists_in_the_specified_Block.Throw(TrialIndex);
			end
			TrialUID=max(obj.Trials.TrialUID);
			if TrialUID<intmax('uint16')
				TrialUID=TrialUID+1;
			else
				TrialUID=find(~ismember(1:intmax('uint16'),obj.Trials.TrialUID),1);
			end
			warning off MATLAB:table:RowsAddedExistingVars
			obj.Trials.TrialUID(end+1)=TrialUID;
			obj.Trials.BlockUID(end)=BlockUID;
			obj.Trials.TrialIndex(end)=TrialIndex;
			for V=1:2:numel(varargin)
				obj.Trials.(varargin{V})(end)=varargin{V+1};
			end
		end
		function S=struct(obj,~)
			%数据库的各个表导出到结构体
			%# 语法
			% ```
			% S=obj.struct;
			% %将对象中的非空表导出到结构体
			%
			% S=obj.struct(Flags);
			% %额外指定功能旗帜
			% ```
			%# 输入参数
			% Flags(1,1)UniExp.Flags，指定额外功能旗帜。仅支持UniExp.Flags.AllProperties，指定此旗帜时，对象中的所有属性都会被导出到结构体，包括空表、Version和Note；
			%  如不指定，仅非空表会被导出到结构体。
			%# 返回值
			% S(1,1)struct，包含对象中各个属性作为字段的结构体。
			if nargin>1
				Properties=properties(obj);
				Properties{end+1}='CellSaveOptimize';
			else
				Properties=obj.ValidTableNames;
			end
			S=struct;
			for P=string(Properties')
				S.(P)=obj.(P);
			end
		end
		function RemoveTrials(obj,TrialUIDs)
			%移除数据库中的指定回合
			%将从Trials和TrialSignals表中移除指定回合的所有记录。
			%# 语法
			% ```
			% obj.RemoveTrials(TrialUIDs);
			% ```
			%# 输入参数
			% TrialUIDs(:,1)uint16，要移除的回合UID
			if ~isempty(obj.TrialSignals)
				obj.TrialSignals(ismember(obj.TrialSignals.TrialUID,TrialUIDs),:)=[];
			end
			if ~isempty(obj.Trials)
				obj.Trials(ismember(obj.Trials.TrialUID,TrialUIDs),:)=[];
			end
		end
		function CollectMice(obj)
			%从DateTimes和Cells表中收集所有鼠，添加到Mice表
			if isempty(obj.Mice)
				if isempty(obj.DateTimes)
					if ~isempty(obj.Cells)
						obj.Mice=table(unique(obj.Cells.Mouse),'VariableNames',"Mouse");
					end
				else
					if isempty(obj.Cells)
						NewMice=unique(obj.DateTimes.Mouse);
					else
						NewMice=union(obj.DateTimes.Mouse,obj.Cells.Mouse);
					end
					obj.Mice=table(NewMice,'VariableNames',"Mouse");
				end
			elseif isempty(obj.DateTimes)
				if ~isempty(obj.Cells)
					NewMice=setdiff(obj.Cells.Mouse,obj.Mice.Mouse);
					obj.Mice.Mouse(end+1:end+numel(NewMice))=NewMice;
				end
			else
				if isempty(obj.Cells)
					NewMice=obj.DateTimes.Mouse;
				else
					NewMice=[obj.DateTimes.Mouse;obj.Cells.Mouse];
				end
				NewMice=setdiff(NewMice,obj.Mice.Mouse);
				obj.Mice.Mouse(end+1:end+numel(NewMice))=NewMice;
			end
		end
		function LightLeakageProbabilities=CheckForLightLeakage(obj,LightingPeriod,LightStimuli)
			%检查数据库中各Block在指定回合时段发生漏光的概率
			%确认漏光后可以使用LightLeakageInterpolation方法进行消除
			%# 语法
			% ```
			% LightLeakageProbabilities=obj.CheckForLightLeakage(LightingPeriod);
			% %检查每个回合的指定时段内是否漏光
			%
			% LightLeakageProbabilities=obj.CheckForLightLeakage(LightingPeriod,LightStimuli);
			% %仅检查具有特定刺激类型的回合，以提高性能并避免检出那些理论上不可能漏光的刺激类型
			% ```
			%# 示例
			% 将数据库中漏光概率最大的Block作成代表性线图
			% ```
			% figure;
			% %将obj换成你的数据库变量名
			% plot(median(vertcat(obj.TableQuery("TrialSignal",BlockUID=sortrows(obj.CheckForLightLeakage(seconds([3,3.2]),"LightWater"),'Probability','descend').BlockUID(1),Stimulus="LightWater").TrialSignal{:}),1,'omitnan'));
			% ```
			%# 输入参数
			% LightingPeriod(1,2)duration，给光的时间段，相对于一段TrialSignal开始的时间（而不是刺激时点）
			% LightStimuli(1,:)categorical，有可能漏光的刺激类型。如不指定此参数，所有刺激类型都会被视为可能漏光的。除非所有刺激类型均可能漏光，否则一般应当指定此参
			%  数，特别是存在多种刺激类型穿插的Block中，如果某些刺激类型本身不可能漏光而不被排除，则可能拉低那些可能漏光的刺激类型的漏光概率
			%# 返回值
			% LightLeakageProbabilities(:,2)table，包含BlockUID和Probability两列，每行标识一个Block的漏光概率。通常可以认为概率>0.95即为显著性漏光。
			%See also UniExp.DataSet.LightLeakageInterpolation
			arguments
				obj
				LightingPeriod(1,2)
				LightStimuli
			end
			if nargin>2
				LightStimuli={'Stimulus',LightStimuli};
				LightLeakageProbabilities={obj.Blocks,obj.DateTimes,obj.Trials};
			else
				LightStimuli={};
				LightLeakageProbabilities={obj.Blocks,obj.DateTimes};
			end
			LightLeakageProbabilities=unique(MATLAB.DataTypes.Select(["BlockUID","SeriesInterval"],LightLeakageProbabilities,LightStimuli{:}));
			LightingPeriod=ceil(LightingPeriod./LightLeakageProbabilities.SeriesInterval);
			BlockTrialSignals=MATLAB.DataTypes.Select(["BlockUID","TrialSignal"],{obj.TrialSignals,obj.Trials},LightStimuli{:},BlockUID=LightLeakageProbabilities.BlockUID);
			for B=1:height(LightLeakageProbabilities)
				MaxIndex=MATLAB.ElMat.PadCat(1,BlockTrialSignals.TrialSignal{BlockTrialSignals.BlockUID==LightLeakageProbabilities.BlockUID(B)},Padder=NaN);
				if isempty(MaxIndex)
					LightLeakageProbabilities.Probability(B)=NaN;
				else
					From=LightingPeriod(B,1);
					To=LightingPeriod(B,2);
					Duration=To-From;
					[~,MaxIndex]=max(MaxIndex(:,From-1:To+1),[],2);
					LightLeakageProbabilities.Probability(B)=binocdf(sum(isbetween(MaxIndex,2,Duration+2)),height(MaxIndex),(Duration+1)/(Duration+3));
				end
			end
			LightLeakageProbabilities(isnan(LightLeakageProbabilities.Probability),:)=[];
			LightLeakageProbabilities=LightLeakageProbabilities(:,["BlockUID","Probability"]);
		end
		function UpdateDateTime(obj,Update)
			%更新数据库中已存在的日期时间
			%此方法在Blocks和DateTimes表中更新指定的日期时间。不能更新DateTimes表中不存在的日期时间。
			%# 语法
			% ```
			% obj.UpdateDateTime(Update);
			% ```
			%# 输入参数
			% Update(:,2)datetime，两列矩阵，第一列是已存在的日期时间，第二列更新到的日期时间
			[Exists,Index]=ismember(Update(:,1),obj.DateTimes.DateTime);
			if all(Exists)
				obj.DateTimes.DateTime(Index)=Update(:,2);
			else
				UniExp.Exception.DateTime_not_exist.Throw(join(string(Update(~Exists,1)),' '));
			end
			[~,IB,IU]=intersect(obj.Blocks.DateTime,Update(:,1));
			obj.Blocks.DateTime(IB)=Update(IU,2);
		end
	end
end
function varargout=GetRepeatIndex(varargin)
varargout=[{{findgroups(varargin{1})}},num2cell(varargin)];
end
function Design=StimuliToDesign(Stimuli,DSTable)
for D=1:height(DSTable)
	if isempty(setxor(Stimuli,DSTable.Stimuli{D}))
		Design=DSTable.Design(D);
		return
	end
end
Design=missing;
end
function varargout=LogicalColumnsCat(Logical,Columns)
varargout=Columns;
varargout(Logical)=cellfun(@(V){vertcat(V{:})},Columns(Logical),UniformOutput=false);
Logical=~Logical;
varargout(Logical)=cellfun(@(V){V},Columns(Logical),UniformOutput=false);
end