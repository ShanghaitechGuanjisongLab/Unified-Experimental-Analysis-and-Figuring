%[text] 从数据集中提取一些日期时间，形成一个新的数据集
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] objB=objA.ExtractDateTimes(DateTimes);
%[text] ```
%[text] ## 输入参数
%[text] DateTimes(:,1)datetime，要提取的日期时间。例如`datetime('2022-11-01 10:33:16')`
%[text] ## 返回值
%[text] objB(1,1)UniExp.DataSet，包含指定日期时间的一个新数据集
function objB=ExtractDateTimes(objA,DateTimes)
arguments
    objA
    %使用字符串进行日期比较，避免出现字符串一样但日期时间不一样的诡异情形
    DateTimes(:,1)string
end
objB=UniExp.DataSet;
HasTables=ismember(["DateTimes","Blocks","Trials","BlockSignals","TrialSignals","Cells","Mice"],objA.ValidTableNames);
if HasTables(1)
    Logical=ismember(string(objA.DateTimes.DateTime),DateTimes);
    objB.DateTimes=objA.DateTimes(Logical,:);
    if HasTables(2)
        Logical=ismember(string(objA.Blocks.DateTime),DateTimes);
        BlockUIDs=objA.Blocks.BlockUID(Logical);
        objB.Blocks=objA.Blocks(Logical,:);
        if HasTables(3)
            Logical=ismember(objA.Trials.BlockUID,BlockUIDs);
            TrialUIDs=objA.Trials.TrialUID(Logical);
            objB.Trials=objA.Trials(Logical,:);
            if HasTables(5)
                objB.TrialSignals=objA.TrialSignals(ismember(objA.TrialSignals.TrialUID,TrialUIDs),:);
            end
        end
        if HasTables(4)
            objB.BlockSignals=objA.BlockSignals(ismember(objA.BlockSignals.BlockUID,BlockUIDs),:);
        end
    end
end
if HasTables(6)
    CellUID=objA.Cells.CellUID([]);
    if HasTables(4)
        CellUID=union(CellUID,objB.BlockSignals.CellUID);
    end
    if HasTables(5)
        CellUID=union(CellUID,objB.TrialSignals.CellUID);
    end
    objB.Cells=objA.Cells(ismember(objA.Cells.CellUID,CellUID),:);
end
if HasTables(7)
    ExtractMice=objB.DateTimes.Mouse;
    if HasTables(6)
        ExtractMice=union(ExtractMice,objB.Cells.Mouse);
    end
    objB.Mice=objA.Mice(ismember(objA.Mice.Mouse,ExtractMice),:);
end
end

%[appendix]{"version":"1.0"}
%---
