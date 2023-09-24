function Table=TableCategorize(Table)
for C=string(Table.Properties.VariableNames)
	if isstring(Table.(C))
		Table.(C)=categorical(Table.(C));
	end
end
end