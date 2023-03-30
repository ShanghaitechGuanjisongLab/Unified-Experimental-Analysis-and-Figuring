classdef Query<handle
	%保存一个查询，以便下次快速查看
	properties(SetAccess=immutable)
		%此查询绑定的数据库
		DataSet

		%此查询结果表的列名
		Columns

		%此查询的条件结构
		Where
	end
	properties(Dependent)
		%获取查询结果视图
		View
	end
	methods
		function obj = Query(DataSet,Columns,Where)
			%构造UniExp.Query对象
			%此对象还可以从UniExp.DataSet.TableQuery方法获取
			%# 语法
			% ```
			% obj=UniExp.Query(DataSet,Columns,Where);
			% ```
			%# 输入参数
			% DataSet(1,1)UniExp.DataSet，此查询绑定的数据库
			% Columns(1,:)string，此查询结果表的列名
			% Where(1,1)struct，此查询的条件结构
			%See also UniExp.DataSet UniExp.DataSet.TableQuery
			arguments
				DataSet
				Columns
				Where=struct
			end
			obj.DataSet=DataSet;
			obj.Columns=Columns;
			obj.Where=Where;
		end
		function V=get.View(obj)
			V=obj.DataSet.TableQuery(obj.Columns,obj.Where);
		end
	end
end