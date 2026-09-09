%[text] 批量配准 Olympus OIR 文件并转码为OME-TIFF格式，自动排除电流检测（Current Detector, CD）通道
%[text] 显微镜拍摄出的OIR视频往往存在晃动，需要配准并写出为TIFF文件。此外常用CD通道打标，不是有效的视频通道，将每个时点平均化输出单个值，作为BlockTags，写出为UniExp数据文件。本函数负责在文件内执行平移配准，并输出CD通道每个时间Cycle平均值，写出UniExp文件和每个文件内配准后的平均值图像，可用于下一步的文件间配准
%[text] 原则上，所有文件的XY尺寸必须一致。此函数性能关键，包含大量名称值参数用于调节各种行为，确保程序稳定高效运行，请仔细阅读名称值参数说明文档。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] UniExp.BatchOirRegisterTiff(OirPaths,OutputDirectory,Name=Value);
%[text] ```
%[text] ## 示例
%[text] ```matlabCodeExample
%[text] %选择输入输出。
%[text] MovingPaths=MATLAB.UITools.OpenFileDialog(Filter='Olympus OIR|*.oir',Multiselect=true,Title='选择要配准的 Olympus OIR 文件');
%[text] OutputDirectory=uigetdir('.','选择输出目录');
%[text] 
%[text] %执行文件内配准
%[text] UniExp.BatchOirRegisterTiff(MovingPaths,OutputDirectory,BlockSize=35,MemoryPreserve=1,UseGpu=1:4,CacheDirectory="D:\缓存",BaseRegisterToDisk=false);
%[text] %如果所有文件都输出完毕，程序却不结束，请检查是否有弹出对话框被压在下面等待确认。
%[text] %此方法将在输出目录为每个OIR生成一个仅包含非标通道的、文件内已配准的TIFF，和一个全时间轴平均值图像。此外还生成记录元数据的UniExp数据库。
%[text] %平均值图像用于下一步圈ROI，作为文件间配准的基准晃动图。
%[text] ```
%[text] ## 输入参数
%[text] OirPaths(:,1)string，所有要配准的OIR头文件路径，必须全都具有相同的XYCZ尺寸，且排除CD通道后的CZ尺寸不能比参照图小。此文件名如果符合UniExp标准格式：`<鼠名>.<日期时间>.<会话设计名>[.<其它可选字段>].oir，`例如 `0040.202207151026.BlueAudioWater.oir`，将可以自动识别生成额外的元数据。
%[text] OutputDirectory(1,1)，输出目录路径，输出文件将存放到该目录下。
%[text] ### 名称值参数
%[text] #### MaxTranslationStep=20
%[text] 平移变换最多移动多少像素。
%[text] #### MovingChannel(1,1)uint8=1
%[text] 要选择晃动图的哪个颜色用于平移配准，其它通道将应用完全相同的平移。
%[text] #### MemoryPreserve(1,1)double=1
%[text] 内存保留系数。该值越大，应用配准结果阶段所需内存越小。如果出现内存不足错误，可尝试增大此参数。此参数不能太大，否则会出现未知问题。注意，此系数仅影响应用配准结果阶段，对金字塔配准阶段无影响。请使用BlockSize参数控制金字塔配准阶段的内存占用。
%[text] #### UniExpFilename(1,1)string
%[text] 输出UniExp数据库文件名，包括扩展名。默认【\<鼠名\>.UniExp.mat】
%[text] #### UseGpu(1,:)=1:gpuDeviceCount
%[text] 指定要使用的GPU，默认使用所有GPU，设为空值则不使用任何GPU。注意，此处的GPU编号与任务管理器中的GPU编号无对应关系，可能为任意顺序；反之，与nvidia-smi命令得到的GPU编号有对应关系，MATLAB编号=NVIDIA编号+1，可用!nvidia-smi命令查看NVIDIA编号。一般来说GPU总是比CPU性能更高，但GPU内存太小的话则无法使用。
%[text] 如果需要同时运行多个MATLAB会话执行该函数，必须将此缓存目录设为不同的值。
%[text] #### Parallel(1,1)=UniExp.Flags.AsGPU
%[text] 并行池尺寸。算法中计算量最大的互相关计算步骤，CPU底层实现了自动并行化，因此CPU单线程计算未必比多线程慢，需要实际测试后决定是否并行。一般建议是，如果你有多个高性能GPU，通常应当启用并行，充分利用GPU性能；反之如果只有CPU，即使多核，也应当使用单线程计算，充分发挥自动并行化的性能。此参数有以下两种指定方式：
%[text] UniExp.Flags，可选以下枚举值：
%[text] - AsDefault，使用MATLAB当前并行池设置
%[text] - AsGPU，按照UseGpu个数设置并行池尺寸。如果GPU个数\<2，不使用并行池
%[text] - Sequential，顺序执行，不使用并行池 \
%[text] uint8，直接指定并行池尺寸值。如果此值\<2，将顺序计算，不使用并行池。
%[text] #### BlockSize(1,1)=26
%[text] 平移配准金字塔每层的块尺寸。本函数将时间轴分成多个小块，每块时间帧数为BlockSize，然后对每帧都计算它与其它BlockSize-1帧的互相关并求和，找到最大值点距离中心点的偏移量作为平移量进行配准。据此，计算的时空复杂度均正比于BlockSize^2。此值越大，每次参与配准的帧就越多，配准效果越好，但对性能要求越高、计算越慢。此值太小会导致配准不稳、抖动剧烈；过大则不能显著提高配准效果，反而导致计算极慢甚至内存不足。此外，如果图像的帧数在\[BlockSize,BlockSize^2/2\]范围内，配准效果会非常差，请注意选择合适的BlockSize。
%[text] #### CacheDirectory(1,1)string
%[text] 缓存文件目录。可以是不存在的目录，将自动创建。使用磁盘缓存可以提高输出阶段的性能，但请至少预留等同于所有OIR文件序列的容量，且确保所有OIR文件名均不相同。请勿在CacheDirectory存放任何无关数据！将在程序结束后被删除。
%[text] 如果需要同时运行多个MATLAB会话执行该函数，必须将此缓存目录设为不同的值。
%[text] #### BaseRegisterToDisk(1,1)logical=false
%[text] 是否将金字塔配准底层结果输出到缓存文件。如果设为true，将稍微降低速度，但节省内存。
%[text] #### WatchDogMinutes(1,1)double=Inf
%[text] 并行池看门狗忍耐分钟数。如果设为Inf，则不使用看门狗。看门狗监控并行池，一旦卡死超过指定忍耐时长，就会强行终止并行池，但不会终止整个程序，仍然继续往下执行。如果不使用并行池，此项设置无效。如果使用CPU计算，建议此项设置不少于3min。
%[text] 此参数已弃用，将在未来版本删除，请改用WatchDogTimeout。
%[text] #### LogLevel(1,1)UniExp.Flags=UniExp.Flags.LinearReduce
%[text] 输出日志信息的频率，可选以下枚举值：
%[text] - EachBlock，每个分块都输出一条日志信息
%[text] - LinearReduce，每个分块随机输出或不输出日志，输出概率随已输出日志条数线性衰减
%[text] - EachFile，每个文件输出一条日志信息bu
%[text] - No\_special\_operation或NoLogs，不输出任何日志信息。 \
%[text] #### WatchDogTimeout(1,1)duration=Inf
%[text] 并行池看门狗忍耐时长。如果设为Inf，则不使用看门狗。看门狗监控并行池，一旦卡死超过指定忍耐时长，就会强行终止并行池，但不会终止整个程序，仍然继续往下执行。如果不使用并行池，此项设置无效。如果使用CPU计算，建议此项设置不少于3min。
%[text] #### LogDirectory(1,1)string
%[text] 如果指定此目录，将向该目录下为每个工作单元输出一个日志文件，可用于调试目的
%[text] ## 输出文件
%[text] **此函数不返回值，而是向OutputDirectory输出以下文件：**
%[text] 所有OIR文件内部配准后对应的TIFF，文件名【Oir文件名.tif】，XYCZ尺寸与参照图相同，T与对应OIR文件相同，不含CD通道
%[text] 所有配准后的TIFF的平均值图像，文件名【Oir文件名.平均值.tif】，XYCZ尺寸相同，T尺寸为1
%[text] UniExpFilename，UniExp数据库文件，收集元数据和CD通道信息。
%[text] **See also** [UniExp.Flags](<matlab:edit UniExp.Flags>)
function BatchOirRegisterTiff(OirPaths,OutputDirectory,options)
arguments
	OirPaths(:,1)string
	OutputDirectory(1,1)string
	options.MaxTranslationStep=20
	options.MovingChannel=1
	options.BlockSize=26
	options.UseGpu=1:gpuDeviceCount
	options.Parallel=UniExp.Flags.AsGPU
	options.UniExpFilename
	options.MemoryPreserve=1
	options.CacheDirectory
	options.BaseRegisterToDisk=false
	options.WatchDogMinutes
	options.LogLevel=UniExp.Flags.LinearReduce
	options.WatchDogTimeout
	options.LogDirectory=''
end
import Image5D.*
import UniExp.Flags
HasOptions=isfield(options,["WatchDogTimeout","WatchDogMinutes","CacheDirectory"]);
if HasOptions(1)
	WatchDogOptions={options.WatchDogTimeout};
elseif HasOptions(2)
	WatchDogOptions={minutes(options.WatchDogMinutes)};
	UniExp.Exception.WatchDogMinutes_deprecated.Warn('WatchDogMinutes参数将在未来版本删除，请改用WatchDogTimeout');
else
	WatchDogOptions={};
end
%必须单独拎出来，因为后面要用于parfor
BaseRegisterToDisk=options.BaseRegisterToDisk;
if HasOptions(3)
	CacheDirectory=options.CacheDirectory;
	if isfolder(CacheDirectory)
		if height(ls(CacheDirectory))>2&&questdlg('缓存目录中已有的文件将被删除。确认？','缓存目录不为空','确认','取消','确认')~="确认"
			UniExp.Exception.CacheDirectory_not_empty.Throw;
		end
	else
		mkdir(CacheDirectory);
	end
	CacheDirectory={CacheDirectory};
else
	if BaseRegisterToDisk
		UniExp.Exception.Must_specify_CacheDirectory_if_BaseRegisterToCache.Throw;
	end
	CacheDirectory={};
end
NumFiles=height(OirPaths);
[~,Filename]=fileparts(OirPaths);
try
	[DateTimes,Blocks,Duplicate]=MteFiles2Tables(Filename);
	StandardFilename=true;
catch ME
	StandardFilename=false;
	DateTimes=table;
	Blocks=table;
	UniExp.Exception.Failed_to_resolve_a_standard_file_name.Warn('这将导致部分本应从文件名读取的元数据缺失',false);
	UniExp.Exception.Failed_to_resolve_a_standard_file_name.Warn(ME);
	Blocks.BlockIndex=(0x001:NumFiles)';
end
Blocks.BlockUID(:)=0x001:NumFiles;
if isa(options.Parallel,'UniExp.Flags')
	switch options.Parallel
		case Flags.AsDefault
			ParallelComputing.ParPool('Processes');
			Parallel=true;
		case Flags.AsGPU
			NumGpus=numel(options.UseGpu);
			Parallel=NumGpus>1;
			if Parallel
				ParallelComputing.ParPool('Processes',NumGpus);
			end
		case Flags.Sequential
			Parallel=false;
		otherwise
			UniExp.Exception.Invalid_Parallel_option.Throw;
	end
else
	Parallel=options.Parallel>1;
	if Parallel
		ParallelComputing.ParPool('Processes',options.Parallel);
	end
end
disp('初级配准并收集Tags……');
[CollectData,Metadata]=UniExp.internal.VerboseStream(options.LogLevel,OirPaths,@(Path)UniExp.internal.OirRegisterRW1(Path,options.BlockSize,BaseRegisterToDisk,CacheDirectory{:}),WatchDogOptions{:}).SpmdRun(@BlockProcess1,options.MovingChannel,options.MaxTranslationStep,NArgOut=3,NumGpuArguments=1,Parallel=Parallel,BlockSize=options.BlockSize,UseGpu=options.UseGpu,LogDirectory=options.LogDirectory);
[Translations,Data]=deal(cell(NumFiles,1));
NonstandardOrDuplicate=~StandardFilename||Duplicate;
for F=1:NumFiles
	DeviceNames=Metadata{F}.DeviceColors.Device;
	TTD=vertcat(CollectData{F}{:});
	Blocks.BlockTags{F}=array2table(vertcat(TTD{:,1}),VariableNames=DeviceNames(startsWith(DeviceNames,'CD')));
	DateTimes.SeriesInterval(F)=Metadata{F}.SeriesInterval;
	Translations{F}=TTD(:,2);
	Data{F}=cat(5,TTD{:,3});
	if NonstandardOrDuplicate
		DateTimes.DateTime(F)=Metadata{F}.CreationDateTime;
		Blocks.DateTime(F)=DateTimes.DateTime(F);
	end
end
DateTimes.Metadata=Metadata;
disp('开始执行金字塔配准……')
for F=1:NumFiles
	OP=OirPaths(F);
	fprintf('文件%u/%u：%s\n',F,NumFiles,OP);
	Reader=OirReader(OP);
	SizeXYCZ=[uint32(Reader.SizeX),Reader.SizeY,sum(~startsWith(Metadata{F}.DeviceColors.Device,'CD')),Reader.SizeZ];
	NumLevels=ceil(log2(sum(cellfun(@height,Translations{F})))/log2(options.BlockSize));
	TranslationPyramid=cell(NumLevels,1);
	TranslationPyramid{1}=Translations{F};
	if BaseRegisterToDisk
		CachePaths=Data{F};
		SizeT=numel(CachePaths);
		LevelData=zeros([SizeXYCZ,SizeT]);
		for T=1:SizeT
			Fid=fopen(CachePaths(T));
			LevelData(:,:,:,:,T)=reshape(fread(Fid,prod(SizeXYCZ),'uint16=>double'),SizeXYCZ);
			fclose(Fid);
		end
	else
		LevelData=Data{F};
	end
	for L=1:NumLevels-1
		NumPieces=numel(TranslationPyramid{L});
		NumBlocks=ceil(NumPieces^(1-1/(NumLevels-L)));
		LevelBlockSizes=uint32(linspace(0,NumPieces,NumBlocks+1));
		LevelBlockSizes=LevelBlockSizes(2:end)-LevelBlockSizes(1:end-1);
		LevelTranslations=cell(NumBlocks,1);
		LevelData=mat2cell(LevelData,SizeXYCZ(1),SizeXYCZ(2),SizeXYCZ(3),SizeXYCZ(4),LevelBlockSizes);
		MaxTranslationStep=options.MaxTranslationStep;
		if Parallel
			if ~isempty(options.UseGpu)
				%使用GPU时不应再单开CPU进程，否则反而更慢
				ParallelComputing.ParPool('Processes',numel(options.UseGpu));
				ParallelComputing.AssignGPUsToWorkers(options.UseGpu);
			end
			try
				parfor B=1:NumBlocks
					[LevelData{B},LevelTranslations{B}]=LevelRegister(LevelData{B},MaxTranslationStep);
				end
			catch ME
				if strcmp(ME.message,'Internal error in PARFOR - no intervals to retrieve.')
					warning(ME.identifier,'%s\n尝试重启并行池。',ME.message);
					delete(gcp);
					parfor B=1:NumBlocks
						[LevelData{B},LevelTranslations{B}]=LevelRegister(LevelData{B},MaxTranslationStep);
					end
				else
					ME.rethrow;
				end
			end
		else
			if isempty(options.UseGpu)&&gpuDeviceCount
				gpuDevice([])
			else
				gpuDevice(randsample(options.UseGpu,1));
			end
			for B=1:NumBlocks
				[LevelData{B},LevelTranslations{B}]=LevelRegister(LevelData{B},MaxTranslationStep);
			end
		end
		LevelData=cat(5,LevelData{:});
		TranslationPyramid{L+1}=LevelTranslations;
	end
	%防止NumLevels=1情况
	LevelTranslations=TranslationPyramid{end};
	for L=NumLevels-1:-1:1
		LevelTranslations=MATLAB.DataTypes.ArrayFun(@(Current,Higher)Current{1}+Higher,TranslationPyramid{L},vertcat(LevelTranslations{:}),Dimension=-1,CatMode=MATLAB.Flags.DontCat);
	end
	Translations{F}=vertcat(LevelTranslations{:});
end
disp('应用配准结果，输出平均图……');
if ~isfolder(OutputDirectory)
	mkdir(OutputDirectory);
end
%这里TiffPaths变量名同时作为表变量名。不用并行，因为读写远大于计算
[~,TiffPaths]=UniExp.internal.OirRegisterStream(options.LogLevel,OirPaths,Translations,OutputDirectory,CacheDirectory{:}).SpmdRun(@BlockProcess2,NArgOut=2,RuntimeCost=options.MemoryPreserve*3,NumGpuArguments=1,Parallel=false,UseGpu=options.UseGpu);
if StandardFilename
	MousePrefix=string(DateTimes.Mouse(1))+".";
	if Duplicate
		OldTiffPaths=[TiffPaths{:}];
		[~,NewTiffPaths]=fileparts(OldTiffPaths);
		DateTimeFields=string(DateTimes.DateTime,'yyyyMMddHHmm');
		for P=1:numel(NewTiffPaths)
			Fields=split(NewTiffPaths(P),'.');
			Fields(2)=DateTimeFields(P);
			NewTiffPaths=join(Fields,'.');
		end
		movefile(OldTiffPaths,fullfile(OutputDirectory,NewTiffPaths+".tif"));
	end
else
	MousePrefix="";
end
if isfield(options,'UniExpFilename')
	Filename=options.UniExpFilename;
else
	Filename=MousePrefix+"UniExp.mat";
end
Filename=fullfile(OutputDirectory,Filename);
UniExp.DataSet.Merge(struct(DateTimes=DateTimes,Blocks=Blocks),OutputPath=Filename);
if HasOptions(3)
	MATLAB.IO.Delete(options.CacheDirectory,MATLAB.Flags.FOF_NOCONFIRMATION);
end
end
%%
function Data=DoTranslation(Data,Translation)
[SizeX,SizeY,SizeZ,SizeT]=size(Data,1,2,4,5);
Xs=Translation(:,1,:);
Ys=Translation(:,2,:);
MXS=max(1,Xs+1);
MXE=min(SizeX,SizeX+Xs);
MYS=max(1,1+Ys);
MYE=min(SizeY,SizeY+Ys);
RXS=max(1,1-Xs);
RXE=min(SizeX,SizeX-Xs);
RYS=max(1,1-Ys);
RYE=min(SizeY,SizeY-Ys);
for T=1:SizeT
	for Z=1:SizeZ
		Data(RXS(T,Z):RXE(T,Z),RYS(T,Z):RYE(T,Z),:,Z,T)=Data(MXS(T,Z):MXE(T,Z),MYS(T,Z):MYE(T,Z),:,Z,T);
	end
end
end
function [Block,Translation]=SelfRegister(Block,MaxTranslationStep)
Translation2=SRImpl(imresize(Block,1/2),MaxTranslationStep/2)*2;
Block=DoTranslation(Block,Translation2);
Translation1=SRImpl(Block,1);
Block=mean(DoTranslation(Block,Translation1),5);
Translation=Translation2+Translation1;
end
function [Tags,Translation,Data]=BlockProcess1(Data,TagLogical,RegisterChannel,MaxTranslationStep,LogFid)
if nargin<5
	LogFid=0;
end
MATLAB.IO.LogF(LogFid,'标通道切片……');
Data=single(Data);
Tags=gather(permute(mean(Data(:,:,TagLogical,:,:),[1 2 4]),[5,3,1,2,4]));
MATLAB.IO.LogF(LogFid,'块内自配准……');
[Data,Translation]=SelfRegister(Data(:,:,RegisterChannel,:,:),MaxTranslationStep,LogFid);
MATLAB.IO.LogF(LogFid,'收集结果……');
Data=gather(Data);
Translation=gather(Translation);
end
function [Data,Sum]=BlockProcess2(Data,Translation)
Data=DoTranslation(Data,Translation);
Sum=gather(sum(Data,5));
Data=gather(uint16(Data));
end
function [LevelData,LevelTranslations]=LevelRegister(LevelData,MaxTranslationStep)
GPU=parallel.gpu.GPUDeviceManager.instance.SelectedDevice;
if isempty(GPU)
	[LevelData,LevelTranslations]=SelfRegister(LevelData,MaxTranslationStep);
else
	try
		[LevelData,LevelTranslations]=SelfRegister(gpuArray(LevelData),MaxTranslationStep);
		LevelData=gather(LevelData);
		LevelTranslations=gather(LevelTranslations);
	catch ME
		if strcmp(ME.identifier,'parallel:gpu:array:OOM')
			GPU.reset;
			try
				[LevelData,LevelTranslations]=SelfRegister(gpuArray(LevelData),MaxTranslationStep);
			catch ME
				if strcmp(ME.identifier,'parallel:gpu:array:OOM')
					warning('GPU内存不足，转入CPU计算。\n金字塔层尺寸：%s',size(LevelData));
					[LevelData,LevelTranslations]=SelfRegister(LevelData,MaxTranslationStep);
				else
					ME.rethrow;
				end
			end
		else
			ME.rethrow;
		end
	end
end
end
function Translation=SRImpl(Block,MaxTranslationStep)
persistent MaxBlockSize
if isempty(MaxBlockSize)
	MaxBlockSize=Inf;
end
[SizeX,SizeY,SizeC,SizeZ,SizeT]=size(Block);
Deback=ImageProcessing.Edge(Block);
Template=permute(Deback,[1,2,5,4,3]);
Translation=zeros(SizeT,2,SizeZ,'int16'); %后面要跟图像尺寸加减，所以需要更大范围
FullSize=SizeX*SizeY*SizeC*SizeT*SizeT;
NumBlocks=floor(FullSize/MaxBlockSize)+1;
XCSize=MaxTranslationStep*2+1;
XCorrs=zeros(XCSize,XCSize,SizeT,1,SizeT,'like',Block);
Partial={SizeX-MaxTranslationStep:SizeX+MaxTranslationStep,SizeY-MaxTranslationStep:SizeY+MaxTranslationStep};
for Z=1:SizeZ
	while true
		try
			BlockEnds=uint32(linspace(0,SizeT,NumBlocks+1));
			for B=1:NumBlocks
				Index=BlockEnds(B)+1:BlockEnds(B+1);
				XCorrs(:,:,:,:,Index)=ImageProcessing.NormXCorr2(Template(:,:,:,Z,:),Deback(:,:,:,Z,Index),Partial);
			end
			break;
		catch ME
			warning('off','backtrace');
			switch ME.identifier
				case {"parallel:gpu:device:UnknownCUDAError","parallel:gpu:kernel:LaunchFailure"}
					warning('%s：将尝试在CPU上执行',ME.identifier);
					XCorrs=gather(XCorrs);
					Template=gather(Template);
					Deback=gather(Deback);
					Partial=gather(Partial);
					GpuIndex=gpuDevice().Index;
					gpuDevice([]);
					gpuDevice(GpuIndex);
				case "parallel:gpu:array:OOM"
					MaxBlockSize=ceil(FullSize/NumBlocks)-1;
					NumBlocks=NumBlocks+1;
					if NumBlocks>SizeT
						ME.rethrow;
					end
					warning('GPU内存不足，启动自适应分块算法，目前分块：%u',NumBlocks);
				otherwise
					ME.rethrow;
			end
		end
	end
	[~,Xs,Ys]=MATLAB.DataFun.MaxSubs(XCorrs,1:2);
	Xs=mean(Xs,3)-double(MaxTranslationStep)-1;
	Ys=mean(Ys,3)-double(MaxTranslationStep)-1;
	Translation(:,:,Z)=[Xs(:),Ys(:)];
end
end

%[appendix]{"version":"1.0"}
%---
