classdef BrainAP<single
	%表示小鼠脑的AP坐标，支持前囟和耳间两个参照系，支持基本数学运算。
	%此类值不支持直接构造，请使用FromBregma和FromInteraural两个静态函数构造BrainAP值
	%耳间坐标=前囟坐标+3.79
	properties(Dependent)
		%以前囟为参照的AP坐标
		Bregma
		%以耳间为参照的AP坐标
		Interaural
	end
	methods(Access=protected)
		function obj=BrainAP(Interaural)
			obj@single(Interaural);
		end
	end
	methods(Static)
		function obj=FromBregma(Bregma)
			%从前囟坐标转换为BrainAP
			%# 语法
			% ```
			% obj=UniExp.BrainAP.FromBregma(Bregma);
			% ```
			%# 输入参数
			% Bregma single，前囟坐标
			%# 返回值
			% obj BrainAP，数组尺寸与输入相同
			obj=UniExp.BrainAP(Bregma+3.79);
		end
		function obj=FromInteraural(Interaural)
			%从耳间坐标转换为BrainAP
			%# 语法
			% ```
			% obj=UniExp.BrainAP.FromInteraural(Interaural);
			% ```
			%# 输入参数
			% Interaural single，耳间坐标
			%# 返回值
			% obj BrainAP，数组尺寸与输入相同
			obj=UniExp.BrainAP(Interaural);
		end
	end
	methods
		function obj=get.Bregma(obj)
			obj=single(obj)-3.79;
		end
		function obj=get.Interaural(obj)
			obj=single(obj);
		end
		function obj=set.Bregma(~,Bregma)
			obj=UniExp.BrainAP.FromBregma(Bregma);
		end
		function obj=set.Interaural(~,Interaural)
			obj=UniExp.BrainAP(Interaural);
		end
		function Strings=string(obj)
			obj=single(obj);
			Logical=obj<1.895;
			Strings=strings(size(obj));
			Strings(Logical)=compose("Interaural%+.3f",obj(Logical));
			Logical=~Logical;
			Strings(Logical)=compose("Bregma%+.3f",obj(Logical)-3.79);
		end
		function obj=char(obj)
			obj=cellstr(obj.string);
		end
		function obj=plus(obj1,obj2)
			obj=UniExp.BrainAP(single(obj1)+single(obj2));
		end
		function obj=minus(obj1,obj2)
			obj=UniExp.BrainAP(single(obj1)-single(obj2));
		end
		function obj=times(obj1,obj2)
			obj=UniExp.BrainAP(single(obj1).*single(obj2));
		end
		function obj=mtimes(obj1,obj2)
			obj=UniExp.BrainAP(single(obj1)*single(obj2));
		end
		function obj=rdivide(obj1,obj2)
			obj=UniExp.BrainAP(single(obj1)./single(obj2));
		end
		function obj=mrdivide(obj1,obj2)
			obj=UniExp.BrainAP(single(obj1)/single(obj2));
		end
		function obj=mean(obj,varargin)
			obj=UniExp.BrainAP(mean(single(obj),varargin{:}));
		end
		function disp(obj)
			disp(obj.string);
		end
		function obj=subsref(obj,S)
			switch S.type
				case "()"
					obj=single(obj);
					obj=UniExp.BrainAP(obj(S.subs{:}));
				case "."
					obj=obj.(S.subs);
				otherwise
					UniExp.UniExpException.Unexpected_subsref_type.Throw;
			end
		end
		function obj=subsasgn(obj,S,V)
			obj=single(obj);
			obj(S.subs{:})=V;
			obj=UniExp.BrainAP(obj);
		end
		function obj=cat(Dimension,varargin)
			varargin=cellfun(@single,varargin,UniformOutput=false);
			obj=UniExp.BrainAP(cat(Dimension,varargin{:}));
		end
		function obj=vertcat(varargin)
			obj=cat(1,varargin{:});
		end
		function obj=horzcat(varargin)
			obj=cat(2,varargin{:});
		end
	end
end