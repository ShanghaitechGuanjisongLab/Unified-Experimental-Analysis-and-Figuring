classdef DataSet<handle
	%UniExp数据集大类，包含多种处理、分析方法，是实现统一实验分析作图的通用数据集类型。
	%此类的属性，除Version外，是按照BC范式设计的数据库表。可以从包含这些表的结构体或另一个此类对象构造对象。每个表都可以留空。
	%注意此类是句柄类，必须使用MakeCopy成员函数才能复制对象，直接赋值给其它变量只能取得数据集的一个引用。
	properties
		%主键Mouse，鼠名。本表其它列可选，但应当是与该鼠特定的信息，如实验范式等。
		Mice

		%主键DateTime，实验进行的时间日期，本表其它列可选，但应当是与该次实验特定的信息，例如鼠、拍摄采样率、元数据等
		DateTimes

		%主键BlockUID，模块的唯一标识符；码(DateTime,BlockIndex)，因为“一次特定实验的第N个模块”应当可以唯一确定一个模块。主键和码应当一一对应且不能重复。其它可选列应
		% 当是特定于该模块的信息，如模块设计名称、标通道值、事件日志等
		Blocks

		%主键TrialUID，回合的唯一标识符；码(BlockUID,TrialIndex)，因为“一个特定模块的第N回合”应当可以唯一确定一个回合。其它可选列应当是特定于该回合的信息，如刺激类
		% 型、标通道值、采样时点、动物行为等。
		Trials

		%主键CellUID，细胞的唯一标识符；码(Mouse,ZLayer,CellType,CellIndex)，因为“一只鼠某层某种类型的第N个细胞”应当可以唯一确定一个细胞。其它可选列应当是特定于该细
		% 胞的信息，如像素位置等。
		Cells

		%主键(CellUID,BlockUID)，用模块和细胞的组合唯一标识该细胞在该模块的活动，可选列如BlockSignal等
		BlockSignals

		%主键(CellUID,TrialUID)，用回合和细胞的组合唯一标识该细胞在该回合的活动，可选列如TrialSignal等
		TrialSignals

		%保存一些常用的查询以便快速打开
		CommonQueries

		%产生此对象的UniExp版本
		Version=UniExp.Version
	end
	methods(Static)
		Merged = Merge(Inputs,options)
		varargout=RenameMice(Old,New,varargin)
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
	methods(Access=private,Static)
		function [UID,Time]=GetRepeatIndex(UID,Time)
			UID={UID};
			Time={findgroups(Time)};
		end
		function [TrialUID,Behavior]=GetBehavior(TrialUID,TrialTags,ResponseWindow)
			TrialUID={TrialUID};
			TrialTags=[TrialTags{:}];
			Behavior={any(TrialTags(ResponseWindow(1):ResponseWindow(2),:)>mean2(TrialTags)+std2(TrialTags),1)'};
		end
		function [ResizedTT,TrialUID]=TrialTagsResize(TrialTags,TrialUID,Height)
			Sample=TrialTags{1};
			VariableNames=Sample.Properties.VariableNames;
			TrialTags=cellfun(@table2array,TrialTags,UniformOutput=false);
			TrialTags=imresize(cat(3,TrialTags{:}),[Height,width(Sample)]);
			NumTables=size(TrialTags,3);
			ResizedTT=cell(NumTables,1);
			for T=1:NumTables
				ResizedTT{T}=array2table(TrialTags(:,:,T),VariableNames=VariableNames);
			end
			ResizedTT={ResizedTT};
			TrialUID={TrialUID};
		end
		function [TrialSignals,SignalIndex]=TrialSignalsResize(TrialSignals,SignalIndex,NormalizeTo)
			TrialSignals={num2cell(imresize(vertcat(TrialSignals{:}),[numel(TrialSignals),NormalizeTo]),2)};
			SignalIndex={SignalIndex};
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
				CheckMouse=ischar(StructOrPath)||isstring(StructOrPath);
				if CheckMouse
					[~,Filename]=fileparts(StructOrPath);
					Filename=string(split(Filename,'.'));
					CheckMouse=UniExp.DataSet.CheckMouse&&~isscalar(Filename);
					StructOrPath=load(StructOrPath);
					Cells=struct2cell(StructOrPath);
					Logical=cellfun(@(C)isa(C,'UniExp.DataSet'),Cells);
					if any(Logical)
						StructOrPath=Cells{Logical};
					end
				end
				Fields=string(intersect(fieldnames(StructOrPath),properties(obj)))';
				if isempty(Fields)
					warning('输入结构体没有任何符合UniExp规范的字段');
				end
				for F=Fields
					obj.(F)=StructOrPath.(F);
				end
				if CheckMouse
					for TableName=["Mice","DateTimes","Cells"]
						if ~isempty(obj.(TableName))&&any(obj.(TableName).Mouse~=Filename(1))
							warning('文件“%s”中的鼠名字段似乎和数据库“%s”表内记录的不一致',Filename,TableName);
							break;
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
		function obj=MakeCopy(obj)
			%取得对象的一个拷贝
			%# 语法
			% ```
			% New=Old.MakeCopy;
			% ```
			%# 返回值
			% New(1,1)UniExp.DataSet，原对象的拷贝。修改该新对象的成员不会导致原对象被修改。
			obj=UniExp.DataSet(obj);
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
			if istabular(obj.BlockSignals)
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
			Query=MATLAB.DataTypes.Select({obj.DateTimes,obj.Blocks},["DateTime","Mouse","Design"]);
			[Index,RepeatIndex]=splitapply(@UniExp.DataSet.GetRepeatIndex,(1:height(Query))',Query.DateTime,findgroups(Query(:,["Mouse","Design"])));
			obj.Blocks.BlockRI(vertcat(Index{:}))=vertcat(RepeatIndex{:});
			[Index,RepeatIndex]=splitapply(@UniExp.DataSet.GetRepeatIndex,(1:height(obj.Trials))',obj.Trials.TrialIndex,findgroups(obj.Trials(:,["BlockUID","Stimulus"])));
			obj.Trials.TrialRI(vertcat(Index{:}))=vertcat(RepeatIndex{:});
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
		function AddBehaviorFromTrialTags(obj,ResponseWindow)
			%根据TrialTags，向数据集的Trials表添加二元行为
			%此函数根据TrialTags在指定时间窗内的信号，是否存在比平均值高一倍标准差的尖峰，判断行为0或1。不含TrialTags的回合行为不变，默认NaN。行为值将作为Behavior列
			% 添加到Trials表。
			%# 语法
			% ```
			% obj.AddBehaviorFromTrialTags(ResponseWindow);
			% ```
			%# 输入参数
			% ResponseWindow(1,2)double，时间窗范围秒数，相对于回合开始（而不是刺激开始），例如[2,3]
			Query=MATLAB.DataTypes.Select({obj.Trials,obj.Blocks,obj.DateTimes},["TrialUID","TrialTags","SeriesInterval"]);
			Query(cellfun(@isempty,Query.TrialTags)|isnan(Query.SeriesInterval),:)=[];
			TrialTags=cellfun(@(Table)Table.CD2,Query.TrialTags,UniformOutput=false);
			Query.NumSamples=cellfun(@height,TrialTags);
			[TrialUID,Behavior]=splitapply(@UniExp.DataSet.GetBehavior,Query.TrialUID,TrialTags,uint16(ResponseWindow*1000./Query.SeriesInterval),findgroups(Query(:,["SeriesInterval","NumSamples"])));
			TrialUID=vertcat(TrialUID{:});
			[~,Index]=ismember(TrialUID,obj.Trials.TrialUID);
			if ~ismember("Behavior",obj.Trials.Properties.VariableNames)
				obj.Trials.Behavior(~ismember(obj.Trials.TrialUID,TrialUID))=single(NaN);
			end
			obj.Trials.Behavior(Index)=single(vertcat(Behavior{:}));
		end
		function SampleNormalize(obj)
			%对数据集中所有回合信号和标进行归一化，重采样到最短信号的长度
			%# 语法
			% ```
			% obj.SampleNormalize;
			% ```
			Lengths=cellfun(@numel,obj.TrialSignals.TrialSignal);
			NormalizeSignal=Lengths>0;
			Lengths=Lengths(NormalizeSignal);
			Heights=cellfun(@height,obj.Trials.TrialTags);
			NormalizeTags=Heights>0;
			ValidHeights=Heights(NormalizeTags);
			NormalizeTo=min([Lengths;ValidHeights]);
			NormalizeSignal(NormalizeSignal)=Lengths~=NormalizeTo;
			NormalizeTags(NormalizeTags)=ValidHeights~=NormalizeTo;
			if any(NormalizeSignal)
				SignalIndex=1:height(obj.TrialSignals);
				[TrialSignal,SignalIndex]=splitapply(@(TrialSignals,SignalIndex)UniExp.DataSet.TrialSignalsResize(TrialSignals,SignalIndex,NormalizeTo),obj.TrialSignals.TrialSignal(NormalizeSignal),SignalIndex(NormalizeSignal)',findgroups(Lengths(NormalizeSignal)));
				obj.TrialSignals.TrialSignal(vertcat(SignalIndex{:}))=vertcat(TrialSignal{:});
			end
			if any(NormalizeTags)
				TrialIndex=1:height(obj.Trials);
				[TrialTags,TrialIndex]=splitapply(@(TrialTags,TrialUID)UniExp.DataSet.TrialTagsResize(TrialTags,TrialUID,NormalizeTo),obj.Trials.TrialTags(NormalizeTags),TrialIndex(NormalizeTags)',findgroups(Heights(NormalizeTags)));
				obj.Trials.TrialTags(vertcat(TrialIndex{:}))=vertcat(TrialTags{:});
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
			BlockDesign=groupsummary(obj.Trials,"BlockUID",@(Stimuli)UniExp.DataSet.StimuliToDesign(Stimuli,DSTable),"Stimulus");
			BlockDesign(ismissing(BlockDesign.fun1_Stimulus),:)=[];
			[~,Index]=ismember(BlockDesign.BlockUID,obj.Blocks.BlockUID);
			obj.Blocks.Design(Index)=categorical(BlockDesign.fun1_Stimulus);
		end
	end
end