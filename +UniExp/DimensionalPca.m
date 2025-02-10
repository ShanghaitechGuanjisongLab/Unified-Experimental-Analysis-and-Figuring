%[text] 对多维数组沿指定维度执行PCA分析
%[text] 此函数将多维数组的某些维度视为采样，某些维度视为变量，执行PCA分析，方便观察各采样在高维空间中的投影，并通过PCA系数得知每个变量的权重。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] [Coeff,Score,Explained] = UniExp.DimensionalPca(Array,Dimensions)
%[text] %对数组Array在Dimension维度上执行PCA分析
%[text] 
%[text] [Coeff,Score,Explained] = UniExp.DimensionalPca(Array,Dimensions,NumComponents)
%[text] %额外指定要计算的主成分个数。按需指定较小值可以改善性能。
%[text] ```
%[text] ## 示例
%[text] ```matlabCodeExample
%[text] Array=rand(4,4,4,4);
%[text] 
%[text] %在第1、4维采样，第2、3维是变量
%[text] [Coeff,Score,Explained] = UniExp.DimensionalPca(Array,[false,true,true,false],4);
%[text] 
%[text] %可以使用tensorprod将同样变量的其它采样数据投影到同样Coeff指定的PCA空间。此处示例用原本数据重新计算Score，需要分别指定Array和Coeff的变量维度做张量积，然后比较误差。
%[text] max(Score-tensorprod(Array,Coeff,[2,3],[1,2]),[],'all')
%[text] 
%[text] %{
%[text] ans =
%[text] 
%[text]    2.4147e-15
%[text] %}
%[text] %会存在非常小的机器精度误差
%[text] ```
%[text] ## 输入参数
%[text] Array，输入数组
%[text] Dimensions(1,:)logical，依次指定Array的每个维度视为采样还是变量。true表示变量，false表示采样。如指定的少于Array的维度数，后续维度一律视为采样维度。
%[text] NumComponents(1,1)uint16，要返回的主成分个数。默认尽可能返回所有机器精度以内的主成分。
%[text] ## 返回值
%[text] Coeff，PCA系数，表示各变量对各主成分的贡献。最后一个维度是主成分，前面依次排列各变量维度。
%[text] Score，PCA分数，表示各采样在各主成分上的分量。最后一个维度是主成分，前面依次排列各采样维度。
%[text] Explained(:,1)，各主成分解释的方差百分比，从大到小排列。
%[text] **See also** [pca](<matlab:doc pca>) [tensorprod](<matlab:doc tensorprod>)
function [Coeff,Score,Explained] = DimensionalPca(Array,Dimensions,NumComponents)
VariableDimensions=find(Dimensions);
VariableSizes=size(Array,VariableDimensions);
SampleDimensions=setdiff(1:max(ndims(Array),numel(Dimensions)),VariableDimensions);
SampleSizes=size(Array,SampleDimensions);
Array=reshape(permute(Array,[SampleDimensions,VariableDimensions]),prod(SampleSizes),prod(VariableSizes));
if nargin<3
	[Coeff,Score,~,~,Explained]=pca(Array,Centered=false);
	NumComponents=numel(Explained);
else
	[Coeff,Score,~,~,Explained]=pca(Array,NumComponents=NumComponents,Centered=false);
	Explained=Explained(1:NumComponents);
end
Coeff=reshape(Coeff,[VariableSizes,NumComponents]);
Score=reshape(Score,[SampleSizes,NumComponents]);
end

%[appendix]{"version":"1.0"}
%---
