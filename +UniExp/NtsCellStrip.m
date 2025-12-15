%[text] 将不在所有NTS分组中均出现的细胞移除
%[text] 不同NTS分组中常常有不同的细胞群体，难以进行整合分析（如PCA等）。但是，可以将只在某些分组中出现的细胞移除，使得不同分组的细胞群体变为相同。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] GroupNts=UniExp.NtsCellStrip(GroupNts);
%[text] ```
%[text] ## 输入参数
%[text] GroupNts，NTS分组的结构体或元胞数组。如果是结构体，每个字段名将被视为分组名。每个分组是table，每行一个细胞-回合对组，包含以下列：
%[text] - TrialSignal(:,:)，第2维时间。
%[text] - CellUID(:,1)uint16，每个细胞的UID
%[text] - TrialUID(:,1)uint16，每个回合的UID \
%[text] ## 返回值
%[text] GroupNts，与输入不同的是，所有分组均包含相同的细胞
function GroupNts = NtsCellStrip(GroupNts)
HasGroupNames=isstruct(GroupNts);
if HasGroupNames
	GroupNames=fieldnames(GroupNts);
	GroupNts=struct2cell(GroupNts);
end
CellUID=cellfun(@(T)T.CellUID,GroupNts,UniformOutput=false);
CellUID=MATLAB.Ops.IntersectN(1,CellUID{:});
GroupNts=cellfun(@(T)T(ismember(T.CellUID,CellUID),:),GroupNts,UniformOutput=false);
if HasGroupNames
	GroupNts=cell2struct(GroupNts,GroupNames);
end

%[appendix]{"version":"1.0"}
%---
