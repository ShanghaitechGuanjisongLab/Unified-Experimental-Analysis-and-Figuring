%[text] 对两组 ImageJ RoiSet 进行集合运算
%[text] 设两 ROI 的圆心距离为 $d$；每个 ROI 的半轴由其外接矩形得到：
%[text] $r=\\sqrt{a,b}$（$a,b$ 为长/短半轴）；若 $d \< \\sqrt{r\_1 r\_2}$，视为相同。因此，可能会有来自两边的多个ROI被视为相同。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] Operations=UniExp.ImageJRoiSetOperations(RoiAPath,RoiBPath,Operations);
%[text] ```
%[text] ## 输入参数
%[text] #### RoiAPath(1,1)string
%[text] 第一个 ROI/ZIP 文件路径（左侧集合）
%[text] #### RoiBPath(1,1)string
%[text] 第二个 ROI/ZIP 文件路径（右侧集合）
%[text] #### Operations table
%[text] 要执行的操作，包含以下列：
%[text] Operation(:,1)UniExp.Flags，必须，可以是
%[text] - Union，输出两个ROI集合的并集。相同的ROI会被合并，输出ROI的圆心是所有相同ROI圆心的均值点，XY半轴是对应半轴在所有相同ROI中的的较大值
%[text] - Intersect，输出两个ROI集合的交集。相同的ROI会被合并，输出ROI的圆心是所有相同ROI圆心的中点，XY半轴是对应半轴在所有相同ROI中的的较大值
%[text] - ADiffB，从A中排除与B相同的ROI
%[text] - BDiffA，中排除与A相同的ROI \
%[text] OutputPath，可选，该操作输出的文件路径。如不指定，将输出RoiAPath同目录下，下并使用默认文件名。
%[text] ## 返回值
%[text] Operations table，与输入相同，但如果输入未指定OutputPath，则输出时会附加这一列，包含每个操作输出的路径信息。
%[text] **See also** [union](<matlab:doc union>) [intersect](<matlab:doc intersect>) [setdiff](<matlab:doc setdiff>)
function Operations = ImageJRoiSetOperations(RoiAPath, RoiBPath, Operations)
if ~ismember("OutputPath", Operations.Properties.VariableNames)
	Operations.OutputPath = strings(height(Operations),1);
end
Operations.OutputPath = string(Operations.OutputPath);

[~, aStem] = fileparts(RoiAPath);
[~, bStem] = fileparts(RoiBPath);
baseName = aStem + "_vs_" + bStem;

% 默认输出目录：RoiAPath 所在目录（若为空则回退到 pwd）
roiADir = string(fileparts(RoiAPath));
if roiADir==""
	roiADir = string(pwd);
end

% 读取几何信息（通过 internal.ImageJRoiReadout 间接使用 ReadImageJROI）
% 注意：本函数忽略 Z，统一按单层处理。
[Ac, Ar] = UniExp.internal.ImageJRoiReadout(adaptForReadout(RoiAPath));
[Bc, Br] = UniExp.internal.ImageJRoiReadout(adaptForReadout(RoiBPath));

% 读取 ROI 条目名称与数量（用于输出 zip 的 entry name 与一致性校验）
Ameta = readRoiNamePayload(RoiAPath);
Bmeta = readRoiNamePayload(RoiBPath);

% 空集快速返回：仍然回填 OutputPath=""（不写文件）
if Ameta.Count==0 && Bmeta.Count==0
	Operations.OutputPath(:) = "";
	return;
end

% 计算每个 ROI 的有效半径 r = sqrt(longAxis * shortAxis)
ArEff = effectiveRadius(Ar);
BrEff = effectiveRadius(Br);

% 构建所有满足阈值的候选匹配对，并允许多对多：按阈值关系构造二部图，取连通分量作为“相同 ROI 组”。
[grpA, grpB, isAHit, isBHit] = componentGroups(Ac, ArEff, Bc, BrEff);

idxAOnly = find(~isAHit);
idxBOnly = find(~isBHit);

for row = 1:height(Operations)
	op = Operations.Operation(row);
	defaultFile = defaultFilenameFor(op, baseName);
	outPath = defaultOutputPath(Operations.OutputPath(row), defaultFile, roiADir);
	
	switch op
		case UniExp.Flags.ADiffB
			[names, bytesCell] = buildOvalPayload(Ameta.Name, Ac, Ar, idxAOnly, "A");
		case UniExp.Flags.BDiffA
			[names, bytesCell] = buildOvalPayload(Bmeta.Name, Bc, Br, idxBOnly, "B");
		case UniExp.Flags.Intersect
			[names, bytesCell] = buildMergedPayload(Ac, Ar, Bc, Br, grpA, grpB, "intersect_");
		case UniExp.Flags.Union
			[names, bytesCell] = buildUnionPayload(Ameta.Name, Ac, Ar, idxAOnly, Bmeta.Name, Bc, Br, idxBOnly, grpA, grpB);
	end
	
	Operations.OutputPath(row) = writeZipBytesOrEmpty(outPath, names, bytesCell);
end


% ========================
% local functions
% ========================
	function rEff = effectiveRadius(Rxy)
		% Rxy: [height/2, width/2]
		if isempty(Rxy)
			rEff = zeros(0,1);
			return;
		end
		semiY = max(Rxy(:,1), 0);
		semiX = max(Rxy(:,2), 0);
		longAxis = max(semiX, semiY);
		shortAxis = min(semiX, semiY);
		rEff = sqrt(longAxis .* shortAxis);
	end

	function x = adaptForReadout(path)
		% UniExp.internal.ImageJRoiReadout 假设 ReadImageJROI 返回 cell array；
		% 但 ReadImageJROI 对单个 .roi 会返回 struct。
		% 这里对 .roi 用 cell 包装，确保 readout 可用。
		[~,~,ext] = fileparts(path);
		if lower(string(ext))==".roi"
			x = {char(path)};
		else
			x = path;
		end
	end

	function outPath = defaultOutputPath(userPath, defaultFile, baseDir)
		if baseDir==""
			baseDir = string(pwd);
		end
		if userPath==""
			outPath = fullfile(baseDir, defaultFile);
			return;
		end
		[dirPart, ~, extPart] = fileparts(userPath);
		if extPart==""
			% 用户可能只给了目录；按默认文件名补全
			if isfolder(userPath)
				outPath = fullfile(userPath, defaultFile);
			else
				outPath = userPath + ".zip";
			end
			return;
		end
		if dirPart==""
			outPath = fullfile(baseDir, userPath);
		else
			outPath = userPath;
		end
	end

	function [grpA, grpB, isAHitLocal, isBHitLocal] = componentGroups(Acxy, ArE, Bcxy, BrE)
		nA = size(Acxy,1);
		nB = size(Bcxy,1);
		grpA = cell(0,1);
		grpB = cell(0,1);
		isAHitLocal = false(nA,1);
		isBHitLocal = false(nB,1);
		if nA==0 || nB==0
			return;
		end
		
		% 张量化计算候选关系：mask(i,j)=true 表示 A(i) 与 B(j) 被视为“相同”。
		Ax = double(Acxy(:,1));
		Ay = double(Acxy(:,2));
		Bx = double(Bcxy(:,1)).';
		By = double(Bcxy(:,2)).';
		D = hypot(Ax - Bx, Ay - By); % nA x nB
		T = sqrt(max(double(ArE),0) .* max(double(BrE),0).'); % nA x nB
		mask = (T > 0) & (D < T);
		if ~any(mask, 'all')
			return;
		end

		% 多对多：用阈值关系构造二部图，连通分量即为“相同 ROI 组”。
		[iA, iB] = find(mask);
		s = double(iA);
		t = double(nA + iB);
		G = graph(s, t, [], nA+nB);
		bins = conncomp(G); % 1 x (nA+nB)
		bins = bins(:);
		cidA = bins(1:nA);
		cidB = bins(nA+1:end);
		k = max(bins);
		hasA = accumarray(cidA, true, [k,1], @any, false);
		hasB = accumarray(cidB, true, [k,1], @any, false);
		both = hasA & hasB;

		isAHitLocal = both(cidA);
		isBHitLocal = both(cidB);
		compIds = find(both);
		if isempty(compIds)
			return;
		end
		grpA = arrayfun(@(id) int32(find(cidA==id)), compIds, 'UniformOutput', false);
		grpB = arrayfun(@(id) int32(find(cidB==id)), compIds, 'UniformOutput', false);
	end

	function [names, bytesCell] = buildUnionPayload(aNames, Acxy, Arxy, idxAOnlyLocal, bNames, Bcxy, Brxy, idxBOnlyLocal, grpALocal, grpBLocal)
		% 所有输出 ROI 一律生成为椭圆（Oval）。
		% Union: (A-only oval) + (B-only oval) + (same-group -> merged oval)
		nameSet = containers.Map('KeyType','char','ValueType','logical');
		nTotal = numel(idxAOnlyLocal) + numel(idxBOnlyLocal) + numel(grpALocal);
		names = strings(nTotal,1);
		bytesCell = cell(nTotal,1);
		p = 0;
		
		for ii = 1:numel(idxAOnlyLocal)
			idx = idxAOnlyLocal(ii);
			[entryName, roiBytes] = ovalEntryFromIndex(aNames, Acxy, Arxy, idx, "A", nameSet);
			p = p + 1;
			names(p,1) = entryName;
			bytesCell{p,1} = roiBytes;
		end
		for ii = 1:numel(idxBOnlyLocal)
			idx = idxBOnlyLocal(ii);
			[entryName, roiBytes] = ovalEntryFromIndex(bNames, Bcxy, Brxy, idx, "B", nameSet);
			p = p + 1;
			names(p,1) = entryName;
			bytesCell{p,1} = roiBytes;
		end
		for ii = 1:numel(grpALocal)
			roiBytes = makeMergedOvalRoiBytesForGroup(Acxy, Arxy, Bcxy, Brxy, grpALocal{ii}, grpBLocal{ii});
			base = "union_" + ii + ".roi";
			entryName = makeUniqueRoiEntryName(base, nameSet);
			p = p + 1;
			names(p,1) = entryName;
			bytesCell{p,1} = roiBytes;
		end
	end

	function [names, bytesCell] = buildMergedPayload(Acxy, Arxy, Bcxy, Brxy, grpALocal, grpBLocal, prefix)
		% 对每个“相同 ROI 组”生成一个合并椭圆 ROI。
		nameSet = containers.Map('KeyType','char','ValueType','logical');
		n = numel(grpALocal);
		names = strings(n,1);
		bytesCell = cell(n,1);
		for ii = 1:n
			roiBytes = makeMergedOvalRoiBytesForGroup(Acxy, Arxy, Bcxy, Brxy, grpALocal{ii}, grpBLocal{ii});
			base = prefix + ii + ".roi";
			entryName = makeUniqueRoiEntryName(base, nameSet);
			names(ii,1) = entryName;
			bytesCell{ii,1} = roiBytes;
		end
	end

	function roiBytes = makeMergedOvalRoiBytesForGroup(Acxy, Arxy, Bcxy, Brxy, idxAGroup, idxBGroup)
		% “相同 ROI”的合并规则（Union/Intersect 完全一致）：
		% 圆心取所有相同 ROI 圆心的中点（用均值实现）；XY 半轴长取对应半轴在组内的较大值。
		idxAGroup = idxAGroup(:);
		idxBGroup = idxBGroup(:);
		allC = [Acxy(double(idxAGroup),:); Bcxy(double(idxBGroup),:)];
		newC = mean(allC, 1);
		newSemiY = max([Arxy(double(idxAGroup),1); Brxy(double(idxBGroup),1)]);
		newSemiX = max([Arxy(double(idxAGroup),2); Brxy(double(idxBGroup),2)]);
		roiBytes = makeOvalRoiBytes(newC, [newSemiY, newSemiX], 1);
	end

	function [names, bytesCell] = buildOvalPayload(originalNames, CxyAll, RxyAll, indices, prefix)
		nameSet = containers.Map('KeyType','char','ValueType','logical');
		n = numel(indices);
		names = strings(n,1);
		bytesCell = cell(n,1);
		for ii = 1:n
			idx = indices(ii);
			[entryName, roiBytes] = ovalEntryFromIndex(originalNames, CxyAll, RxyAll, idx, prefix, nameSet);
			names(ii,1) = entryName;
			bytesCell{ii,1} = roiBytes;
		end
	end

	function [entryName, roiBytes] = ovalEntryFromIndex(originalNames, CxyAll, RxyAll, idx, prefix, nameSet)
		candidate = originalNames(idx);
		if ~endsWith(lower(candidate), ".roi")
			candidate = candidate + ".roi";
		end
		if candidate==".roi" || candidate==""
			candidate = prefix + "_" + idx + ".roi";
		end
		entryName = makeUniqueRoiEntryName(candidate, nameSet);
		roiBytes = makeOvalRoiBytes(CxyAll(idx,:), RxyAll(idx,:), 1);
	end

	function uniqueName = makeUniqueRoiEntryName(candidate, nameSet)
		uniqueName = candidate;
		key = char(lower(uniqueName));
		if ~isKey(nameSet, key)
			nameSet(key) = true; %#ok<NASGU>
			return;
		end
		[dirPart, stemPart, extPart] = fileparts(uniqueName);
		if extPart==""
			extPart = ".roi";
		end
		counter = 1;
		while true
			if dirPart==""
				trial = stemPart + "_" + counter + extPart;
			else
				trial = string(dirPart) + filesep + stemPart + "_" + counter + extPart;
			end
			trialKey = char(lower(trial));
			if ~isKey(nameSet, trialKey)
				nameSet(trialKey) = true; %#ok<NASGU>
				uniqueName = trial;
				return;
			end
			counter = counter + 1;
		end
	end

	function bytes = makeOvalRoiBytes(Cxy, Rxy, zPos)
		% 生成一个最小可读的 ImageJ Oval ROI（二进制 .roi），用于并集中的“合并 ROI”。
		% 仅保证 vnRectBounds 与 nPosition 与期望一致；其他高级字段留空。
		Cx = double(Cxy(1));
		Cy = double(Cxy(2));
		semiY = max(double(Rxy(1)), 0);
		semiX = max(double(Rxy(2)), 0);
		width = max(0, round(2*semiX));
		roiHeight = max(0, round(2*semiY));
		left = round(Cx - 0.5 - width/2);
		right = left + width;
		top = round(Cy - 0.5 - roiHeight/2);
		bottom = top + roiHeight;
		
		left = clampInt16(left);
		right = clampInt16(right);
		top = clampInt16(top);
		bottom = clampInt16(bottom);
		zPos = max(0, round(double(zPos)));
		
		bytes = uint8([]);
		bytes = [bytes, uint8('Iout')];
		bytes = [bytes, packInt16BE(217)]; % 版本号（<218，避免额外字段依赖）
		bytes = [bytes, uint8(2), uint8(0)]; % type=Oval, padding
		bytes = [bytes, packInt16BE([top, left, bottom, right])];
		bytes = [bytes, packUInt16BE(0)]; % nNumCoords
		bytes = [bytes, packSingleBE([0 0 0 0])]; % vfLinePoints
		bytes = [bytes, packInt16BE(0)]; % nStrokeWidth
		bytes = [bytes, packUInt32BE(0)]; % nShapeROISize
		bytes = [bytes, packUInt32BE(0)]; % nStrokeColor
		bytes = [bytes, packUInt32BE(0)]; % nFillColor
		bytes = [bytes, packInt16BE(0)]; % nROISubtype
		bytes = [bytes, packInt16BE(0)]; % nOptions
		bytes = [bytes, uint8(0), uint8(0)]; % arrow style, head size
		bytes = [bytes, packInt16BE(0)]; % rounded rect arc size
		bytes = [bytes, packUInt32BE(uint32(zPos))]; % nPosition
		bytes = [bytes, packUInt32BE(0)]; % header2 offset
	end

	function v = clampInt16(x)
		v = int16(max(min(double(x), double(intmax('int16'))), double(intmin('int16'))));
	end

	function b = packInt16BE(x)
		b = typecast(swapbytes(int16(x(:).')), 'uint8');
	end

	function b = packUInt16BE(x)
		b = typecast(swapbytes(uint16(x(:).')), 'uint8');
	end

	function b = packUInt32BE(x)
		b = typecast(swapbytes(uint32(x(:).')), 'uint8');
	end

	function b = packSingleBE(x)
		b = typecast(swapbytes(single(x(:).')), 'uint8');
	end

	function payload = readRoiNamePayload(path)
		payload = struct('Name', strings(0,1), 'Count', 0);
		[~, stem, ext] = fileparts(path);
		ext = lower(string(ext));
		if ext==".roi"
			payload.Name = stem + ".roi";
			payload.Count = 1;
			return;
		end

		% 对非 .roi（包括未知扩展名）：先当作 zip 尝试列出 ROI；失败再当作 roi。
		try
			roiNames = listZipRoiEntryNames(path);
			payload.Name = roiNames;
			payload.Count = numel(roiNames);
			return;
		catch
			% ignore and fallback
		end

		if isRoiFile(path)
			payload.Name = stem + ".roi";
			payload.Count = 1;
			return;
		end
	end

	function tf = isRoiFile(path)
		% 最小校验：前 4 字节必须为 'Iout'
		fid = fopen(char(path), 'rb');
		if fid < 0
			tf = false;
			return;
		end
		cleanup = onCleanup(@() fclose(fid));
		magic = fread(fid, 4, '*uint8');
		tf = numel(magic)==4 && all(magic(:).' == uint8('Iout'));
	end

% readAllBytesFromFile 已不再需要：所有输出 ROI 均由几何信息重写生成。

	function names = listZipRoiEntryNames(zipPath)
		% 复刻 ReadImageJROI 内部 listzipcontents_rois 的行为：
		% 用 Java ZipInputStream 顺序遍历，过滤 .roi 且排除 __MACOSX。
		import java.util.zip.ZipInputStream
		import java.io.FileInputStream
		zis = ZipInputStream(FileInputStream(char(zipPath)));
		cleanup = onCleanup(@() zis.close());
		entry = zis.getNextEntry();
		builder = MATLAB.DataTypes.ArrayBuilder(1);
		while (entry ~= 0)
			name = string(entry.getName());
			if endsWith(lower(name), ".roi") && ~startsWith(name, "__MACOSX")
				builder.Append(name);
			end
			entry = zis.getNextEntry();
		end
		names = builder.Harvest();
	end

	function outPath = writeZipBytesOrEmpty(outPath, names, bytesCell)
		if isempty(names)
			outPath = "";
			return;
		end
		if isfile(outPath)
			delete(outPath);
		end
		outDirLocal = string(fileparts(outPath));
		if outDirLocal~="" && ~isfolder(outDirLocal)
			mkdir(outDirLocal);
		end

		% 统一使用 Java 写入 ZIP（避免混用 .NET 与 Java）。
		import java.io.FileOutputStream
		import java.util.zip.ZipOutputStream
		import java.util.zip.ZipEntry
		
		fos = FileOutputStream(char(outPath));
		zos = ZipOutputStream(fos);
		cleanup = onCleanup(@() localCloseZip(zos, fos));
		
		for kk = 1:numel(names)
			entryName = names(kk);
			bytes = uint8(bytesCell{kk});
			ze = ZipEntry(char(entryName));
			zos.putNextEntry(ze);
			b = int8(bytes(:));
			zos.write(b, 0, numel(b));
			zos.closeEntry();
		end
	end

	function localCloseZip(zos, fos)
		% 尽量释放句柄，避免文件锁死
		try
			if ~isempty(zos)
				zos.close();
			end
		catch
		end
		try
			if ~isempty(fos)
				fos.close();
			end
		catch
		end
	end

	function defaultFile = defaultFilenameFor(op, base)
		switch op
			case UniExp.Flags.ADiffB
				defaultFile = base + "_A_minus_B.zip";
			case UniExp.Flags.BDiffA
				defaultFile = base + "_B_minus_A.zip";
			case UniExp.Flags.Union
				defaultFile = base + "_A_union_B.zip";
			case UniExp.Flags.Intersect
				defaultFile = base + "_A_intersect_B.zip";
			otherwise
				defaultFile = base + "_output.zip";
		end
	end

end

%[appendix]{"version":"1.0"}
%---
