%[text] 合并同一只鼠非常接近的两个日期时间
%[text] 拍双光子时，自动生成的日期时间和手动记录的日期时间可能存在误差，导致同一次实验变成两条记录。此方法根据指定的容差将那些记录合并到较早的那个日期时间。
%[text] 如果两个日期时间之间存在冲突的非空缺值，将仅保留其中之一，具体保留哪一个是不确定的。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] Merged=obj.MergeVeryCloseDateTimes;
%[text] %将同一只鼠误差不超过1分钟的日期时间合并到较早的一个
%[text] 
%[text] Merged=obj.MergeVeryCloseDateTimes(Tolerance);
%[text] %将同一只鼠误差不超过指定时长的日期时间合并到较早的一个
%[text] ```
%[text] ## 输入参数
%[text] Tolerance(1,1)duration=minutes(2)，要合并的日期时间的最大时差
%[text] ## 返回值
%[text] Merged(:,2)duration，被合并的日期时间对，每行一对，合并后的日期时间是两者中较早的那个。
function Merged=MergeVeryCloseDateTimes(obj,Tolerance)
arguments
	obj
	Tolerance=minutes(2)
end
obj.DateTimes=sortrows(obj.DateTimes,["Mouse","DateTime"]);
ToMerge=find(obj.DateTimes.Mouse(2:end)==obj.DateTimes.Mouse(1:end-1)&obj.DateTimes.DateTime(2:end)-obj.DateTimes.DateTime(1:end-1)<=Tolerance);
ToMerge(:,2)=ToMerge+1;
Merged=obj.DateTimes.DateTime(ToMerge);
if isempty(Merged)
	return;
end
if iscolumn(Merged)
	Merged=Merged.';
end
obj.DateTimes.DateTime(ToMerge(:,2))=obj.DateTimes.DateTime(ToMerge(:,1));
lastwarn('','UniExp:Exception:Placeholder');
obj.DateTimes=MATLAB.DataFun.MergeDuplicateKeys(obj.DateTimes,"DateTime",@UpdateMerge);
ConflictDetail("DateTimes");
[Exist,Index]=ismember(obj.Blocks.DateTime,Merged(:,2));
obj.Blocks.DateTime(Exist)=Merged(Index(Exist),1);
obj.Blocks=sortrows(obj.Blocks,["DateTime","BlockIndex"]);
UIDMap=[obj.Blocks.BlockUID,obj.Blocks.BlockUID(KeyTableMapIndex(obj.Blocks(:,["DateTime","BlockIndex"])))];
obj.Blocks.BlockUID=UIDMap(:,2);
lastwarn('','UniExp:Exception:Placeholder');
obj.Blocks=MATLAB.DataFun.MergeDuplicateKeys(obj.Blocks,["DateTime","BlockIndex","BlockUID"],@(T)UpdateMerge(T,true));
ConflictDetail("Blocks");
if~isempty(obj.BlockSignals)
	[Exist,Index]=ismember(obj.BlockSignals.BlockUID,UIDMap(:,1));
	obj.BlockSignals.BlockUID(Exist)=UIDMap(Index(Exist),2);
	lastwarn('','UniExp:Exception:Placeholder');
	obj.BlockSignals=MATLAB.DataFun.MergeDuplicateKeys(obj.BlockSignals,["BlockUID","CellUID"],@(T)UpdateMerge(T,true));
	ConflictDetail("BlockSignals");
end
if~isempty(obj.Trials)
	[Exist,Index]=ismember(obj.Trials.BlockUID,UIDMap(:,1));
	obj.Trials.BlockUID(Exist)=UIDMap(Index(Exist),2);
	obj.Trials=sortrows(obj.Trials,["BlockUID","TrialIndex"]);
	UIDMap=[obj.Trials.TrialUID,obj.Trials.TrialUID(KeyTableMapIndex(obj.Trials(:,["BlockUID","TrialIndex"])))];
	obj.Trials.TrialUID=UIDMap(:,2);
	lastwarn('','UniExp:Exception:Placeholder');
	obj.Trials=MATLAB.DataFun.MergeDuplicateKeys(obj.Trials,["BlockUID","TrialIndex","TrialUID"],@(T)UpdateMerge(T,true));
	ConflictDetail("Trials");
end
if~isempty(obj.TrialSignals)
	[Exist,Index]=ismember(obj.TrialSignals.TrialUID,UIDMap(:,1));
	obj.TrialSignals.TrialUID(Exist)=UIDMap(Index(Exist),2);
	lastwarn('','UniExp:Exception:Placeholder');
	obj.TrialSignals=MATLAB.DataFun.MergeDuplicateKeys(obj.TrialSignals,["TrialUID","CellUID"],@(T)UpdateMerge(T,true));
	ConflictDetail("TrialSignals");
end
end
function KTMI=KeyTableMapIndex(KTMI)
KTMI=findgroups(KTMI);
KTMI=[find(KTMI(1:end-1)~=KTMI(2:end));numel(KTMI)];
KTMI=repelem(KTMI,[KTMI(1);diff(KTMI)]);
end
function ConflictDetail(TableName)
[~,WarnID]=lastwarn;
if WarnID=="UniExp:Exception:UpdateMerge_found_conflict_values"
	UniExp.Exception.UpdateMerge_found_conflict_values.Warn("表"+TableName);
end
end

%[appendix]{"version":"1.0"}
%---
