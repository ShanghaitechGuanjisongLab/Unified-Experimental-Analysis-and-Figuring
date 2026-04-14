%[text] 对NTATS数据，将所有参与细胞的信号主成分分析，生成主成分空间中的典型时间曲线图。主成分是细胞的加权和。
%[text] 注意，本函数只生成作图所需数据，本身并不作图，你需要另外使用作图函数，例如SegmentFadePlot。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] PcaTable = UniExp.LinearPca(NTATS);
%[text] %对NTATS执行完全PCA分析
%[text] 
%[text] PcaTable = UniExp.LinearPca(NTATS,NumComponents);
%[text] %只计算前几个成分，速度更快
%[text] 
%[text] PcaTable = UniExp.LinearPca(___,Centered);
%[text] %与上述任意语法组合使用，额外指定是否中心化
%[text] ```
%[text] ## 输入参数
%[text] NTATS(:,:,:)MATLAB.DataTypes.NDTable，作图数据，第1维细胞，第2维时间，第3维分组。可在NTATS.Dimensions.IndexNames{3}中指定分组名称。一般应从QueryNTATS的返回值中取得。
%[text] NumComponents(1,1)uint8，只计算前几个成分，可提高性能。
%[text] Centered=false，是否中心化，参见内置pca的Centered参数，本函数直接转发
%[text] ## 返回值
%[text] #### PcaTable(:,3)table
%[text] 每行对应一个主成分，包含以下列：
%[text] Explained(:,1)double，指示每个主成分解释了多少比例的方差
%[text] Coeff(:,:)double，PCA系数，指示每个细胞在每个主成分中贡献的权重，第2维是细胞，顺序和输入的NTATS相同
%[text] Score(:,:,:)MATLAB.DataTypes.NDTable，主成分分数，第2维时间，第3维分组。如果NTATS中包含分组名称，Score中也将保留这些名称。
%[text] **See also** [UniExp.SegmentFadePlot](<matlab:doc UniExp.SegmentFadePlot>) [UniExp.DataSet.QueryNTATS](matlab:MATLAB.Doc('UniExp.DataSet.QueryNTATS'))
function PcaTable = LinearPca(NTATS,varargin)
NumComponents={};
Centered={};
for V=1:numel(varargin)
	if islogical(varargin{V})
		Centered={'Centered',varargin{V}};
	else
		NumComponents={'NumComponents',varargin{V}};
	end
end
[NumCells,NumGroups]=size(NTATS,1,3);
[Coeff,PcaLines,~,~,Explained]=pca(reshape(NTATS.Data,NumCells,[])',NumComponents{:},Centered{:});
if isempty(NumComponents)
	Coeff=Coeff.';
	PcaTable=table(Explained,Coeff);
else
	PcaTable=table(Explained(1:NumComponents{2}),Coeff.','VariableNames',["Explained","Coeff"]);
end
PcaLines=PcaLines';
NumComponents=height(PcaLines);
NTATS.Data=reshape(PcaLines,NumComponents,[],NumGroups);
NTATS.Dimensions.DimensionName(1)="主成分";
PcaTable.Score=NTATS;
PcaTable.Properties.DimensionNames(1)="主成分";
end

%[appendix]{"version":"1.0"}
%---
