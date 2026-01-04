%[text] 向Trials表添加Behavior列，指示行为
%[text] 此函数优先查找每Trial对应Block的EventLog，从中解析命中或错失行为；如果没有找到EventLog，将从Trials表的TrialTags中查找行为。查找到的行为将作为Behavior列加入Trials表；还会在Blocks表中添加一列Performance作为此Block所有Behavior的平均值。
%[text] 命中的行为将在Behavior列中记为1，错失记为0，无数据记为NaN。Performance将采用所有非NaN的Behavior数据计算。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] [LoggedBlocks,TaggedTrials,NullTrials]=obj.AddBehavior(Name=Value);
%[text] ```
%[text] ## 名称值参数
%[text] #### HitMiss=categorical(\["命中","错失"\])
%[text] 可选以下类型：
%[text] (1,2)categorical，命中和错失的Event标识，将据此从EventLog中识别命中和错失Behavior
%[text] table，对不同的Stimulus采用不同的命中和错失标识，每行一种Stimulus，包含以下列：
%[text] - Stimulus(:,1)categorical，刺激类型
%[text] - HitEvent(:,1)categorical，该刺激下等价于命中的事件
%[text] - MissEvent(:,1)categorical，该刺激下等价于错失的事件 \
%[text] table，对不同的Design采用不同的命中和错失标识，每行一种Design，包含以下列：
%[text] - Design(:,1)categorical，刺激类型。如果设为\<undefined\>，则不在表中的刺激类型都适用本行规则。
%[text] - HitEvent(:,1)categorical，该刺激下等价于命中的事件
%[text] - MissEvent(:,1)categorical，该刺激下等价于错失的事件 \
%[text] #### ResponseWindow(1,2)duration=seconds(\[3,4\])
%[text] 响应窗秒数，以回合开始为0时刻的响应窗时间段，默认取3~4秒之间。每个回合中，这段时间的TrialTags将作为识别行为的依据。此设置不影响对EventLog的识别。
%[text] #### TagChannel(0:1,0:1)string="CD2"
%[text] 标通道名称，TrialTags表的这一列将用作行为识别。可以指定为空，将跳过通过标通道解析行为的步骤。
%[text] #### TagCutoff(1,1)
%[text] 行为阈值，超过该阈值的Tag值将视为命中。如果不指定此参数，将以平均值+1倍标准差作为阈值。
%[text] #### EventLogCheckLevel(1,1)UniExp.Flags=UniExp.Flags.Warn
%[text] 当发现EventLog中的回合记录与Trials表中不一致时，采取的行动。可选：
%[text] Throw，抛出异常，终止程序
%[text] Warn，发出警告，继续程序
%[text] Ignore，忽略问题，继续程序
%[text] #### TrialStartEvents(:,1)categorical=categorical("回合开始")
%[text] 回合开始的事件标识。如果EventLog中包含此类标识，将根据此标识分割回合，这有助于识别没有行为记录的回合；否则将仅根据HitMiss生成行为。
%[text] #### BlockUIDs(:,1)uint16
%[text] 只为指定的BlockUID添加行为，其它BlockUID不变。如不指定，则应用于所有BlockUID。
%[text] ## 返回值
%[text] LoggedBlocks(:,1)uint16，指示哪些BlockUID找到了对应EventLog作为行为识别依据
%[text] TaggedTrials(:,1)uint16，指示哪些TrialUID找到了对应TrialTags作为行为识别依据，不包括那些已经找到EventLog的BlockUID
%[text] NullTrials(:,1)uint16，指示哪些TrialUID没有找到任何可用于行为识别的信息，其Behavior将置为NaN。
%[text] InconsistentBlocks(:,1)uint16，如果发现EventLog和已有记录不一致的警告，将在此返回值中列出那些BlockUID。
%[text] **See also** [UniExp.Flags](<matlab:edit UniExp.Flags>)
function [LoggedBlocks,TaggedTrials,NullTrials,InconsistentBlocks]=AddBehavior(obj,options)
arguments
	obj
	options.TrialStartEvents(:,1)categorical=categorical("回合开始")
	options.HitMiss=categorical(["命中","错失"])
	options.ResponseWindow=seconds([3,4])
	options.TagChannel="CD2"
	options.TagCutoff=NaN
	options.EventLogCheckLevel=UniExp.Flags.Warn
	options.BlockUIDs(:,1)uint16
end
import UniExp.Flags;
if ~any(obj.Trials.Properties.VariableNames=="Behavior")
	obj.Trials.Behavior(:)=NaN;
end
HasBlockUIDs=isfield(options,'BlockUIDs');
if HasBlockUIDs
	BlockUIDs=options.BlockUIDs;
else
	BlockUIDs=obj.Blocks.BlockUID;
end
BlockLogical=ismember(obj.Blocks.BlockUID,BlockUIDs);
if any(obj.Blocks.Properties.VariableNames=="EventLog")
	Clude=~cellfun(@(EL)isempty(EL)||isequaln(EL,missing),obj.Blocks.EventLog);
else
	Clude=false(height(obj.Blocks),1);
end
Clude=Clude&BlockLogical;
BlockIndex=find(Clude);
NumBlocks=numel(BlockIndex);
Success=true(NumBlocks,1);
warning off MATLAB:table:RowsAddedExistingVars
TabularHitMiss=istabular(options.HitMiss);
if TabularHitMiss
	ByStimulus=any(options.HitMiss.Properties.VariableNames=="Stimulus");
	if ByStimulus
		HitMissOperator=reshape(options.HitMiss{:,["HitEvent","MissEvent"]},1,[],2);%1×刺激类型×命中错失
		StimuliOperator=categorical(options.HitMiss.Stimulus)';%1×刺激类型
	else
		DefaultHitMiss=options.HitMiss{ismissing(options.HitMiss.Design),["HitEvent","MissEvent"]};
	end
end
for B=1:NumBlocks
	BI=BlockIndex(B);
	if ~any(obj.Blocks.EventLog{BI}.Properties.VariableNames=="Event")
		UniExp.Exception.EventLog_has_no_Event_columns.Throw(sprintf('Block %u\n尝试执行FixHistory。',obj.Blocks.BlockUID(BI)));
	end
	Events=categorical(obj.Blocks.EventLog{BI}.Event);
	obj.Blocks.EventLog{BI}.Event=Events;
	TrialStarts=find(ismember(Events,options.TrialStartEvents));
	BlockUID=obj.Blocks.BlockUID(BI);
	if TabularHitMiss
		if ByStimulus
			StimuliLogical=sortrows(obj.Trials(obj.Trials.BlockUID==BlockUID,["Stimulus","TrialIndex"]),"TrialIndex").Stimulus==StimuliOperator;%回合×刺激类型
		else
			Logical=options.HitMiss.Design==obj.Blocks.Design(BI);
			if any(Logical)
				HitMissOperator=options.HitMiss{Logical,["HitEvent","MissEvent"]};
			else
				HitMissOperator=DefaultHitMiss;
			end
		end
	end
	if isempty(TrialStarts)
		if TabularHitMiss
			if ByStimulus
				Behavior=NaN(height(StimuliLogical),1);
				HitMissLogical=Events==HitMissOperator;
				TrialIndex=1;
				SL=StimuliLogical(TrialIndex,:);
				for E=1:height(Events)
					HML=HitMissLogical(E,SL,:);
					if any(HML)
						Behavior(TrialIndex)=HML(1);
						TrialIndex=TrialIndex+1;
						SL=StimuliLogical(TrialIndex,:);
					end
				end
			else
				Behavior=Events==HitMissOperator;
				Behavior=Behavior(any(Behavior,2),1);
			end
		else
			Behavior=Events==options.HitMiss;
			Behavior=Behavior(any(Behavior,2),1);
		end
	else
		Behavior=NaN(size(TrialStarts));
		TrialStarts(end+1)=numel(Events)+1;
		if TabularHitMiss
			if~ByStimulus
				Operator=HitMissOperator;
			end
		else
			Operator=options.HitMiss;
		end
		for T=1:numel(TrialStarts)-1
			if TabularHitMiss&&ByStimulus
				Operator=HitMissOperator(:,StimuliLogical(T,:),:);
			end
			TrialBehavior=Events(TrialStarts(T)+1:TrialStarts(T+1)-1);
			if isempty(TrialBehavior)
				continue;
			end
			TrialBehavior=any(TrialBehavior==Operator,1);
			if TrialBehavior(1)
				Behavior(T)=1;
			elseif TrialBehavior(2)
				Behavior(T)=0;
			end
		end
	end
	NumTrials=numel(Behavior);
	Trials=obj.Trials(obj.Trials.BlockUID==BlockUID,["TrialUID","TrialIndex"]);
	switch height(Trials)
		case 0
			MaxID=height(obj.Trials);
			NewIndex=MaxID+1:MaxID+NumTrials;
			MaxID=max(obj.Trials.TrialUID);
			obj.Trials.TrialUID(NewIndex)=MaxID+1:MaxID+NumTrials;
			obj.Trials.TrialIndex(NewIndex)=1:NumTrials;
			obj.Trials.BlockUID(NewIndex)=BlockUID;
			obj.Trials.Behavior(NewIndex)=Behavior;
		case NumTrials
			[~,Index]=ismember(Trials.TrialUID,obj.Trials.TrialUID);
			obj.Trials.Behavior(Index)=Behavior(Trials.TrialIndex);
		otherwise
			switch options.EventLogCheckLevel
				case Flags.Throw
					UniExp.Exception.Number_of_trials_inconsistent_with_EventLog.Throw(sprintf('Block %u',BlockUID));
				case Flags.Warn
					UniExp.Exception.Number_of_trials_inconsistent_with_EventLog.Warn(sprintf('Block %u',BlockUID));
				case Flags.Ignore
				otherwise
					UniExp.Exception.Unexpected_EventLogCheckLevel_value.Throw;
			end
			Success(B)=false;
			continue;
	end
end
LoggedBlocks=obj.Blocks.BlockUID(BlockIndex(Success));
InconsistentBlocks=obj.Blocks.BlockUID(BlockIndex(~Success));
if isempty(options.TagChannel)
	TaggedTrials=uint16.empty(1,0);
	NullTrials=obj.Trials.TrialUID(ismissing(obj.Trials.Behavior));
else
	Clude(Clude)=Success;
	Clude=~Clude&BlockLogical;
	while true
		%这个循环纯粹用来break
		QueryTable=table;
		if any(Clude)
			QueryTable.GroupIndex=1;
			QueryTable.Behavior=NaN;
			QueryTable.BlockUID={obj.Blocks.BlockUID(Clude)};
		end
		%有的Block在CD2通道没有持续记录行为信号，因此不能认为有CD2就不应该有missing的行为
		if any(ismissing(obj.Trials.Behavior(ismember(obj.Trials.BlockUID,BlockUIDs))))
			if isempty(QueryTable)
				QueryTable.GroupIndex=1;
				QueryTable.Behavior=NaN;
				QueryTable.BlockUID={BlockUIDs};
			else
				QueryTable.GroupIndex(2)=1;
				QueryTable.Behavior(2)=NaN;
				QueryTable.BlockUID{2}=BlockUIDs;
			end
		end
		if ~isempty(QueryTable)
			try
				Trials=obj.TableQuery(["TrialUID","TrialTags","SeriesInterval"],QueryTable);
			catch ME
				if any(ME.identifier==["MATLAB:Lang:MatlabException:Column_not_found_in_tables","MATLAB:Exception:Column_not_found_in_tables"])
					NullTrials=obj.Trials.TrialUID(~ismember(obj.Trials.BlockUID,LoggedBlocks)|ismissing(obj.Trials.Behavior));
					TaggedTrials=[];
					break;
				else
					ME.rethrow;
				end
			end
			Trials=Trials{1};
			Trials(cellfun(@(T)isempty(T)||isequaln(T,missing),Trials.TrialTags),:)=[];
			if ~isempty(Trials)
				TaggedTrials=Trials.TrialUID;
				Trials.NumSamples=cellfun(@height,Trials.TrialTags);
				[Behavior,TrialUID]=splitapply(@(TrialUID,TrialTags,SeriesInterval)GetBehavior(TrialUID,TrialTags,SeriesInterval,options.ResponseWindow,options.TagChannel,options.TagCutoff),Trials(:,["TrialUID","TrialTags","SeriesInterval"]),findgroups(Trials(:,["SeriesInterval","NumSamples"])));
				[~,Index]=ismember(vertcat(TrialUID{:}),obj.Trials.TrialUID);
				obj.Trials.Behavior(Index)=[Behavior{:}];
			end
		else
			TaggedTrials=uint16.empty(0,1);
		end
		NullTrials=obj.Trials.TrialUID(ismissing(obj.Trials.Behavior));
		break;
	end
end
[Groups,BlockUID]=findgroups(obj.Trials.BlockUID);
Performance=splitapply(@(Behavior)mean(Behavior,'omitnan'),obj.Trials.Behavior,Groups);
[~,Index]=ismember(BlockUID,obj.Blocks.BlockUID);
obj.Blocks.Performance(Index)=Performance;
end
%%
function [Behavior,TrialUID]=GetBehavior(TrialUID,TrialTags,SeriesInterval,ResponseWindow,TagChannel,TagCutoff)
ResponseWindow=uint16(ResponseWindow/SeriesInterval(1));
TrialTags=cellfun(@(TT)TT.(TagChannel),TrialTags,UniformOutput=false);
TrialTags=[TrialTags{:}];
if isnan(TagCutoff)
	TagCutoff=mean2(TrialTags)+std2(TrialTags);
end
Behavior={any(TrialTags(ResponseWindow(1):ResponseWindow(2),:)>TagCutoff,1)};
TrialUID={TrialUID};
end

%[appendix]{"version":"1.0"}
%---
