function Var=UpdateMerge(Var,WarnConflict)
arguments
	Var
	WarnConflict=false
end
if iscell(Var)
	Var(cellfun(@(V)isempty(V)||isequaln(V,missing),Var))=[];
	IsStruct=cellfun(@isstruct,Var);
	if any(IsStruct)
		FieldValues=flipud(cellfun(@(S){fieldnames(S),struct2cell(S)},Var(IsStruct),UniformOutput=false));
		FieldValues=vertcat(FieldValues{:});
		[Names,Index]=unique(vertcat(FieldValues{:,1}));
		Values=vertcat(FieldValues{:,2});
		Merge=cell2struct(Values(Index),Names,1);
		if isfield(Merge,'Miscellany')
			Miscellany=[Var(~IsStruct);Merge.Miscellany];
		else
			Miscellany=Var(~IsStruct);
		end
		if ~isempty(Miscellany)
			Merge.Miscellany=MATLAB.Ops.UniqueN(Miscellany,1);
		end
		Var={Merge};
	elseif isempty(Var)
		Var={[]};
	else
		if WarnConflict&&~isscalar(Var)
			[~,WarnID]=lastwarn;
			if WarnID~="UniExp:Exception:UpdateMerge_found_conflict_values"&&~isequaln(Var(1:end-1),Var(2:end))
				UniExp.Exception.UpdateMerge_found_conflict_values.Warn;
			end
		end
		Var=Var(end);
	end
elseif isinteger(Var)
	Index=find(Var,1,'last');
	if isempty(Index)
		Var=Var(end);
	else
		Var=Var(Index);
	end
else
	%兼容表格和列向量的写法，ismissing对表格操作的结果是二维数组
	if WarnConflict
		LastNonMissing=find(~all(ismissing(Var),2));
		if isempty(LastNonMissing)
			Var=Var(end,:);
		else
			Var=Var(LastNonMissing,:);
			if~isscalar(LastNonMissing)
				if~isequaln(Var(1:end-1),Var(2:end))
					UniExp.Exception.UpdateMerge_found_conflict_values.Warn;
				end
				Var=Var(end,:);
			end
		end
	else
		LastNonMissing=find(~all(ismissing(Var),2),1,'last');
		if isempty(LastNonMissing)
			Var=Var(end,:);
		else
			Var=Var(LastNonMissing,:);
		end
	end
end
end