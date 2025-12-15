%[text] 将不在所有NTATS分组中均出现的细胞移除
%[text] 不同NTATS分组中常常有不同的细胞群体，难以进行整合分析（如PCA等）。但是，可以将只在某些分组中出现的细胞移除，使得不同分组的细胞群体变为相同。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] GroupNtats=UniExp.NtatsCellStrip(GroupNtats);
%[text] ```
%[text] ## 输入参数
%[text] GroupNtats，NTATS分组的结构体或元胞数组。如果是结构体，每个字段名将被视为分组名。每个分组是table，每行一个细胞，包含以下列：
%[text] - NTATS(:,:)，第2维时间。
%[text] - CellUID(:,1)uint16，每个细胞的UID \
%[text] ## 返回值
%[text] GroupNtats，table，表的每一行对应一个细胞。包含以下列：
%[text] - NTATS(:,:,:)MATLAB.DataTypes.NDTable，第2维时间，第3维分组。如果输入GroupNtats是结构体，字段名将会作为第3维的索引。
%[text] - CellUID(:,1)uint16，每个细胞的UID，不在所有分组中均出现的细胞已移除 \
function GroupNtats = NtatsCellStrip(GroupNtats)
if istabular(GroupNtats)
	return;
end
HasGroupNames=isstruct(GroupNtats);
if HasGroupNames
	GroupNames=fieldnames(GroupNtats);
	GroupNtats=struct2cell(GroupNtats);
else
	GroupNames=[];
end
CellUID=cellfun(@(T)T.CellUID,GroupNtats,UniformOutput=false);
Index=cell(size(CellUID));
[CellUID,Index{:}]=MATLAB.Ops.IntersectN(1,CellUID{:});
GroupNtats=cellfun(@(T,I)T.NTATS(I,:),GroupNtats,Index,UniformOutput=false);
NTATS=MATLAB.DataTypes.NDTable(cat(3,GroupNtats{:}),table(["细胞";"时间";"分组"],{[];[];GroupNames},'VariableNames',["DimensionName","IndexNames"]));
GroupNtats=table(CellUID,NTATS);

%[appendix]{"version":"1.0"}
%---
