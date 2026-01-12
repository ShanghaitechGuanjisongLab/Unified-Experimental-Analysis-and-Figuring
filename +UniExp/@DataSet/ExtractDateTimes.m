%[text] 从数据集中提取一些日期时间，形成一个新的数据集
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] objB=objA.ExtractDateTimes(DateTimes);
%[text] ```
%[text] ## 输入参数
%[text] DateTimes(:,1)datetime，要提取的日期时间。例如`datetime('2022-11-01 10:33:16')`
%[text] ## 返回值
%[text] objB(1,1)UniExp.DataSet，包含指定日期时间的一个新数据集
%[text] **See also** [UniExp.DataSet.ExtractMice](<matlab:helpwin UniExp.DataSet.ExtractMice>)
function objB=ExtractDateTimes(objA,DateTimes)
arguments
    objA
    %使用字符串进行日期比较，避免出现字符串一样但日期时间不一样的诡异情形
    DateTimes(:,1)string
end
objB=UniExp.DataSet;
if~isempty(objA.DateTimes)
	objB.DateTimes=objA.DateTimes(ismember(string(objA.DateTimes.DateTime),DateTimes),:);
	if~isempty(objA.Blocks)
		objB.Blocks=objA.Blocks(ismember(string(objA.Blocks.DateTime),DateTimes),:);
		if~isempty(objA.Trials)
			objB.Trials=objA.Trials(ismember(objA.Trials.BlockUID,objB.Blocks.BlockUID),:);
		end
	end
	if~isempty(objA.Mice)
		objB.Mice=objA.Mice(ismember(objA.Mice.Mouse,objB.DateTimes.Mouse),:);
	end
	if~isempty(objA.Cells)
		objB.Cells=objA.Cells(ismember(objA.Cells.Mouse,obj.DateTimes.Mouse),:);
	end
	if~isempty(objA.BlockSignals)
		objB.BlockSignals=objA.BlockSignals(ismember(objA.BlockSignals.BlockUID,objB.Blocks.BlockUID)&ismember(objA.BlockSignals.CellUID,objB.Cells.CellUID),:);
	end
	if~isempty(objA.TrialSignals)
		objB.TrialSignals=objA.TrialSignals(ismember(objA.TrialSignals.TrialUID,objB.Trials.TrialUID)&ismember(objA.TrialSignals.CellUID,objB.Cells.CellUID),:);
	end
	if~isempty(objA.Manipulations)
		objB.Manipulations=objA.Manipulations(ismember(objA.Manipulations.Mouse,obj.DateTimes.Mouse),:);
	end
end
end

%[appendix]{"version":"1.0"}
%---
