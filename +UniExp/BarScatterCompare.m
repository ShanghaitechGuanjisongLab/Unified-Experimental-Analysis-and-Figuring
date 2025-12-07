%[text] 用误差条形图和散点对两组采样数据进行比较，并显示方差分析多重比较的P值
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] import UniExp.BarScatterCompare
%[text] 
%[text] BarScatterCompare(Data);
%[text] %对两组数据采样点作两个条形进行比较，显示误差条、样本点
%[text] 
%[text] BarScatterCompare(Data,ShowScatter);
%[text] %额外指定是否要显示采样散点
%[text] 
%[text] BarScatterCompare(___,CompareGroup);
%[text] %与上述任意语法组合使用，额外指定要多重比较计算P值的分组对
%[text] 
%[text] BarScatterCompare(___,Colors);
%[text] %与上述任意语法组合使用，额外指定条形和散点的颜色
%[text] 
%[text] BarScatterCompare(___,Ax);
%[text] %与上述任意语法组合使用，额外指定绘图目标坐标区
%[text] 
%[text] BarScatterCompare(___,Name=Value);
%[text] %与上述任意语法组合使用，额外指定名称值参数
%[text] 
%[text] [___,Optional]=BarScatterCompare(___);
%[text] %与上述任意语法组合使用，返回可选的多重比较和图形对象
%[text] 
%[text] [___,PLines]=BarScatterCompare(___);
%[text] %与上述任意语法组合使用，返回P值线对象
%[text] ```
%[text] ## 示例
%[text] ```matlabCodeExample
%[text] figure;
%[text] load('+UniExp\BarScatterCompare.mat');
%[text] tiledlayout('flow',TileSpacing='tight',Padding='tight');
%[text] MATLAB.Graphics.FigureAspectRatio(8,5,1/3);
%[text] Ax=nexttile;
%[text] UniExp.BarScatterCompare(Days);
%[text] title('Days spent to learn');
%[text] nexttile;
%[text] UniExp.BarScatterCompare(array2table([Days{:}],VariableNames=CompareGroup.GroupPair),CompareGroup);
%[text] ```
%[text] ## ![](text:image:6ba7)
%[text] ## 输入参数
%[text] Data，分组采样数据，可以是：
%[text] - 实数矩阵，每组一列。如果显示散点，同一行的散点将被匹配连接起来。每组的条形下方将用数字标识组序数。
%[text] - table，可以是：
%[text] -    - 每组一列。如果显示散点，同一行的散点将被匹配连接起来。每组的条形下方将用表列名标识组名。
%[text] -    - 二维分组，维度顺序参考内置bar函数，行名和列名对应该维度上的组名。每列都是(:,1)cell，元胞内是(:,1)，该组的所有样本。如果使用此语法，将取行名作为X轴，列名作为图例。如果要指定CompareGroup，通常还应当指定table的DimensionNames。
%[text] - (1,:)cell，每组一个元胞，元胞里是实数列向量。如果显示散点，将不会匹配连接，而是均匀分布在各个高度上。每组的条形下方将用数字标识组序数。
%[text] - (1,1)struct，每组一个字段，字段值是实数列向量。如果显示散点，将不会匹配连接，而是均匀分布在各个高度上。每组的条形下方将用字段名标识组名。 \
%[text] ShowScatter(1,1)logical=true，是否显示散点。若设为false，不能输出ScatterLines。
%[text] CompareGroup table=table.empty，分组配对比较表，标识要将哪些分组配对计算P值，每行一对。默认不显示P值。
%[text] - GroupPair(:,2)，必需，为每个比较配对指定要比较的两个分组。类型可以是：
%[text] -    - 如果Data使用table二维分组语法，此列必须是table，两列名对应Data的DimensionNames，每列内又是(:,2)，每行是该比较对组在该维度上的两个组名。此语法与TabularAnovaN的Comparison参数语法相同。
%[text] -    - 如果Data中仅指定了一维组名，GroupPair可以指定为字符串或组序数
%[text] -    - 如果Data未指定任何组名，GroupPair只能为组序数。
%[text] - PLineOffset(:,1)，可选。为每个配对计算的P值将显示在图上，有时这些显示字符可能发生重叠。使用此参数，为每个比较配对指定一个向上偏移值，手动垫高特定配对的P值显示位置，避免与其它P值重叠。数值单位与Y轴一致。 \
%[text] Ax(1,1)matlab.graphics.axis.Axes=gca，绘图目标坐标区
%[text] #### Colors(:,3)table
%[text] 必须包含以下列：
%[text] - R(:,1)double，红色通道
%[text] - G(:,1)double，绿色通道
%[text] - B(:,1)double，蓝色通道 \
%[text] 可选包含具有以下名称的行：
%[text] - Bar，可以用此行指示填充条形的颜色，默认为白色。如果Data采用二维分组语法，此行设置无效。
%[text] - ErrorBar，指示误差帽的颜色，默认为黑色
%[text] - Scatter，指示散点的颜色，默认为\[1,0,1\]
%[text] - Link，指示散点连接线的颜色，默认与散点颜色相同
%[text] - 如果Data采用二维分组语法，还可以将行名指定为第二维度的分组名，以对不同的第二维分组使用不同的颜色。未指定的分组将自动分配颜色。 \
%[text] ### 名称值参数
%[text] AsteriskThreshold(1,1)=0，小于该阈值的P不会显示值，而是标记为星号\*
%[text] CapSize(1,1)=0.5，误差帽的宽度，相对于条形，例如设为1表示和条形等宽
%[text] ## 返回值
%[text] P(1,1)double，所有组的总体P值
%[text] Optional(1,1)struct，可选输出，可选包含以下字段：
%[text] - MultiCompare(:,2)table，如果CompareGroup不为空，则此输出对应CompareGroup，每行一个分组对，包含以下列：
%[text] -    - GroupPair(:,2)，保留CompareGroup的同名列不变
%[text] -    - PValue，该分组对两两比较的P值
%[text] - ScatterLines(:,1)，散点和连接线图形对象。如果Data是实数或一维分组table，返回matlab.graphics.chart.primitive.Line；如果Data是cell或struct或二维分组table，返回matlab.graphics.chart.primitive.Scatter；如果ShowScatter设为false，不输出此返回值。 \
%[text] PLines(:,2)matlab.graphics.Graphics，P值线图形对象，一行一个P值线。第1列是横线，第2列是文本。
%[text] **See also** [anova1](<matlab:doc anova1>) [multcompare](<matlab:doc multcompare>) [matlab.graphics.chart.primitive.Line](<matlab:doc matlab.graphics.chart.primitive.Line>) [matlab.graphics.chart.primitive.Scatter](<matlab:doc matlab.graphics.chart.primitive.Scatter>) [matlab.graphics.chart.primitive.errorbar](<matlab:doc matlab.graphics.chart.primitive.errorbar>) [bar](<matlab:doc bar>) [UniExp.TabularAnovaN](<matlab:doc UniExp.TabularAnovaN>)
function [P,Optional,PLines]=BarScatterCompare(Data,varargin)
import UniExp.Flags
ShowScatter=true;
CompareGroup=table.empty;
Colors=table.empty;
Ax={};
AsteriskThreshold=0;
CapSize=0.5;
for V=1:numel(varargin)
	Arg=varargin{V};
	if islogical(Arg)
		ShowScatter=Arg;
	elseif isa(Arg,'matlab.graphics.axis.Axes')
		Ax={Arg};
	elseif istabular(Arg)
		if width(Arg)<3
			CompareGroup=Arg;
		else
			Colors=Arg;
		end
	else
		for NV=V:2:numel(varargin)
			switch varargin{NV}
				case "AsteriskThreshold"
					AsteriskThreshold=varargin{NV+1};
				case "CapSize"
					CapSize=varargin{NV+1};
				otherwise
					UniExp.Exception.Parameter_cannot_be_parsed.Throw(varargin{NV});
			end
		end
		break;
	end
end
Table2D=false;
if isreal(Data)
	DataType=Flags.Real;
	[Mean,Sem]=MATLAB.DataFun.MeanSem(Data,1);
	[NumRepeats,NumGroups]=size(Data);
	HasGroupNames=false;
elseif istabular(Data)
	if iscell(Data{1,1})
		DataType=Flags.Table2D;
		Table2D=true;
		[Mean,Sem]=cellfun(@MATLAB.DataFun.MeanSem,Data{:,:});
		NumGroups=height(Data);
		HasGroupNames=true;
		GroupNames=Data.Properties.RowNames;
	else
		DataType=Flags.Table;
		[Mean,Sem]=MATLAB.DataFun.MeanSem(Data{:,:},1);
		[NumRepeats,NumGroups]=size(Data);
		HasGroupNames=true;
		GroupNames=Data.Properties.VariableNames;
	end
elseif iscell(Data)
	DataType=Flags.Cell;
	[Mean,Sem]=cellfun(@MATLAB.DataFun.MeanSem,Data);
	NumGroups=numel(Data);
	HasGroupNames=false;
elseif isstruct(Data)
	DataType=Flags.Struct;
	[Mean,Sem]=structfun(@MATLAB.DataFun.MeanSem,Data);
	NumGroups=numel(Mean);
	HasGroupNames=true;
	GroupNames=fieldnames(Data);
end
BarPositive=Mean>0;
BarZero=Mean==0;
BarNegative=Mean<0;
if~any(BarPositive)
	BarNegative=BarNegative|BarZero;
elseif~any(BarNegative)
	BarPositive=BarPositive|BarZero;
end
LackRows=~ismember(["ErrorBar","Scatter","Link"],Colors.Properties.RowNames);
persistent RGB
if isempty(RGB)
	RGB=["R","G","B"];
end
if LackRows(1)
	Colors{"ErrorBar",RGB}=[0,0,0];
end
if LackRows(2)&&ShowScatter
	Colors{"Scatter",RGB}=[1,0,1];
end
if LackRows(3)&&ShowScatter
	Colors("Link",:)=Colors("Scatter",:);
end
if Table2D
	HasRows=ismember(Data.Properties.VariableNames,Colors.Properties.RowNames);
	Colors{Data.Properties.VariableNames(~HasRows),RGB}=GlobalOptimization.ColorAllocate(nnz(~HasRows),Colors{[Colors.Properties.RowNames(HasRows);intersect(["Scatter","Link"],Colors.Properties.RowNames)],RGB});
	CData=Colors{Data.Properties.VariableNames,["R","G","B"]};
elseif any(Colors.Properties.RowNames=="Bar")
	CData=Colors{"Bar",["R","G","B"]};
else
	CData=[1,1,1];
end
Bars=bar(Ax{:},Mean,CData=CData,FaceColor='flat',LineWidth=2);%FaceColor默认不是flat，而是一个自动分配的颜色
if Table2D
	legend(Bars,Data.Properties.VariableNames,Location=MATLAB.Graphics.OptimizedLegendLocation(Bars));
end
if isempty(Ax)
	Ax=gca;
else
	Ax=Ax{1};
end
Ax.TickLabelInterpreter='none';
XTickGroups=1:NumGroups;
if HasGroupNames
	xticks(Ax,XTickGroups);
	xticklabels(Ax,GroupNames);
end
HoldState=ishold;
hold(Ax,'on');
AxUnits=Ax.Units;
Ax.Units='points';
CommonArguments={'Color',Colors{"ErrorBar",["R","G","B"]},'LineStyle','none','LineWidth',2,'CapSize',Ax.Position(3)*Bars.BarWidth/diff(xlim)*CapSize};
Ax.Units=AxUnits;
Xs=[Bars.XEndPoints];
ErrorBars=table;
if any(BarPositive)
	ErrorBars.Object(BarPositive)=errorbar(Ax,Xs(BarPositive),Mean(BarPositive),[],Sem(BarPositive),CommonArguments{:});
	ErrorBars.Index(BarPositive)=1:sum(BarPositive);
end
if any(BarNegative)
	ErrorBars.Object(BarNegative)=errorbar(Ax,Xs(BarNegative),Mean(BarNegative),Sem(BarNegative),[],CommonArguments{:});
	ErrorBars.Index(BarNegative)=1:sum(BarNegative);
end
if any(BarZero)
	ErrorBars.Object(BarZero)=errorbar(Ax,Xs(BarZero),Mean(BarZero),Sem(BarZero),CommonArguments{:});
	ErrorBars.Index(BarZero)=1:sum(BarZero);
end
Optional=struct;
if ShowScatter
	ScatterColor=Colors{"Scatter",["R","G","B"]};
	switch DataType
		case Flags.Real
			Optional.ScatterLines=plot(Ax,repmat(Xs.',1,NumRepeats),Data','-o',Color=Colors{"Link",["R","G","B"]},MarkerFaceColor=ScatterColor);
		case Flags.Table
			Optional.ScatterLines=plot(Ax,repmat(Xs.',1,NumRepeats),Data{:,:}','-o',Color=Colors{"Link",["R","G","B"]},MarkerFaceColor=ScatterColor);
		case Flags.Cell
			Optional.ScatterLines=swarmchart(Ax,repelem(1:numel(Data),cellfun(@numel,Data)),vertcat(Data{:}),[],ScatterColor,'filled');
		case Flags.Struct
			DataCell=struct2cell(Data);
			Optional.ScatterLines=swarmchart(Ax,repelem(1:numel(DataCell),cellfun(@numel,DataCell)),vertcat(DataCell{:}),[],ScatterColor,'filled');
		case Flags.Table2D
			Optional.ScatterLines=swarmchart(Ax,repelem(1:numel(Data{:,:}),cellfun(@numel,Data{:,:})),vertcat(Data{:,:}{:}),[],ScatterColor,'filled');
	end
end
NoCompareGroups=isempty(CompareGroup);
if nargout||~NoCompareGroups
	switch DataType
		case Flags.Real
			if isduration(Data)
				Data=seconds(Data);
			end
			[P,~,Stats]=anova1(Data,[],'off');
		case Flags.Table
			Data=Data{:,:}(:);
			if isduration(Data)
				Data=seconds(Data);
			end
			[P,~,Stats]=anova1(Data,repelem(GroupNames,1,NumRepeats),'off');
		case Flags.Cell
			Groups=arrayfun(@(Group,G)repmat(G,numel(Group{1}),1),Data,XTickGroups,UniformOutput=false);
			Data=vertcat(Data{:});
			if isduration(Data)
				Data=seconds(Data);
			end
			[P,~,Stats]=anova1(Data,vertcat(Groups{:}),'off');
		case Flags.Struct
			Y=struct2cell(Data);
			Groups=arrayfun(@(Group,Name)repmat(Name,numel(Group{1}),1),Y,GroupNames,UniformOutput=false);
			Y=vertcat(Y{:});
			if isduration(Y)
				Y=seconds(Y);
			end
			[P,~,Stats]=anova1(Y,vertcat(Groups{:}),'off');
		case Flags.Table2D
			[Columns,Rows]=meshgrid(Data.Properties.VariableNames,Data.Properties.RowNames);
			if NoCompareGroups
				P=UniExp.TabularAnovaN(vertcat(Data{:,:}{:}),table(Columns{:},Rows{:},'VariableNames',Data.Properties.DimensionNames),Display=false,Model='full');
			else
				[Optional.MultiCompare,P]=UniExp.TabularAnovaN(vertcat(Data{:,:}{:}),table(Columns{:},Rows{:},'VariableNames',Data.Properties.DimensionNames),Display=false,Model='full',Comparison=CompareGroup.GroupPair);
			end
	end
end
if NoCompareGroups
	if nargout>1&&~Table2D
		if HasGroupNames
			MultiCompare=table('Size',[0,2],'VariableTypes',["string","double"],'VariableNames',["GroupPair","PValue"]);
		else
			MultiCompare=table('Size',[0,2],'VariableTypes',["uint8","double"],'VariableNames',["GroupPair","PValue"]);
		end
		MultiCompare.Properties.DimensionNames(1)="分组对";
	end
	PLines=gobjects(0,2);
else
	if Table2D
		Descriptors=CompareGroup.GroupPair(:,Data.DimensionNames);
		ErrorBars.Object=array2table(reshape(ErrorBars.Object,size(Data)),VariableNames=Data.Properties.VariableNames,RowNames=Data.Properties.RowNames);
		ErrorBars.Index=array2table(reshape(ErrorBars.Index,size(Data)),VariableNames=Data.Properties.VariableNames,RowNames=Data.Properties.RowNames);
		for P=1:height(Descriptors)
			Descriptors.ObjectA(P)=ErrorBars.Object{Descriptors{P,1}(P,1),Descriptors{P,2}(P,1)};
			Descriptors.ObjectB(P)=ErrorBars.Object{Descriptors{P,1}(P,2),Descriptors{P,2}(P,2)};
			Descriptors.IndexA(P)=ErrorBars.Index{Descriptors{P,1}(P,1),Descriptors{P,2}(P,1)};
			Descriptors.IndexB(P)=ErrorBars.Index{Descriptors{P,1}(P,2),Descriptors{P,2}(P,2)};
		end
	else
		if HasGroupNames
			[MultiCompare,~,~,CompareGN]=multcompare(Stats,Display='off');
			if isreal(CompareGroup.GroupPair)
				NumericGroupPair=CompareGroup.GroupPair;
				GroupPair=GroupNames(NumericGroupPair);
			else
				GroupPair=CompareGroup.GroupPair;
				[~,NumericGroupPair]=ismember(GroupPair,GroupNames);
			end
			[~,GroupRow]=ismember(GroupPair,CompareGN);
			Unfound=GroupPair(~GroupRow);
			if~isempty(Unfound)
				UniExp.Exception.Group_name_not_found.Throw(Unfound);
			end
			[~,GroupRow]=ismember(sort(GroupRow,2),MultiCompare(:,1:2),'rows');
		else
			MultiCompare=multcompare(Stats,Display='off');
			GroupPair=CompareGroup.GroupPair;
			[~,GroupRow]=ismember(sort(GroupPair,2),MultiCompare(:,1:2),'rows');
			NumericGroupPair=GroupPair;
		end
		PValue=MultiCompare(GroupRow,6);
		MultiCompare=table(GroupPair,PValue);
		MultiCompare.Properties.DimensionNames(1)="分组对";
		Descriptors=table;
		Descriptors{:,["ObjectA","ObjectB"]}=[ErrorBars.Object(NumericGroupPair(:,1)),ErrorBars.Object(NumericGroupPair(:,2))];
		Descriptors{:,["IndexA","IndexB"]}=[ErrorBars.Index(NumericGroupPair(:,1)),ErrorBars.Index(NumericGroupPair(:,2))];
	end
	Logical=PValue<AsteriskThreshold;
	Descriptors.Text(Logical)="*";
	Logical=~Logical;
	Descriptors.Text(Logical)="p="+MATLAB.SignificantFixedpoint(PValue(Logical),2);
	[Lines,Texts]=MATLAB.Graphics.PLine(Descriptors);
	if any(CompareGroup.Properties.VariableNames=="PLineOffset")
		for P=1:height(CompareGroup)
			Lines(P).YData=Lines(P).YData+CompareGroup.PLineOffset(P);
			Texts(P).Position(2)=Texts(P).Position(2)+CompareGroup.PLineOffset(P);
		end
	end
	PLines=[Lines,Texts];
end
if ~HoldState
	hold(Ax,'off');
end
end

%[appendix]{"version":"1.0"}
%---
%[text:image:6ba7]
%   data: {"align":"baseline","height":344,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAiYAAAFYCAIAAADobKA9AAAACXBIWXMAABcSAAAXEgFnn9JSAAAAB3RJTUUH6QcWBiU2GQkNdQAAACR0RVh0U29mdHdhcmUATUFUTEFCLCBUaGUgTWF0aFdvcmtzLCBJbmMuPFjdGAAAACJ0RVh0Q3JlYXRpb24gVGltZQAyMi1KdWwtMjAyNSAxNDozNzo1NLlN5X0AACAASURBVHic7d1\/dBTlvT\/wTyQl2cvvjUEJaYKLG2wRowG6q6A7aDVUu9p4WgOppbVYc\/0R92tNG+Ham4m3nrDosU6D2tArFKqB9PZAL7moubYyW5DOIlC5INZEQhIgVNfdoIALGs33jyc7zP6ezf7efb8Oh7M788wzz\/7IfPb5NU\/O8PAwAQAAxN9FyS4AAABkC4QcAABIEIQcAABIEIQcAABIEIQcAABIEIQcAABIEIQcSCir1arzNn\/+\/JUrV3Z1dSW7aInT39+\/du1at9s9ir2htbe3V1VVuVyu6AoIEC+5yS4AZJ1x48ZVVVVNmTKFPf3HP\/6xffv27du3P\/XUUzfffHNOTk5yi5cAmzZtGhgYGN1egLSGkAOJNmnSpB\/84Ad6vV7ecuLEiUcffdRqtc6cOXPmzJlJLBsAxBUa1iD5pk+f\/rOf\/ezDDz989dVX5Y2HDx9+6KGHysvLWePbk08+OTg4SET\/\/Oc\/77jjjtWrVytvnPHGG28sXLiwu7ubiE6cOPHwww+Xl5eXlZXdeeedO3bs+PLLLwOed3Bw8Mknn5w\/f75Op7v11lv\/+Mc\/nj9\/nojcbrfFYlm1apXNZvvWt75VVla2bNmyAwcOKM949uzZF154gR1rNps7OjqGhobYLkmSFi5cuGfPnieeeKK8vHzWrFl1dXUnTpyQc25tbe3o6Jg9e3Z7e7uyPAH3Dg8PHzp06IEHHpg1a9asWbMeeOCBw4cPq3xjQxSSvVErV65ke8vLyx9++GFWSCJyuVxVVVXr1q1buXLl1772tUceeaS\/v7+qqurll1\/esmXLTTfdxDK02Wy4fQlEZAzP88kuA2SRN998s6ur6zvf+U5BQYFy+8SJEw8fPnzq1CmTyTR27NhDhw79+Mc\/1mq1Foulqqpq7NixL7300scff7xw4cJJkyYdO3ZMkqRvfvOb\/\/Iv\/0JEQ0NDGzdunDZtWlVV1eDgoMViYdfuO++888MPP3zmmWfKy8tnzJjhUxK32\/3444+\/\/fbb999\/\/913301EzzzzTEFBQXl5+dDQ0J\/\/\/GebzbZz586lS5feddddBw8e\/M1vfnPNNdcUFxcTkcPhsFgsu3fvfuCBB5YtW5aTk7N69eovv\/xy\/vz5F1100fHjx\/\/rv\/5r9+7dBQUFdXV1Op1u+\/bt3d3dHMfl5eUVFxefOXNGq9U2NTVdffXVkyZNkouUk5Pjv\/fNN99cvny5Vqv9+c9\/vmjRol27dv3nf\/7nnDlzSkpK\/N\/ed95559ChQ3fccYdGowldyBMnTtx3332Dg4N1dXVLliwpLCzctm3boUOHOI7TaDRut3vbtm2vvPKKXq9\/6KGHysrKSktLt23bJklSV1fXfffdV1lZefDgwS1btixcuLCwsDDWXxPIWGhYg5QwduxYrVb73nvvnT9\/fty4cbt37541a9aqVavY5eyGG24YO3bs3r17z549m5eXd9NNN7388svvv\/\/+xRdfTEQOh+Ott966\/\/778\/Lyjhw5cvz48fXr15eVlRHRvHnzzpw58\/e\/\/\/3666+\/6CKvOv3x48f37du3atWqhQsXEtGCBQs+\/\/zzd9999+zZsyzl6dOnn3vuOXnvo48++rvf\/e7KK68cP378q6+++tFHH\/3+979nEchkMn3jG9\/4xS9+sXjx4q997WtEdPbs2R\/84Ac\/\/elPc3Nzb7zxxsLCwpaWlpMnT+r1+vLy8uLi4osuuujaa6\/VaDTKIuXm5vrsHRwcfP7552+44Ybm5ubx48cT0aJFi372s5+99NJLV199NdsSTOhCHjx4cHh4ePXq1ayF02QyFRYWrl279qOPPpK72QwGw8qVKydOnEhEbEiCVqttaWm59NJLiWj27Nn33HPP\/\/3f\/7GXDKAGQg6khLFjx8pXOiK677777rvvPvlpbm7u5Zdf\/uabb7KGL51ON3v27L\/+9a8GgyEnJ2f\/\/v3nz5+fM2cOEU2aNGloaGjdunW1tbWlpaUTJ05cu3ZtwDNOmDChoKBg\/fr1Wq22rKwsNzdXrvGz0WIcx82dO1dOfNNNNz3\/\/PMOhyMnJ+ett9669NJLjxw50tvbyxI4HI7PPvtMef297rrrcnNH\/r5KS0sHBgacTqeyB0uN3t7egwcPCoIgR5dJkyaZzeYnnniit7f3yiuvDHbg2bNnQxdy8eLFixcvVh5SVlZ2\/vx59g4zer2exRvZNddcc8kll7DHBQUFhYWFcuYAaiDkQEo4f\/78hx9+qNwyPDx86tSp3t7e999\/\/29\/+9tf\/vKXCRMmnDlzhogmT5587bXX7tixw+l0Tpw4cefOnfPnzy8qKiIivV5\/3333rV69+g9\/+ENBQcHNN9\/8ve99r7y83KeKQ0SXXHLJvffe+8QTT3z729+eMGHC9ddfv2TJkvnz5+fl5bEERUVFylpIaWnpsWPHPvjgg0mTJh0\/fvzAgQM7duzwyfP48ePyYzneRPm25OfnT506VbmxsLDQ6XSytyLEgWoKeebMmSNHjvT399vt9s7OzrDZjhkzJhuGFEL8IORASjh\/\/rzD4SgpKWFX+Z6enhUrVrz11ltf+cpXLr\/88nnz5t166607d+5kiXNychYuXLhx48a+vr6pU6fu3bv3kUceGTt2LBHl5uYuX778rrvuevPNN7du3bp9+\/bNmzfX1dXV1dX5xICcnByz2fzNb35z7969HR0dO3bseOWVV6qqqpqamsaMGROwkLm5ufKu2trahoaGOL4jsRCikA6Ho6mp6ZVXXsnNzZ05c+bXv\/717373u62trQkuIWQbhBxICd3d3X\/\/+99\/9rOfaTSa8+fP\/+Y3v\/nss89ef\/11nU7HflavW7dODjlEpNfrr7nmmt27d8+cOXPs2LEVFRXK3CZMmMAajtxutyAI27dv\/+53v\/vVr37V\/7wajeb666+\/\/vrrh4aG2tvbV61adffdd19xxRVENDg4+Nlnn7FIRkR9fX0lJSWXXnrp2LFjCwsLjxw5cubMmdC9KdHLy8s7d+6cT\/3P4XBMmzZNq9WGODB0IYeHhzdv3vz2229v2rSJjSYgojfeeAMhB+INg6Qh+U6cOPHUU09NmzbthhtuIKKzZ892d3ezwbss3nz88ceSJCkPGT9+\/MKFC3ft2vXKK68sWLBAHjS1ZcuWO+64Q+5gyM\/PDzaeio1527dvH3uam5vrk3LXrl1Hjx5ljwcHB7dv315RUTF16lR26r\/97W\/ysURks9mMRuMbb7wR9ZvhZcaMGXPmzNm6davc3vXxxx93dHRcfvnl06ZNC3Fg6EKeO3fu\/fffv+aaa6688koWb86fP2+z2WJbeAB\/qOVAon388ce\/\/\/3v5cEC7777rs1my8\/Pf+6559hQ5nHjxn3961\/fsGFDXl6ewWDo6+t76aWXPvroI7mXhZk\/f35ra+vhw4fXrFkjN5qVl5efOXPmkUceqa6unjZt2t69ezdu3PjjH\/\/Y\/wI9c+bMqVOn1tfX33333bNmzTp8+PDGjRsrKytZFYeIBgYG\/vVf\/\/Xee+\/VarW\/+93vPvroo8cff5yVYfHixa+88gob4zBv3rz9+\/e3tbXdcMMN3\/jGN9S8A+PGjZMkafv27QaDwb\/u5bP3gQceePDBBx944IGamppz585t2LChp6fnueeemzBhQuizhChkfn7+FVdc8atf\/WrixIm33HLL4ODgpk2burq6YtL\/BBACvmGQaGfPnn3ppZfkp9OnT7\/77rt\/+MMfyhNN8vLy6uvr8\/LyNm7c2NraeuWVVz7yyCOTJ0\/+yU9+MjAwIA\/6+upXvzpnzpyTJ0\/OmjVLzm3mzJlr16791a9+1dzcfPr06csuu+wXv\/iF2Wz2v5gWFhY+88wzzz\/\/\/G9+8xun01lQUPDjH\/942bJlbFYKEd12220LFy5cu3bt8ePHb7nllqeeekou4dSpU1944YV169Zt3rz5ueeemz59Ojt23Lhxat6BW2+9dffu3T\/\/+c8ffPDBRx99NPTeBQsWvPzyy88\/\/7zFYiGiW265xWq1siHgoYUu5I9+9CMiWrdu3aZNm6644orvf\/\/7FRUVdXV1XV1dRqNRzasAGIUcn8nD7e3tu3fvXrVqlTxWp7u7+5577lHe9MlsNisTACSF2+1+7LHH2J0LYjuMiuVMRPieA8SW108\/SZJWrFhhNpuVG51OJxF1dnZGOqUAIK6OHDny9ttvs3n1yS4LAKhyIeRYrdaA41X6+vrmzp3LJjADpIK33nrrjTfeeO21166++uqvf\/3ryS4OAKg1MmLNarV2dHR0dnbW1tb6pOjt7fWZEweQXIODg+vWrSspKamvr8c3EyCN+PblWK3WgYEBuQnb5XItX76cTfBmCdJiBhwAAKSgMCPWnE6nw+EwGo0bNmwgTwRi93VnMclut\/tMmAAAAAgozFRQvV6\/a9cuuVqj1WobGho6OjoOHDjAtkiSZLfb41tGyBR2ux3flgwjCEKyiwBpw263Rzwvp6CgoKioqK+vTx68bzAY2IwBgNDsdrsgCPi2ZBJBEIxGo8FgSHZBIA0IgoCpoAAwKk2eBzzRY0SmJBYF0kaYhjVJknQ6nbK3hk3T8bmLIgBkkSaiHCKeiCciIhsRR7SICDdpg3DChJzy8nKz2Wy1WtmagN3d3fX19WazGdNCAbKUzRNpfIhEnKLqAxBImIY1jUYjCILVap03bx7b0tzcXF1dHf+CQWZCo3\/a47yeGc9535CNJ2pMXFkg7fjOy4kUG6+CDmGArGDzDTkB8Ig6EJggCFgvBwBU45NdAEhzCDkAEFNisgsAKQwhBwBU45JdAEhzCDkAEFN8sgsAKQwhBwCCayJqIlrkmXajZlwA5oRCcLj7AAAE0uRXX+E8\/8TgR4XYBYCQAwABhJjvSZ4eHTHQXlRxICSEHADww4XcKxINK8ISS4y5OKACQg4AeFNzq7QmokaiHXEvC2QYDB8AAG98sgsAmQshBwAiJya7AJCeEHIAwBuX7AJA5kLIAYDI8ckuAKQnhBwA8Ib5nhA3CDkA4IcPuVdMSBkgEyHkAICfRs8qn\/5EVHFg9DAvBwACMRHtwHxPiDGEHAAIzoT5nhBLaFgDAIAEQcgBAIAEQcgBAIAEQcgBAIAEwfABAFChiYg8M3J4jJOGUULIAYCQgi0PyiPwQMTQsAYAwYVYHpTzVH0AVEPIAYDguJB7+YSUATIIQg4ABKFyeVAA1RByACAIPtkFgIyDkAMAURCTXQBIKwg5ABAEl+wCQMZByAGAKPDJLgCkFd+Q097ebrFY3G63cqMkSTqP9vb2BBYPAJIHy4NCrHmFHEmSVqxY4ZNCkqT6+vrOzs6enp7Ozs6WlhZEHYBswYfcKyakDJBBLoQcq9VaU1Pjs9vlclmtVrPZrNfriUiv19fV1W3evNnlciW0mACQFFgeFGJqJORYrdaOjo7Ozs7a2lrlbqfT6XA4TKYL36yKigqHw9HV1ZXQYgJAsrBV2kTFfW54omHEGxiNkXusNTQ0NDQ0+O92Op1EVFBQ4LO9r6\/PaDTGu3AAkCqwPCjEQsS39SwoKCgsLFRusdvtgiDIT41Go8FgiEHRAAAgnSlDAxHZ7fbYD5KWJCnmeQIAQNrxbwyLuJbDeneUWwwGg8ViiapcAACQcQwGg7LRSxCEMLUc1ovDenSUSktLY144AADIbOFDTmFhYV9fn7xl\/\/79hYWFZWVlcS4YAABkmjAhR6vVLlmyZMWKFayHpru7u6WlZcmSJVqtNiHFAwCAzBG+L6e6urq0tFSeJdrc3FxdXR3nUgEAQAbyDTkBZ+cYjcaenp6ElAcAADIW7iQNAAAJgpADAAAJgpADAAAJgpADAAAJEvHdBwAAQmkiIs9SOjxuOA1eEHIAIEaa\/JZ04zzrHSDwABGhYQ0AYsMWZAlRkYjzVH0g6yHkAEAscCH38gkpA6Q8hBwAiJpNRRpUdAAhBwBigE92ASBNIOQAQEKIyS4ApACEHACIGpfsAkCaQMgBgITgk10ASAEIOQAQRBNRE9EiokXhBgg0qsgNU3MAU0EBIIBRTOrkQ9ZjxOjLBJkAtRwA8Da6SZ2NngQBD0QVB4gItRwA8MWF3MsHb0YzEe1QRCyWj5o2N8gaCDkAoKByUmeIQMICD0AgaFgDAAU+2QWAjIaQAwAREpNdAEhbaFgDyHA2m00URZWJOeJM4fr6baJNbFKbYTQ4jjOZMPAgoyDkAGQ4URR5nleZmCc+bMjhiRd5McpSqSoMzyPkZBg0rAHABbyKzhyRRJaSJ14kUSSRwx1vQB2EHADw0hRymYFFtIgnfpiGG6mxkRpNZDKRaQftQOABNdCwBpDhOI5T37DG2MhmEk3+wwRsvI0TuUYxwBBpFnhsnE3k\/A4bLY7jYpUVpIic4eHhaI4XBIGILBZLjMoDACkj4KTOnHBHRXVFgUwmCAJqOQAQhP+kzugnikJ2Q18OAKjGJ7sAkOYQcgAgpsRkFwBSGBrWAJJJEATWIZoWLKcsFgrTcWu325fqliamPNEzGo1tbW3JLkUWQS0HAGJJmJw2ERQSL3zI6e7uXrhwoU7BYrG43e4EFA6ygvqlJyHZ1IQTKV9KQEkgTYVvWHM6nUTU2dmp1+vjXx7IJqNYehKSTZgiWAaDtq3VTKtJZGEg7YQPOX19fXPnzi0uLk5AaSCLhF56ks\/GgbYWiyU9prixz0702y5SmykN+kXsdvvSpWnT25Rhwoec3t7eoqIijUaTgNJAFuFC7uWzMeSkDaz+CaMVJuS4XC5JkiZOnKjT6diW2trahoaG+BcMMhpmFGYArP4JkQsTcpxOp8PhMBqNGzZsICKXy7V8+XKLxbJq1Sq53mO325WjPI1Go8FgiF+JIRPwyS4AAMSfzwQAu90eZsSaXq\/ftWuXXK3RarUNDQ0dHR0HDhwIdogkYbwKxIKY7AIAQHSMRqPPloinghYUFBQVFfX19cl5GQyG9OjzhNTBIaIAZD6DwaBs9MJtPUE1toSKSERRDGKWMxFVJOZHdQpIAJ8vg6h4ShjjDqGECTmSJNXU1LS1tcl1GjZNp6KiIu5FgxQRk9kz\/pmEhctWCgr4ZSC\/LRwCDwQWpi+nvLzcbDZbrVaXy0VE3d3d9fX1ZrMZ00KzRejZM6FWj1SRSQhihOkhAdR\/jmIkXw\/IJmFCjkajEQTBaDTOmzdPp9NVVlbW1dVhkHQW4ULu5WORiT8RP5BTEhdhej4OZYA0p6ovp6GhAWEmG8Vk9ozK26ZxmFGY2kZ3+ztMrgJvGD4AwfGJyoTHhSnl8ckuAGQELF4A0RFTJhNIQWKyCwApBiEHguNSJhNIOi7ZBYCMgJAD0eFTJhNIQXyyCwApBn05qSomUy8TkGfYTBpVXHdYJtEXL5oc4vHmxFtEZY7yBar5HP35nCXmb3LoDNPxM810CDmpJx4Ll0Wap8qZm6K6s\/MhcxNj8ZKjySEdV4qLqMyxeoF8hFFHjEMZVGaYjp9pdkDDWoqJydTLKPNUOeNPVP3X2+g5V8BMKOqXHM2bFo83PN4iKnMMX2CIzzFg\/vLXI+ZvcugMF6XhZ5o1EHJSDBdyL5+QPEOnZ4cMR\/hrka2tIip+bMqZRFo8f9HkEP3ZE48LuZePInFYJhVVW97v6xHbMoTNUIz16SB2EHJSicqpl3HNc3Qz\/lRigWcHUaNnIk70LzmaHOLxhsdbRGWO+QscxdcjFcoQzekgptCXk0r4FMhTRXqbaBNjNOGiUQw\/BTT06dTkEBQ\/+kOTho9b4jhlmAplgJSBkJNuxDhM1I80T5F4kY\/JmTniTGFb6EKeTmUOo3\/Tojk2WcRIyhxR4jhlGPMyhD3dpQk8HSgg5KQSLnxDud1uF2qEMIkUDAcMFgqzgJ4yTzXpY0gkMXzAiDqHYG9apG8OpcKChFwkU\/ojShynDFOhDJAyEHLSjDBZiGipbwMZwqZR5qkmPZ\/Ypo3oTxfsTYv0zSEi5RKHqYuPW+I4ZRjzMoTWSNSa2DOCR87w8HA0xwuCQERYiDpmcsLs112m89liOWUhIuM5I7HrY77vtbXnaE9EeYZNr52iDVPKSLgGXVGeLmwO\/m8aed43y2CYr6587Ej6cgtRLKd3CILA\/oiIyGKxqPpTCvclIeXfdESJ1RhFhqM4JPQszrAZhmSX7EuXLmWPjUZjW1tbVNmBaliIOvXw4WZN3nPhmeWUxeeK2eZus2vsPoFHmCKEuLDWTKtRPmUX1hBqptVMzp8cOk1EBApVPGGKMHlymNOFzsHnBVKg9y30sV7pRSJK9rxCPtyXZNSJY372URyiZhZn6Ay5kK8rxC6IP4ScFNPo+esS\/XaJXhc44zljwOumwW1oc7fZv2WXKi9EHfs5u+E1g3+e9lV2Q77hQvuSjSxbQ12LfdPHiL3Tbng1cJ6WQYvRaFS+lsA5qHyBFP41+h5rMwROL3o+qcQPLlD9JYk4cczPHukhoed48p53O2yGtpB77YFOAQmBhrVUJf\/tcUR04bqm042084Rt\/grQWBEkzwti3gijUqzOG\/YFqjkX731snN+T0TSsydS83tEljvnZVR4S6bsdOsMge+12NKwlBxrWUhibNRkE67kJw39BxpB5xmYN0FGI4XlDv0CV5yLFuZL1nqgU9vWOOnGcMoz5NzB0hjF\/yRA13H0gLYXtcRkNPvZZptx5Iz1XpOkhGnyyCwDxh5CTucQ0yTPVzhvpuSJND9EQk10AiA5CTlryHwkdA1zss0y580Z6rkjTQzS4ZBcA4g8hJ3PxaZJnqp030nNFmh6iwSe7ABAdhJy0JExWcc+bUSz7GPM8iaiJqIloEdGiIP3DcTpvQJGeK5FlA7zbWQAhJ10JU0JGHXFUmfIh90aaZxNRjmfWnqhYPss\/8MT2vKFFeq5I00M0+JB7xYSUAeIJISddCZMF+yp70KU2R\/djMGBuymzVi2ghyNDLhsb2h22k52okoUqwawLNHgyYHqKRyG8CJAPm5aQzjqghplP8uJB7+UgyjzQrNoUi5tMVA4rwXPZ8u3CpYDxnZGPTDQ2GOJYNEvlNgIRDyEl\/sZrvFsNpj6POKpFz9yI8l5QvSZdKFovFYEmHm0mnO8zizFBoWAMPPiWzAoAMgpADkRBTMisASBMIOeDBpWRWAJBBEHIgEnxKZgUAaUJVyJEkSefR3t4e7zJBcsRwIl6QrOwa+4XpRBjwmhFqamrsdqw\/A2qFDzmSJNXX13d2dvb09HR2dra0tCDqZCw+5F4xBlnZ8+0RZwUpTJLicLs\/yFxhQo7L5bJarWazWa\/XE5Fer6+rq9u8ebPLFWa1eUhLMZyIhzl9AOAnTMhxOp0Oh8NkunCFqKiocDgcXV1dcS4YJAmbDyEqFpzniYZHFST8szIRcYg3ANkrzFRQp9NJRAUFBT7b+\/r6jEYVC1NCPMmL6cbRBsX\/MclKsZY2+FAuSp1GEvE9hEwR8d0HCgoKCgsLlVvsdns6\/p0AjELMv+3oe08uSZJw+UoYu90e7Q1vUNcBgPSFK1giGQyGiEMO691RZmEw4JZTiYNfZMllMBgsFksMMxQEAYO+kiu2HyiEFibksF4cp9PJRqzJSktL41goCK6npyfZRYBYslgsuORB9ggzYo313PT19clb9u\/fX1hYWFZWFueCAQBApgkTcrRa7ZIlS1asWMHq\/t3d3S0tLUuWLNFqtQkpHgAAZI6c4eHhsIkkSaqpqWGPm5ubq6ur41wqAADIQKpCDkCsWK1WImpoaEh2QSBayl+i5eXlL774Iho\/ICzcSRoSp729vbW1NdmlgBhob2+vqalpa2vr6enp6ekxGo233357d3d3sssFqQ4hBxLB7XZbLJYVK1YkuyAQA263e\/fu3bW1tfKklp\/85CeFhYX79+9PbsEg9UU7FRQgLLfb\/dhjj\/X39+\/cuXP16tXJLg5ES6PRBJwf1tvbm\/CyQJpByIG4k69Qbrc72WWBuGAzxGfMmJHsgkCqQ8MaAETF7XavWbOmsLDw5ptvTnZZINWhlgMAUfn1r3\/d0dHR1taGEWsQFmo5ADB6Vqu1tbW1ra0N98cENVDLAYDRYKNCWP0G8QZUQsgBgIixeLNv377Ozk6fe\/4ChICGNQCI2K9\/\/et9+\/atX78e8QYigloOAESmu7u7o6NjYGCgsrJSud1sNq9atUqj0SSrYJD6cI81AABIEDSsAQBAgiDkAABAgiDkAABAgiDkAABAgiDkAABAgiDkAABAgiDkAABAgviGnPb2dovFolzXpLu7e+HChToFnwQAAABqeN19QJKkFStWmM1m5Uan00lEuJMSAABE6UItx2q11tTU+Kfo6+ubO3ducXFxAksFAAAZaCTkWK3Wjo6Ozs7O2tpanxS9vb1FRUW4bxIAAERpJOQ0NDTs2rXLv+nM5XJJknT48GG5I8dqtSa8kAAAkAnC3Ena6XQ6HA6j0bhhwwYicrlcy5cvt1gs8v1i7Xa7JEmJKCkAAKS5MIOk9Xr9rl27Ghoa2FOtVtvQ0NDR0XHgwAG2RZIku90e3zJCprDb7fi2ZBhBEJJdBEgbdrs94vVyCgoKioqK+vr65KVnDQaDxWKJddkgA9ntdkEQ8G3JHDYSSDCeMxoaDMkuCqQBQRAwFRQAItdElEPEKR43JbdAkB7ChBxJknQ6nbK3hk3TqaioiG+5ACA12YgWEfF+23miRUS2hJcH0kqYkFNeXm42m61Wq8vlIqLu7u76+nqz2YxpoQBZiicSg+wSPfUegCDC9OVoNBpBEKxW67x589iW5ubm6urq+BcMMpPBgEb\/dNbkG2+M54wB0jQmqjyQbnKGh4ejOZ6NV0GHMEBWyFGXLKqLCmQsDB8AANXQTwNRQ8gBgFhDcIIgEHIAACBBEHIAQB1THFJClkHIAQDVOBVp+DiXAdIZQg4AqOM3QjoADiOkIRSEHAAIp8kzPHo4XEVHjH9hIJ0h5ABAcMpg06iuooObrUFwCDkAEIhPYFJkHwAAIABJREFUsGF4FQeqSQPZKuLFCwAgw9mIRCKRiPfumMFsG4gaajkAoNDk6a3ZEcVAAAQnCAIhBwCIKEhLGkBMIeQAZD2VwQZTQSFq6MsByGLy6DJeXc2GUzFijR91aSDzoZYDkK2aPOGhUUW8Ua48HQKHRjkIBSEHIPtE1G3DEouempAYPPBwqOJAGAg5ANkk0jECrCbEKwawmYh2BAotLA16cSAkhByA7NBEtIiIVHfbhA5OjUTDnuk7Iga5gVoYPgCQBeTKSkQ1m7DrSaNOAxFCLQcgo42i24ZUByeACKGWA5Ch1FdWyHOTGx7BBuILtRyAjCNXVkTVLWkcEUXeJWPz\/ANQByEHILMou23C9rWM+iY38jQd9i8HaxaAKgg5AJlidN02YuQ1m0VBBkkvQo0HwkBfDkD6i6jbhlVH+NF22\/DB73kjEnHqygDZCrUcgHQ2uqmd6tP7Hy6qSAMQBEIOQHqyeQIAH4upnSrxMUoD2QohByANRbSQWqwWwkE\/DUQNIQcgrUQ6RmBRMmbbIDhBEAg5AGlidN02HG6ABikEIQcg5TUphpklrNvGH1YFhaj5hpz29naLxeJ2u5UbJUnSebS3tyeweABZbxQLqVEcajZNqoei8TE9L2QWr5AjSdKKFSt8UkiSVF9f39nZ2dPT09nZ2dLSgqgDkAjRLKQW85LwnpKExqERD0K5EHKsVmtNTY3PbpfLZbVazWazXq8nIr1eX1dXt3nzZpfLldBiAiTPl19+uWPHDrPZrNPpysvLH3vssRMnToQ9yuFwPPHEE+Xl5Tqdzmw2d3R0DA0Nqc22iSiHPvnsk2U\/WKbboPNhtVrlTI4dO\/bNb35Tp9PpNuh0l+l0fTqWPma\/C\/3DnohVQWH0Ru4+YLVaOzo6Ojs7t2zZMjAwIO92Op0Oh8NkutA0W1FR0dLS0tXVZTQaE11YgIQbGhp64YUXWlpaZs6cWVtbOzAwsHXr1rfeeuuFF14oKysLdtTRo0dra2v7+voWL15cVFQkiqLFYnn\/\/ffr6upyc3NDZTvnhbIDZeza7Vzm7PtRX0FBQXFxsTLzSZMmyY\/\/2fzP\/iP908dPv\/jyi5VpJkyYEO0rD3ZHA7YqaJNfdOFRvwEVhr2tWrXq4Ycf\/vTTT9nTv\/3tbwsWLOjq6pITdHV1LViwYPPmzezps88+++yzzw4DZKiDBw9+4xvf+OlPf3r69Gm2ZefOnVddddXKlSvPnTsX8JDPP\/+8qanpqquu2rlzJ9ty+vTpn\/70p1ddddX+\/ftDZVt21cqCleceH8l2z549er1+y5YtgUvGDw\/T8JYfbNHr9Xv27InRy72Q8zCvIqXo+QegwrPPPhvxPdYKCgoKCwuVW+x2uyAI8lOj0WgwGGIQDAGSbXh4eMeOHZ9++mlNTc348ePZRqPReNddd7366qv9\/f2swdnH8ePHbTZbZWXl\/Pnz2Zbx48ffe++9u3btev3116+++moi8s22iYy88a7b7nq18NX+Zf160hNRT08PEflUcVjikfoHT135XdP6pl188cW+aUYnonu1EUamQRjK0EBEdrs99oOkJUmKeZ4AkWLDLCVJstlsrL\/k+uuvf+GFF86ePcsSuFyuqqoq334Sj6qqKpfLdfbs2YMHD+p0upKSEjnn3Nzcq6++emBgoKurK+Cpe3p6jh49WlFRkZeXJ2+cPn36rFmzDh06dPr0aa9sPZ0lucO5V99\/Idvh4eEjR46UlJRceumlF7K2ea1NcLb+7PHjx0tLSwsKCqJ9v+I31A2ymH\/\/S8S1HNa7o9xiMBgsFktU5QKIj9dff33btm1XXXUVx3F79ux56qmn3n777ebmZq1Wm5OTE6AC4VFcXJyTk\/PZZ585HI4ZM2bIVRyGXeI\/+OCDgMeyP5AZM2YoN37lK1+ZMmVKd3f32bNn8\/LyHA7HjNMzxl8ynhqJxJHqgjLbTz\/99OTJkwUFBa+\/\/vrWrVvfeeedgryCJSeXLKtdVjg80szw6aef9vf3f\/WrX924cePWrVuPHj162WWX1dTULFmyZNy4cWrfo0hrNgCqGQwGZaOXIAhhQg77G3A6nT4NCKWlpfEoH0Bs\/fGPf3zqqaduvvnmnJycoaGhlpaWlpaWBQsWLFu2bMqUKS0tLaEPP3r0qMvlUlZxGK1WO23aNJ\/fXrLjx4\/7b8zPz7\/kkkv27dt35syZc+fOuY64Sk6W0L95VSmU2X7yySdHjhz5xz\/+0dPTU1lQyZ3i9sza89z55zr\/3rmmaw0bufDBBx8MDAwcPHjw3XffNZlMt9xyiyiKTz75pM1me\/rpp6dOnRrm3UGwgYQL07DGem76+vrkLfv37y8sLAwxVgcgdVRWVppMppycHCLKzc1dunTpnDlz\/vznP3\/yySdqDh8aGvriiy\/8t+fk5LA8gx0V8JAxY8YQET1HQ2VDXwx\/QTVEK4Nme+bMmby8vO\/ovvOXvX\/55bW\/fHTro5ve3NTc3Nzb2\/vcc8+xydpnzpzJz89\/8MEHX3nllX\/\/939vaGj405\/+9OCDD+7atev3v\/99wGKMQDMaJEmYkKPVapcsWbJixQrWQ9Pd3d3S0rJkyRKtVpuQ4gFEZe7cucoOFa1W+7Wvfa2vr8\/pdKo5PDc3dyROeGPDb0IcFfCQL3Z+QX1ERLlduWO0YbLVt+m3Xr31mb88M5GfyJaUvuiii2677bYbb7xx7969x44dIyKj0bhz585HH31Ufo15eXnf\/\/7358yZ89e\/\/nVwcDBA4RBsIKnC9+VUV1eXlpbKs0Sbm5urq6vjXCqA2PBpAR47duyUKVO++OKLoaEhl8u1fPnyAwcOBDywvLz8xRdfnDRpUsBfVy6X6+TJkz5DN2UBx5idazr3AffBxDkTxzeMz8vLC5NtkCav8ePHX3bZZf\/7v\/8bYi72pEmTZsyYsW\/fvlOnTnmVEM1okAJ8Q05DQ4N\/IqPRyMZrAqSXkydPKp+eP3\/+ww8\/zM\/Pz8\/PVzN8YOzYscXFxf39\/W63W6PRyHtZJemSSy4JeOz06dOJqK+vz2g0km3kJjSfr\/x88NjgxXTxuHHjxowZEyrbhy6hBqJhcrvdYz4bM3bsWJ\/8lXUv1rbmX68aM2bMhY0INpAyIh6xBpBGDh8+bDab5Yvv4ODg+++\/r9PppkyZMn78+LDDB4ho1qxZoigePXpUrpcMDQ3t2bOnqKgoWI9maWmpTqfbt2\/fdw59J++Xeexa33+o\/9173v3e9743YcKEnJycANk2Du1p2VM0vajsQBnpad26db\/85S99GhUGBwcPHDjARk4PDQ39x3\/8x6ZNmzZu3KgcivrBBx8cOnRoZOQ0gg2kGCxeAJnsD3\/4gzxR7Pz58y+\/\/PLBgwdvuukmn0HPISxYsOCiiy56+eWX5REHkiT96U9\/MplM\/iPZmKlTpxpyDZ2bO6V\/SsNfDlMjnTlzZv369Z999hkbO+ebbRNRE0lW6U+FfzLdPpLttddeW1hYuHXrVvnGa+fPn1+3bp0kSWazedq0abm5uTfeeCN7jXLZPvnkk1\/\/+tfHjh37Dn1n4qSJRLgPDaQW1HIgk1188cX333\/\/jTfeyG509t57791111233Xab+hzmzJnzox\/9qKWl5d133+U4bmBg4LXXXisuLv7hD38od9pbrdbW1taRGkkT5fF5P7T8UPpcuu+v9y3+f4vlU9fV1c2ZM8c3W9u73FFu4OqB10q9sr3iiivq6+v\/7d\/+7dZbb\/32t789ceJElsltt922bNkyVm9bsGDB\/fff39LSYrfbKysriaizs\/PkyZP3Dt77rZJvIdhACkLIgUz2k5\/85JJLLlm9enVHR8fs2bOfffbZyspK5Ri2sHJzc+vq6i6\/\/PK1a9e2trZOmDChqqqqrq6Oddh42Ub0j5Gem7LGso0nNra0tLz66qunT5+ePXu2IAjf+ta35Ca+3NzculN1l394+Vrt2tbJrROcvtnm5OR897vfnTFjxvr16\/\/4xz9+\/vnns2fPXr169W233SZ3\/7CyzZkz58UXX3zppZfoS5p7Zm7TbU1cMZfblJA\/bXnBadz5BtTJCTHWUw12Cx3cfQBSjSRJNTU1iRtgqbgPTYwTR3R2SlTNBneShsgJgoC+HIDoRLqQ2qKYLqQmn51Xt2xo9GxEiwKti8MTLVLUewACQcgBGK1Ip1WymgFHtCMWsSHxwYY8pxOD7BKDr94GQEQIOQCjwSorFElLWgzn\/LPc+IQHG3ZqUUUagCAwfAAyUxznL4+u2yYmM2PY1Vz92WOOV5cGnToQBGo5AKpF2m2jbPiK\/tRyj32ybo+GfhqIGmo5kFCLFi0SRTHZpYgOr+7HvpyYIkkf27PHH098o38AtGHYNASGkAMJtWPHjmQXIUJyyxin7jIawwHQSW9G82HD6ACIFkIOQHDJ6rZRBpvUuT2aqDolqjgQBPpyAAIZXbeNGHV1JBX6bHyw4Xlyv1RYatJAtkLIAfAWabBR1oSi\/HWfUsHGJ9IMqxuQzaVAySGFIeQAeIxuaqf69DE8dfwoIw3nKY8ylHIhDxfjVS7IDAg5AES2yLttYhUhUiTYBIw0\/uXBVFCIDkIOZL0mzy\/3iLptMiPYNCmKwaloPeNV5KkmDWQrhBzIYtF02yTsvPGgjDSkup8GU0Ehagg5kJWS1W2T3GAzukgzCghOEATm5UCWYT0NYsJn28T2ZmuRnpqIeGpij3jv7eoEuMVAiBPyTdFPGuU4zmTCBJ9Mg5AD2US+7qu5B0K6BxvFfNImvomXQw0fJL03jjiOOPbARCYb2UQSVQYeXuSjH7rGcVz63asCwkHDGmSHpCyklpRmtECtZ7y6OMMRxxMvkjhMwztoBws5PPE5lMN2NamoGalJA1kLtRzIdJFWMmIyRiDxNRvlPXIogvOyaKSsyogkssATMHHoio6NbCrDG2QnhBzIXE2edSr5BHbbJDjYyJGG84xyDoTn+QtPxJG5NSPBgxsZI66sncitav5svM0U\/C4LJjJ5nQvAG0IOZKjE35EzkcHG5mn340JFGtlIdBE9Ezl5IvK9N7aqfhoVbWaNkQ01gOyCvhzIOIlfSC1hfTY2xSrU7HQ7gpzRpujUyfFEGo5oWDE2ehTDwfgYpYFshVoOZJDEd9vIOUSTSVgq6zQ2Tz1GJCLPpV+M3VICmG0DUUMtBzJCpMsHRF8v8akexWlCJTsLR0REYqA6TZPi9mg8EcWiKhM9BCcIArUcSH8J7raJac1GEARBEHw2Wk5ZLIMWIhKmCPZpdilfog1EG4iIjOeMhnMGImIJ7Bq7lC\/Z8+3SZRL1jaQZ+T9q8rmM54wGt0H9gTVLa6R8KTaFiDOj0djW1pbsUmQRhBxIIPnHb6x+ekcUP+TE4mgLEOdmNMspC7u4C1OEmmkXrtqWUxZSXPeFKQIRKRPEhH+AYfGMiITJgnSpREQ9R3vUZJUu8QYSL3zI6e7uvueeewYGBuQtZrN51apVGo0mngWDzNLk16vMJ3Dii9wXMuqTxjPYKCMNu7izq7\/hnEFZlZHypaWXLo3VSdUEGH\/CFIEVKQQWEQECCh9ynE4nEXV2dur1+viXBzKOzVOx8MF7wkCkFY5RjxEYXUta\/IJNE5FIFtEiTBFYRCEiyylLm7uNYl2VGV2A8SdMDhNy7Bq7MBkhB4IKH3L6+vrmzp1bXFycgNJABuKDL+olqppTckGklZWYBBuKdbBRTt4Uyb7YbrQZDW6DXWMnExmMBnYuC4WpTIRi87znomJ4NOfZyxGZyEAGA0XQPeOVOR\/kM+XIwBt6TKoa35LIbrcvXRqz+iJEJHzI6e3tLSoqQjMajIbKRSRjHj+iDzYU65qNnKdMHAkDcj3DsthisEQeBmyKN1n0m+zJx3rQmoloRxxaSiE7hAk5LpdLkqSJEyfqdDq2pba2tqGhIf4Fg4zAq0sT+lIVabChKKKF8vCY3ETAP9Kwx9xIJJAESXovkqazgAGG81Ri+ESNimYjsGM+HgQyXZiQ43Q6HQ6H0WjcsGEDEblcruXLl1ssFuXwAbvdrhzlaTQaDYZRVdghw0Q\/OSOR3TYxDDa2QFUNGm0lIEQrGZ\/saz0iDYTkMwHAbreHCTl6vX7Xrl3yU61W29DQUFNTs3TpUqPRGPAQSZIQciAyOYrHnOKx6HnQ5LeLvK93SQ828spvoic3GtVo7FQOMAARMhqNkuRViY94Xk5BQUFRUVFfX58ccgwGg8USRVcngKi4mMq907xfNzXvd5QS532ZVm5X8glUNNpg41OVkUvIRVKbsZHxNSOd8gwk+3\/pFmDQsAYhGQwGZQ1EEARMBYW4UX8ZklP6r9qpzMT\/Xi8iEXkPx2JExQMx0HYlzpOMU2wJWDyfm5jJ+EDF8xewBpNP5BlBYLFY0ubXG4YPwKiECTmSJNXU1LS1tcl1GjZNp6KiIu5FgwzAqxhBwBLE9o6ccpAIuFc+llNsFP2K5L89IDmxf9+V6PmfPeAC1GAkQRLeS6uJLDGfaAXZJEzIKS8vN5vNVqv1xRdf1Gq13d3d9fX1ZrMZ00JBlUZ1g9YWJWohtRDHKqsyDE9EflUo3rOFbRQ928Vwr9Q\/PXOAjOdGfs\/JD1IaH7uJVpB9woQcjUYjCILVap03bx7b0tzcXF1dHf+CQUZQsaJXgqZ2hj42ROd\/wIUD\/JvISBFyOL9f+j4VIPHCAwtZ7Kfs7JnhMQM9pkjGeR\/FBd+VsIpFDCdaQVZS1ZfT0NCAuTgwGry6ZGoWUuNHO9smYLDxH8fM\/u3wTsApmsKYRd6tZJy6piRTkKeNJAiC0DfSsObVlxMsSlG4DiouyFOf7aOLUry6NAg5EASGD0DcxGrRlFEvpOYTbNSsYGbzbiLjFBd0znNUYqoUwaIUhXwfQgQqPsh2hgvyVLnd\/yiACCHkQApo8r60+Q9gi7QlTVkrIk\/VhPOryjD+w505T3m4dOsMjz5Qid6PxVFFGlu6vW+QKAg5kAJERdeID877qsf5PWB8ohTDB2r7svn13MiJxUy\/UAYLLRSypQ4gdhByIG7UX76V1Y4mRe2EU2wXvR+LQXYpcYoEvHfckh\/zaViVoZDBQ7nFfxfn\/VhUJOO803Pe6Tkik\/d9IkJIu\/cTEgUhB+KJVz0vh8KtTaC8inHBZ\/6zLaLnf05xiM92nxzklD5PfbbH4WLqNUjaZ4yfGOQxwwV\/rHzqc7jo+V\/0GxzBHoR4jXwkHyiAH4QciKew83I4T3QJ223jP45ZDFRf4TzZct6tbaJiXIB\/PAs+iHn0F32fxEHyYevi2DX2kXIaQgaPEMHA5p0zr3jKeRePD5dVCOo\/UIBAEHIgzriQfQNi8GATcO6LnCFPRIo7CHCBrqHKW6hxfqMGlAL2utu8m+bI+6mo2O6fxn+7D09W9ny7ZB+576GxwUjKyaABo4ItUH1FzlMuIR88hyhx4T5QgOAQciCe1MwcFBX99sFuYsZwiqYzPvivaWWkIaJhTw3Apx5Afk\/9T8oFf8wrnqq\/svtXpzy32R1pVTMEKUlAXBQlGR1MBYXoIORAPPEq0oh+3fsM51eDafLusAnY7aHMhFf8z3nn7H8WJt6XbJ85QNyFkENEBrchcFMYR15ExQMx+GABLvhTn13qXzWvLg1CDgSBkAMBNDWpuVNNGBxxJpUXM97rMN+RVLxXWhLJxtk8D8VGz+XNxtlMnOlC4hQZNOVTtRL9BnznjzwTJguGxQbLFhV3kg5901LleWWi92MxyC4KGagAooaQAwHwPB99JhxxO0L1nwQhhm+6kSOZMqSZRFOadSSIREQGMhjIs6DIVtWjkONHDPlUJUwFhSAQctJMTU1NsosQe03URESc9y9qNTUkG9mISCSRiPI1+fn5+fZ8ezxKSESGcwYiMp7zrLMueu\/mgreDhWSXLqzjbjDGZ7VDMchj\/6cAcYaQk2Z8VnVNZaLq6xnv3XbGE99IjSwOsV0sKxOZmrw7cFiUGolVbjK5faPUyOBjDyl\/5N3ziUzydjZFhkWXC0\/dhgu5mWhkUBkrctS\/5aW3JfnsBpMhTIajvn0A5\/dYDPKUgvQksYJhKihEByEHApgyZUpM8rGesza4w9yDXJgiTKGR01kGLY3UKEwRBBIEEiyDFhZ+7Bq7lC9VUZXvseS1uNnkyZPlxz5rz8hRhO2yDKqtTNg1dmHKyFns+XYLZ7kwjjnKC6tnHJ3l1Ehh2KLURKr7WnweK5\/KIwDJrydJfspFMglUTsarSAMQBEIOBKC8dkejlVobjoYKOXaNXZgsTKbJllMWy6CFBRu2yzXoYpFGN1k3UiqKoFRSvqSssgSor\/hVeuRDZD6BKtQ4Zi7IU2Uyn0OIiCMLWeznvAozcrgyQzVVH9F7zIV8LmVWvIrcQsNUUIgOQk4ai0u7f6zZV9jlC70\/g9vAgg0REUd0gCyDFnaVFCZ7VpGhkC\/T+4e88Zzxwuk4xf9E9ny7nexeV3a5GGQY+T\/0vcuIAnfk+PCcUU0yuz1Q5xPnt8W\/vkJ+jWPsf56I4tm0xWEqKIweQk4aMxo9Xdkpq4nIHSaJso3LYrHIv5G9Ik2IocZExNGFtBwReTcreQ5hVZaRiovotcsL53lQPvKYde+zWCVNkUYivZpruppBzBIJgnChOiVGctXmgrezxWnMGKaCQnQQciCeeNXJGj1XYXl8gKj4n+E8WzjF1VYMklh5SMDHyqchr8729+zyqA2LyRKDS7kygkpkOWUZqZm95v3SyDuCUsh7wfk\/VeKCPPXZrqYvJyweIQeCQsiBuFG\/Kiiv4lrGKR5w3tuVT1NnrFTYSaDcyDNhskCTScqXvBaiDij4gtbhSyIXQ\/lYDLKLgkcpgCgg5EAK4BWPOcXj1IkfwYToYuEU\/1PQLhZJkKT34jzw3RTkcaQ3LxBVnxFTQSEIhBxIAVxKX6EM5wx0zjPy7TUj\/YmIEn7\/5gQLWJ3iUNeBaCHkQNyov\/KmyDU6yLoAFrKw4doju3giSpkyJ1LafaCQehByIJ741Js5qGwKU\/5P3k1h3IW6V01NzYWbPiwmgym1RwnGFZ96HyikFYQciKdkzRxU2XXPpXqbXsrBVFCIDkIOxBkXt5mDUXfdw2iIgRY3YjhUcSAMhByIp+hnDiKupBoT0Q7PcnlKPOo3EB5CDsQTry5NY9Cue6IMHRKW7hoVs3cJnwiohZADcaN+KmgO4kp6wmcEEULIgRQg4uIFkBUuSnYBAAAgWyDkQNxg5iAAeFMVciRJ0nm0t7fHu0yQOXivZ8oVNoOlgfRSU1MTeMkfgEDChxxJkurr6zs7O3t6ejo7O1taWhB1QC2\/UbNs\/c0LOIysTW8X7ssAoEKYkONyuaxWq9ls1uv1RKTX6+vq6jZv3uxyuRJSPEh\/YvB7QXKo4gBklzAhx+l0OhwOk+lCW3tFRYXD4ejq6opzwSBTsJmDvN92nmgHenEAskuYQdJOp5OICgoKfLb39fUZjcZ4FQrUWbp0abKLEInLyHjOKOVLNdNqpHyJNhBtSHaRUowgCGzR6\/SSZt9DSKqI5+UUFBQUFhYqt9jt9nT8O4HEY\/f\/v7AKQBqK+bcdfe\/JJUkSLl8JY7fbo50KiroOAKQvXMESyWAwRBxyWO+OMguDIYuXD0k4\/CJLLoPBYLFYYpihIAgY9JVcsf1AIbQwIYf14jidTjZiTVZaWhrHQkFwPT09yS4CxJLFYsElD7JHmBFrrOemr69P3rJ\/\/\/7CwsKysrI4FwwAADJNmJCj1WqXLFmyYsUKVvfv7u5uaWlZsmSJVqtNSPEAACBz5AwPD4dNJElSTU0Ne9zc3FxdXR3nUgEAQAZSdY81o9HY44F4kzGsVqtOp7NaraPOweVyVVVVsRwkSVq4cGF3d3eI9N3d3QsXLvS5YVJ7e7tOp7NYLG632ydl6H51SZKiKXymYm+dzltVVZV8xxA1n1QIbreb9T\/5f14+2bKUoT8jt9v9+OOPj7owkHZwJ+ks1d3d3dHRcf3113d0dMTkD95oNO7atctnmImP4uLiuXPn9vb2Kjeyp\/v27Tt+\/Li8cf\/+\/RRoDrLM7XZv2rQpuiJnsubm5h4Fo9G4fPnymNynSqPRXHfddf39\/cqQ43Q6BwYGBgYG2AfHHD9+fN++fTNmzAiR24EDB0RRjL5UkC4QcrIUGwZy\/\/33k+f6ngAajaaoqEiSJPna53K5JElas2ZNYWEhu9UF09vbO3fu3OLi4sQULOPdeeedDofj9ddfj0lupaWlBw4cUN71ymaz1dbW1tbWKn9PsA+0oqIiJieFzICQk41cLtfmzZuNRqPRaDSbzbt375Z\/sfo3hrClK+Q2LmW7TVtbmzKZsl2FtbmxZMrtJpPJ4XDI0aWrq8vhcEyfPr2kpMRms8nHSpJ03XXXaTQaZT5yM6DL5aqpqeno6GhtbZUzZyWXU8oFZjmsX7+eFTub2+L85za0t7cr29yULaUU\/C0tKysrLy+XB7Kyz2vGjBkzZsxQ\/p6w2Wzy7wbWiuvTytfe3l5TUzMwMFBZWSmflDW0Kj9uuSRr1qxhXwYMK09fCDnZqKur68CBA+xurSaTqaOj48CBA2oOlCSpsrKyrq6up6fnnXfe6e7uDnhgd3f37bffLncB1tXVVVZWsgtWWVlZYWGhXK\/q6+ubO3duWVnZddddJ1+t2HTj0tJSl8u1fPnyJUuWsHw6Ozs7Ojra29u1Wm1bW5vZbK6trWWteSwIEdE777zT09PT1tZWU1Oj7Ap68cUX169f39PT09DQEPX7l362bNliNpsjmmkf4i3VarVGo1H+pSLXZpT3\/HW73QMDA0VFRRqNxmq1DgwMsHzeeeedkpKSpqYmt9tdXV3d1tZWVFTU2dnJPher1drS0sKWStm7d69Pd90zzzzT0NDQ09ODCdHpCyEnG9lsNrPZXF5eTp5frHINIwTWfWI2m2+\/\/XYi0mg0jY2NLBMfW7ZsmTt37sMPP8ye3n777WbtcrBMAAAEgUlEQVSzedOmTW63W6PRlJSUsOYXt9u9e\/duVpthzS\/s4iXP\/WINQTfffDPLR6\/X+9TJZK+\/\/rrD4XjooYc0Gg0RGY3G2tpaq9Uq\/+KWF+DIEitWrFAOH2htbY00h9Bv6YwZM+TunP3795eUlBQXF7O+Olb7YR05JpOJ9RouXbqU5aPRaJYuXerTdcewlHV1deyT0mq1DQ0Nra2t8k8H+UsL6QshJ+uwP2x2oSfPL1Y1gwjcbnd\/f798IBGx+OGfTP55KyeTO5zZY1ahYVcl1trDRgqw2k9vb6\/RaNRqtdXV1Vu3btVqtXJrXsBLJwtdPn0\/Pi14oTuxM4\/P8IHm5ubW1lb1iyuGfUvlCg1LyT5u1lfHfhM4nU72u0Gv1+\/atctoNMrNdPKMCx\/s01f2\/fi04Cm\/VJCmEHKyzv79+wcGBpS\/gltbW33GGgXkc3s98gwH8EnGIlOIfOQKjfJOFnJbzYkTJ1jHACk6hCorK81mc09PT21tbbBsOzo6Zs+eLb+oYNe17HTzzTeXl5cHrCCGEOItlSs0cm2GbTeZTKwGY7PZSkpKWIRgHTmzZ8\/u7+\/fu3evsgvQB+vXkc84b948lU2+kC6ivZM0pBc2cKC2tlbZpeF2ux977LHdu3ezFrNg\/NetkCs0yo0Bqz4++RDR\/v375doM224ymaxW67Fjx8gTln77298S0d69e9Xc7cLnRcmwgi2p+FACCvaWkufXxu7duwsLC5V3wGJ9dceOHRsYGGAVYkmSWltb29ra1PQklZeXv\/jii\/4fd0SRElIZajnZRTlwQMYau4INIpCbNdhly2d4m3+Fxn8kNGt7kX\/zyhUauTbDsFD0P\/\/zP6xjgMUz+SjyjIzyL6GysU7e6DMWK8uxTypsw5RckVXzlppMpv7+\/v\/+7\/9WfkbsS\/LGG2\/09\/ez3w19fX1FRUXKKVbBOg79VxxWMyMY0gtCTnax2Wzl5eX+d2VlDS82m00OP6xrh91Vj6XRaDQPPfTQvn37tm3bxrb89re\/DRil2CwQVkchom3btik7kMkzTM7hcCgb7ouLi0tKStgQJrljQNnPrDwd2zswMMDiHxtiwMZBEW4G6Oe3v\/2tw+G48847fbazqzwbpuF2u9esWTMwMMB2hX1L2bdI2S9InljFms5YmCktLVU227JKj1wA+V715BkeUl9fL496X7Nmzdy5czFkIJMg5GQRNnAg4IVYOYigurrabDazJvWf\/\/znTz\/9tNx0ptfr169f39LSwpraT58+bTab\/U+k1+u3bdvGJvTodLrNmzfv3btX2a5SUFBQVFTk0zvNrlZEJFfCGhoa5JLodLoZM2Y0NzfLQYjFrdmzZ0uSxIZNExHre6isrHz66aez+eZMPiPWJEnatm2b\/5g9vV7\/9NNPs8SzZ8++44475A807FvKKjRFRUU+kz0rKiqKiorkJlOj0djW1iaXZ9OmTVu3biXPYAHWJ1RTU8PuoNPQ0MCG1LPyFBUVCYKAIQOZRNVtPQEAAKKHWg4AACQIQg4AACQIQg4AACTI\/wfJmu53LYSf4QAAAABJRU5ErkJggg==","width":550}
%---
