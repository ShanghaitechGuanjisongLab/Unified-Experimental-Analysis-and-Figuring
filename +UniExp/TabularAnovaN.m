%[text] 内置anovan的改版，将变量表作为分组输入
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] varargout=UniExp.TabularAnovaN(Y,GroupTable,Name=Value);
%[text] varargout=UniExp.TabularAnovaN(YColumn,GroupTable,Name=Value);
%[text] ```
%[text] ## 输入参数
%[text] #### Y
%[text] 同内置anovan的第一个位置参数
%[text] #### GroupTable table
%[text] 分组变量，每列一个变量，每行对应一个Y
%[text] #### YColumn
%[text] GroupTable中要作为Y值的列名或列序号
%[text] ### 名称值参数
%[text] #### Alpha(1,1)
%[text] 置信界限的显著性水平，指定为范围为0到1的标量值。
%[text] #### Continuous(1,:)string
%[text] 连续预测因子的指示器，表示哪些分组变量应被视为连续预测因子，而不是分类预测因子，指定为变量名字符串向量
%[text] #### Display(1,1)logical=true
%[text] 显示方差分析表的指示器，当设为false时，只返回输出参数，而不将标准ANOVA表显示为图形。
%[text] #### Model='linear'
%[text] 模型的类型，指定为以下选项之一：
%[text] - 'linear'，默认的线性模型只计算N个主要效应的零假设的p值。
%[text] - 'interaction'，交互模型计算N个主效应和$C\_N^2${"editStyle":"visual"}双因素相互作用。
%[text] - 'full'，完整模型计算所有水平上N个主要效应和相互作用的零假设的p值。
%[text] - (1,1)uint8，对于k的整数值，(k≤N)为模型类型，计算到第k层的所有交互级别。例如，值3表示主效应加上两因素和三因素相互作用。k=1和k=2分别相当于线性和交互模型。值k=N相当于完整模型。
%[text] - tabular，每一列都是(:,1)logical的表，列名是变量名，必须包含所有变量。为了更精确地控制ANOVA计算的主项和交互项，您可以指定一个表格，其中包含要包含在ANOVA模型中的每个主项或交互项的一行。每一行用N个true和false的定义一项，指示每个变量是否包含在项中。 \
%[text] #### Nested tabular
%[text] 行名和列名都是变量名，但不必包含所有变量。每一列都是(:,1)logical，指示组变量之间的嵌套关系。例如，如果变量i嵌套在变量j中，则Nested{i,j}=true。不能在连续变量中指定嵌套。
%[text] #### Random(1,:)string
%[text] 随机变量的指示器，表示哪些分组变量是随机的，指定为变量名字符串向量。默认情况下，将所有分组变量视为固定的。如果交互项中的任何变量是随机的，则将交互项视为随机的。
%[text] #### SSType(1,1)
%[text] 平方和的类型，指定为以下选项之一：
%[text] - 1，类型Ⅰ平方和。通过将该项添加到已经包含在它之前列出的项的拟合中而得到的残差平方和的减少。
%[text] - 2，类型Ⅱ平方和。通过将该项添加到由不包含该项的所有其他项组成的模型中而得到的残差平方和的减少。
%[text] - 3，类型Ⅲ平方和。通过将该项添加到包含所有其他项的模型中而获得的残差平方和的减少，但其效果受制于通常的“sigma限制”，使模型可估计。
%[text] - 'h'，层次模型。类似于类型Ⅱ，但使用连续和分类因素来确定项的层次结构。 \
%[text] 任何项的平方和都是通过比较两个模型来确定的。对于包含主效应但不包含相互作用的模型，sstype的值仅影响非平衡数据的计算。
%[text] #### Comparison table
%[text] 要额外计算多重比较P值的对组。每行一个比较对组，每列是一个变量，列名就是变量名（不允许使用PValue作为列名），列值是(:,2)，在第2维上排列对组中该变量的两个值。
%[text] ## 返回值
%[text] 如果指定了Comparison参数，第一个返回值是table，在输入的Comparison基础上加一列PValue，表示每个比较对组的多重比较P值。后续返回值同内置anovan。
%[text] 如果未指定Comparison参数，则返回值同内置anovan。
%[text] **See also** [anovan](<matlab:doc anovan>)
function varargout = TabularAnovaN(Y,GroupTable,AnovanOptions,MultcompareOptions)
arguments
	Y
	GroupTable
	AnovanOptions.Alpha
	AnovanOptions.Continuous
	AnovanOptions.Display
	AnovanOptions.Model
	AnovanOptions.Nested
	AnovanOptions.Random
	AnovanOptions.SSType
	MultcompareOptions.Comparison
end
if isreal(Y)
	if isscalar(Y)
		try
			YColumn=GroupTable{:,Y};
			GroupTable(:,Y)=[];
			Y=YColumn;
		catch
		end
	end
else
	YColumn=GroupTable.(Y);
	GroupTable.(Y)=[];
	Y=YColumn;
end
VarNames=GroupTable.Properties.VariableNames;
NumVariables=width(GroupTable);
if isfield(AnovanOptions,'Continuous')
	[~,AnovanOptions.Continuous]=ismember(AnovanOptions.Continuous,VarNames);
end
if isfield(AnovanOptions,'Display')
	if AnovanOptions.Display
		AnovanOptions.Display='on';
	else
		AnovanOptions.Display='off';
	end
end
if isfield(AnovanOptions,'Model')&&istabular(AnovanOptions.Model)
	[~,Index]=ismember(VarNames,AnovanOptions.Model.Properties.VariableNames);
	AnovanOptions.Model=double(AnovanOptions.Model{:,Index});
end
if isfield(AnovanOptions,'Nested')
	Nested=AnovanOptions.Nested;
	AnovanOptions.Nested=false(NumVariables);
	[RowExist,RowIndex]=ismember(VarNames,Nested.Properties.RowNames);
	[ColumnExist,ColumnIndex]=ismember(VarNames,Nested.Properties.VariableNames);
	AnovanOptions.Nested(RowIndex(RowExist),ColumnIndex(ColumnExist))=Nested{:,:};
end
if isfield(AnovanOptions,'Random')
	[~,AnovanOptions.Random]=ismember(AnovanOptions.Random,VarNames);
end
AnovanOptions=[lower(fieldnames(AnovanOptions)),struct2cell(AnovanOptions)]';
Groups=cell(1,NumVariables);
for V=1:NumVariables
	Groups{V}=GroupTable{:,V};
end
[varargout{1:clip(nargout,3,4)}]=anovan(Y,Groups,AnovanOptions{:},varnames=VarNames,display='off');
if isfield(MultcompareOptions,'Comparison')
	Comparison=MultcompareOptions.Comparison;
	VariableNames=Comparison.Properties.VariableNames;
	[~,Dimensions]=ismember(VariableNames,varargout{3}.varnames);
	[ComparisonMatrix,~,~,Groups]=multcompare(varargout{3},Dimension=Dimensions);
	Groups=split(Groups,"="|",");
	Groups=cell2table(Groups(:,2:2:end),VariableNames=Groups(1,1:2:end));
	[ComparisonA,ComparisonB]=deal(table);
	for C=1:width(Comparison)
		ComparisonA.(VariableNames{C})=Comparison{:,C}(:,1);
		ComparisonB.(VariableNames{C})=Comparison{:,C}(:,2);
	end
	[~,ComparisonA]=ismember(ComparisonA,Groups);
	[~,ComparisonB]=ismember(ComparisonB,Groups);
	[~,Groups]=ismember([ComparisonA,ComparisonB],ComparisonMatrix(:,1:2),'rows');
	Comparison.PValue=ComparisonMatrix(Groups,6);
	varargout=[{Comparison},varargout];
end

%[appendix]{"version":"1.0"}
%---
