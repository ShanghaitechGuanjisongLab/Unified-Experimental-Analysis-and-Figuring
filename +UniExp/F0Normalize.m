%[text] 截取信号中的一段作为基线，执行归一化
%[text] 对于一个刺激的响应信号，我们通常关心刺激后与刺激前（基线）的变化关系，因此需要根据基线进行归一化。本函数还会顺便对无穷大和NaN信号执行插值消除。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] Data=UniExp.F0Normalize(Data,Method,F0Index);
%[text] ```
%[text] ## 示例
%[text] ```matlabCodeExample
%[text] Data=UniExp.F0Normalize(Data,UniExp.Flags.log2FdF0,1:30);
%[text] %以数据的前30个采样值的均值作为F0，计算log2(F/F0)为归一化数据
%[text] ```
%[text] ## 输入参数
%[text] Data(:,:)，信号数据矩阵，第1维是不同的重复，第2维是时间
%[text] Method(1,1)UniExp.Flags，归一化方法，可选以下枚举值：
%[text] - No\_special\_operation，不执行归一化
%[text] - dFdF0，将基线均值记为$F\_0${"editStyle":"visual"}，计算$\\frac{F}{F\_0 }-1${"editStyle":"visual"}为归一化数据
%[text] - log2FdF0，将基线均值记为$F\_0${"editStyle":"visual"}，计算$\\log\_2 \\frac{F}{F\_0 }${"editStyle":"visual"}为归一化数据
%[text] - ZScore，将基线均值记为μ，标准差记为σ，计算$\\frac{F-\\mu }{\\sigma }${"editStyle":"visual"}为归一化数据
%[text] - DeltaF，将基线均值记为$F\_0${"editStyle":"visual"}，计算$F-F\_0${"editStyle":"visual"}为归一化数据 \
%[text] F0Index(1,:)uint8，基线时点索引
%[text] ## 返回值
%[text] Data(:,:)，归一化后的数据矩阵，尺寸与输入相同
function Data = F0Normalize(Data,Method,F0Index)
import UniExp.Flags
switch Method
	case Flags.No_special_operation
	case Flags.dFdF0
		Data=Data./mean(Data(:,F0Index),2,'omitmissing')-1;
	case Flags.log2FdF0
		Data=log2(Data./mean(Data(:,F0Index),2,'omitmissing'));
	case Flags.ZScore
		Base=Data(:,F0Index);
		Data=(Data-mean(Base,2,'omitmissing'))./std(Base,0,2,'omitmissing');
	case Flags.DeltaF
		Data=Data-mean(Data(:,F0Index),2,'omitmissing');
	otherwise
		UniExp.Exceptions.Unknown_normalize_algorithm.Throw;
end
Insane=isinf(Data)|isnan(Data);
InfIndex=find(any(Insane,2));
for T=1:numel(InfIndex)
	Index=InfIndex(T);
	Logical=Insane(Index,:);
	xq=find(Logical);
	Logical=~Logical;
	Data(Index,xq)=interp1(find(Logical),Data(Index,Logical),xq);
end
end

%[appendix]{"version":"1.0"}
%---
