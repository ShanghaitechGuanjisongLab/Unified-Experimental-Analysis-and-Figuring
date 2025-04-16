function Table=TableCategorize(Table)
for C=string(Table.Properties.VariableNames)
	Column=Table.(C);
	if isstring(Column)&&all(strlength(Column)<11)
		Table.(C)=categorical(Column);
	end
end
end