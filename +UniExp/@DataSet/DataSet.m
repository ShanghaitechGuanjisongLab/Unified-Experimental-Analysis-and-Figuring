classdef DataSet<handle
	%UniExp数据集大类，包含多种处理、分析方法，是实现统一实验分析作图的通用数据集类型
	properties
		Mice		%主键Mouse，鼠名。本表其它列可选，但应当是与该鼠特定的信息，如实验范式等。
		DateTimes	%主键DateTime，实验进行的时间日期，本表其它列可选，但应当是与该次实验特定的信息，例如鼠、拍摄采样率、元数据等
		Blocks
		Trials
		Cells
		BlockSignals
		TrialSignals
		Version=UniExp.Version
	end
	methods(Static)
		Merged = Merge(Inputs,options)
		varargout=RenameMice(Old,New,varargin)
	end
	methods(Access=private,Static)
		function [BlockUID,RepeatIndex]=GetRepeatIndex(BlockUID,DateTime)
			BlockUID={BlockUID};
			RepeatIndex={findgroups(DateTime)};
		end
		function [TrialUID,Behavior]=GetBehavior(TrialUID,TrialTags,ResponseWindow)
			TrialUID={TrialUID};
			TrialTags=[TrialTags{:}];
			TrialTags=TrialTags(ResponseWindow(1):ResponseWindow(2),:);
			Behavior={any(TrialTags>mean2(TrialTags)+std2(TrialTags),1)'};
		end
	end
	methods
		function VT=ValidTableNames(obj)
			VT=properties(obj);
			VT=VT(cellfun(@(PN)istabular(obj.(PN)),VT));
		end
		function obj=DataSet(Struct)
			if nargin
				Fields=string(intersect(fieldnames(Struct),properties(obj)))';
				for F=Fields
					obj.(F)=Struct.(F);
				end
			end
		end
		function obj=MakeCopy(obj)
			obj=UniExp.DataSet(obj);
		end
		function RemoveCells(DataSet,CellUIDs)
			if istabular(DataSet.Cells)
				DataSet.Cells(ismember(DataSet.Cells.CellUID,CellUIDs),:)=[];
			end
			if istabular(DataSet.BlockSignals)
				DataSet.BlockSignals(ismember(DataSet.BlockSignals.CellUID,CellUIDs),:)=[];
			end
			if istabular(DataSet.TrialSignals)
				DataSet.TrialSignals(ismember(DataSet.TrialSignals.CellUID,CellUIDs),:)=[];
			end
		end
		function AddRepeatIndex(DataSet)
			Query=MATLAB.DataTypes.Select({DataSet.DateTimes,DataSet.Blocks},["BlockUID","DateTime","Mouse","Design"]);
			[BlockUID,RepeatIndex]=splitapply(@UniExp.DataSet.GetRepeatIndex,Query.BlockUID,Query.DateTime,findgroups(Query(:,["Mouse","Design"])));
			[~,Index]=ismember(vertcat(BlockUID{:}),DataSet.Blocks.BlockUID);
			DataSet.Blocks.RepeatIndex(Index)=vertcat(RepeatIndex{:});
		end
		function RemoveDateTimes(DataSet,DateTimes)
			HasTables=num2cell(ismember(["DateTimes","Blocks","Trials","BlockSignals","TrialSignals"],DataSet.ValidTableNames));
			[HasDateTimes,HasBlocks,HasTrials,HasBlockSignals,HasTrialSignals]=HasTables{:};
			if HasDateTimes
				DataSet.DateTimes(ismember(DataSet.DateTimes.DateTime,DateTimes),:)=[];
			end
			if HasBlocks
				Logical=ismember(DataSet.Blocks.DateTime,DateTimes);
				BlockUIDs=DataSet.Blocks.BlockUID(Logical);
				DataSet.Blocks(Logical,:)=[];
				if HasTrials
					Logical=ismember(DataSet.Trials.BlockUID,BlockUIDs);
					TrialUIDs=DataSet.Trials.TrialUID(Logical);
					DataSet.Trials(Logical,:)=[];
					if HasTrialSignals
						DataSet.TrialSignals(ismember(DataSet.TrialSignals.TrialUID,TrialUIDs),:)=[];
					end
				end
				if HasBlockSignals
					DataSet.BlockSignals(ismember(DataSet.BlockSignals.BlockUID,BlockUIDs),:)=[];
				end
			end
		end
		function AddBehaviorFromTrialTags(obj,ResponseWindow)
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
	end
end