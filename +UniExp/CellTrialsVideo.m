%[text] 从TIFF中截取一段展示细胞活动的视频
%[text] ![示例视频.jpg](text:image:9a31)
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] Video=UniExp.CellTrialsVideo(TiffPath);
%[text] %将指定TIFF直接转换为视频
%[text] 
%[text] Video=UniExp.CellTrialsVideo(___,OutputPath);
%[text] %与上述任意语法组合使用，额外指定输出视频文件路径
%[text] 
%[text] Video=UniExp.CellTrialsVideo(___,ROI);
%[text] %与上述任意语法组合使用，额外指定要圈出的细胞范围
%[text] 
%[text] Video=UniExp.CellTrialsVideo(___,ShowSeconds);
%[text] %与上述任意语法组合使用，额外指定要标注的秒数范围
%[text] 
%[text] Video=UniExp.CellTrialsVideo(___,Color);
%[text] %与上述任意语法组合使用，额外指定ROI和秒数的标注颜色
%[text] 
%[text] Video=UniExp.CellTrialsVideo(___,TStarts,TSize);
%[text] %与上述任意语法组合使用，额外指定要截取的时段
%[text] 
%[text] Video=UniExp.CellTrialsVideo(___,Window);
%[text] %与上述任意语法组合使用，额外指定要截取的XY平面窗口
%[text] 
%[text] Video=UniExp.CellTrialsVideo(___,Name=Value);
%[text] %与上述任意语法组合使用，额外指定更多名称值参数
%[text] ```
%[text] ## 输入参数
%[text] #### TiffPath(1,1)string
%[text] TIFF文件路径
%[text] #### OutputPath
%[text] (1,1)string，输出视频文件路径，建议使用mp4扩展名。无论扩展名为何，都将输出MPEG-4格式视频文件。如果不指定此参数，不会将视频输出到文件。
%[text] #### ROI(:,2,2)
%[text] 多个细胞的ROI圆心和半径，第1维细胞，第2维XY，第3维圆心/半径。如果不指定此参数，将不标注细胞圈。
%[text] #### ShowSeconds(1,1)struct
%[text] 要在视频中显示的计时读秒。包含以下字段：
%[text] - Range(1,2)，必需，回合时间偏移范围，两个元素分别是起始和终止时间偏移。如果指定为非duration类型，则单位为秒。
%[text] - Size(1,1)=mean2(ROI(:,:,2))，字体大小。此值大致等于单行文本高度将会占据的像素数，但不同字体的渲染结果可能有所不同。如果未指定ROI，此字段为必需。
%[text] - Font(1,1)string="Microsoft YaHei"，渲染字体。可用listTrueTypeFonts查看所有可用的字体。
%[text] - Location(1,1)UniExp.Flags，显示位置，可选：NorthWest，显示在左上角；NorthEast，显示在右上角；SouthWest，显示在左下角；SouthEast，显示在右下角。如不指定此参数，将自动选择一个离所有ROI最远的角落；如果未指定ROI，默认为左上角。 \
%[text] 计时读秒将仅显示整数秒数，并加后缀单位“s”，右对齐。如果不指定此参数，将不显示计时读秒。
%[text] #### Color(1,3)
%[text] ROI和秒数标注所使用的RGB颜色，使用\[0,1\]范围内的single或\[0,255\]范围内的uint8值表示RGB分量。如果不指定此参数，将根据TIFF的通道颜色自动分配一个尽可能形成高对比的颜色。
%[text] #### TStarts(:,1)
%[text] 要截取的TIFF起始时点，从0开始。如果指定多个，将截取多段并串联。如不指定，将取全时段。
%[text] #### TSize(1,1)
%[text] 要截取的TIFF时段长度。暂不支持每个时段不同长度。
%[text] #### Window
%[text] 要截取的窗口范围。可以是：
%[text] - (1,1)UniExp.Flags。可选枚举项UniExp.Flags.Auto以根据ROI位置确定窗口范围，此时必须指定ROI参数；或UniExp.Flags.Full以包含整个图面不作截取。
%[text] - (2,2)，手动指定窗口范围，4项分别是【左索引，顶索引；右索引，底索引】，即最终窗口将截取为(Window(1,1):Window(2,1),Window(1,2):Window(2,2) \
%[text] 如果指定了ROI，此参数默认是UniExp.Flags.Auto；否则默认是UniExp.Flags.Full。
%[text] ### 名称值参数
%[text] 名称值参数并非都是可选的。在某些条件下，可能是必需的。
%[text] C(1,1)，要截取的通道，从0开始。对于多通道TIFF，必须指定此参数。
%[text] Z(1,1)，要截取的Z层，从0开始。对于多Z层TIFF，必须指定此参数。
%[text] FrameRate(1,1)，视频帧率，一秒几帧。如果指定了OutputPath，但未指定ShowSeconds，则此参数为必需。
%[text] ## 返回值
%[text] Video(:,:,3,:)uint8，生成的视频像素数组。第1维Y，第2维X，第3维RGB，第4维时间。
%[text] **See also** [listTrueTypeFonts](matlab:listTrueTypeFonts) [VideoWriter](<matlab:doc VideoWriter>) [insertText](<matlab:doc insertText>) [pagetranspose](<matlab:doc pagetranspose>) [UniExp.DataSet.CellTrialsVideo](<matlab:doc UniExp.DataSet.CellTrialsVideo>)
function Video=CellTrialsVideo(TiffPath,varargin)
import UniExp.Flags;

% -------- Parse inputs (positional + Name=Value) --------

TSize=[];
Color=[];
Window=[];
HasROI=false;
ShowSeconds=[];
OutputPath=[];
V=1;
NumVarargin=numel(varargin);
while V<=NumVarargin
	Arg=varargin{V};
	if isnumeric(Arg)
		if isvector(Arg)
			if any(Arg>1)
				TStarts=Arg;
				TSize=varargin{V+1};
				V=V+2;
				continue;
			else
				Color=Arg;
			end
		else
			if ismatrix(Arg)
				Window=Arg;
			else
				ROI=Arg;
				HasROI=true;
			end
		end
	else
		if isstruct(Arg)
			ShowSeconds=Arg;
		elseif isa(Arg,'UniExp.Flags')
			Window=Arg;
		elseif any(Arg==["C","Z","FrameRate"])
			% Name=Value pair, stop positional parsing
			break;
		else
			OutputPath=Arg;
		end
	end
	V=V+1;
end
HasChannel=false;
HasZLayer=false;
FrameRate=[];
for V=V:2:numel(varargin)
	Arg=varargin{V+1};
	switch varargin{V}
		case "C"
			Channel=Arg;
			HasChannel=true;
		case "Z"
			ZLayer=Arg;
			HasZLayer=true;
		case "FrameRate"
			FrameRate=Arg;
	end
end
Reader=Image5D.OmeTiffRWer.OpenRead(TiffPath);

% -------- Resolve channel / Z (0-based, consistent with ReadPixels convention) --------
if HasZLayer
	if HasChannel
		ZCArguments={ZLayer,1,Channel,1};
	elseif Reader.SizeC>1
		UniExp.Exception.Channel_not_specified_for_multi_channel_TIFF.Throw;
	else
		ZCArguments={ZLayer,1,0,1};
	end
elseif Reader.SizeZ>1
	UniExp.Exception.ZLayer_not_specified_for_multi_Z_TIFF.Throw;
else
	if HasChannel
		ZCArguments={0,1,Channel,1};
	elseif Reader.SizeC>1
		UniExp.Exception.Channel_not_specified_for_multi_channel_TIFF.Throw;
	else
		ZCArguments={};
	end
end

% -------- Read + build RGB video (XYCT) --------
if isempty(TSize)
	TStarts=0;
	TSize=Reader.SizeT;
end
Video=arrayfun(@(Start)Reader.ReadPixels(Start,TSize,ZCArguments{:}),TStarts,'UniformOutput',false);
Video=gpuArray(cat(6,Video{:}));
if HasChannel
	ChColor=Reader.ChannelColors(Channel+1);
else
	ChColor=Reader.ChannelColors;
end
Video=uint8(rescale(single(reshape(Video,[size(Video,1:2),1,TSize,size(Video,6)])).*single(cat(3,ChColor.R,ChColor.G,ChColor.B))/255,0,255));

% -------- Resolve annotation color --------
if isempty(Color)
	Color=GlobalOptimization.ColorAllocate(1,[ChColor.R,ChColor.G,ChColor.B;0,0,0])*255;
else
	if isfloat(Color)&&all(Color<=1)
		Color=Color*255;
	end
end
Color=reshape(Color,1,1,3);

% -------- ROI overlay (before cropping) --------
PlaneSize=size(Video,1:2);
if HasROI
	% 维度顺序：Xs Ys 细胞 XY 圆心半径
	ROI5=reshape(ROI,[1,1,size(ROI)]);
	ROI5(:,:,:,:,2)=ROI5(:,:,:,:,2)+1;
	Video=MATLAB.Ops.LogicalAssign(Video,edge(all((((1:PlaneSize(1))'-ROI5(:,:,:,1,1))./ROI5(:,:,:,1,2)).^2+(((1:PlaneSize(2))-ROI5(:,:,:,2,1))./ROI5(:,:,:,2,2)).^2>1,3)),Color);
end

% -------- Window cropping --------
if isempty(Window)
	if HasROI
		Window=Flags.Auto;
	else
		Window=Flags.Full;
	end
end

if isscalar(Window)
	switch Window
		case Flags.Full
			% no-op
		case Flags.Auto
			Window=zeros(2);
			[Window(1,:),Window(2,:)]=bounds(ROI(:,:,1),1);
			Padding=mean(ROI(:,:,2),1:2)*3;
			Window(1,:)=max(Window(1,:)-Padding,1);
			Window(2,:)=min(Window(2,:)+Padding,PlaneSize);
			Video=Video(Window(1,1):Window(2,1),Window(1,2):Window(2,2),:,:);
	end
else
	Video=Video(Window(1,1):Window(2,1),Window(1,2):Window(2,2),:,:);
end
PlaneSize=size(Video,1:2);

% -------- ShowSeconds overlay --------
persistent LocationOrder
if~isempty(ShowSeconds)
	if isduration(ShowSeconds.Range)
		ShowSeconds.Range=seconds(ShowSeconds.Range);
	end
	[Index,TextMasks]=findgroups(floor(linspace(ShowSeconds.Range(1),ShowSeconds.Range(2),TSize)));
	if isfield(ShowSeconds,'Size')
		TextSize=ShowSeconds.Size;
	else
		TextSize=mean2(ROI(:,:,2))*2;
	end
	if isfield(ShowSeconds,'Font')
		Var={ShowSeconds.Font};
	else
		Var={};
	end
	TextMasks=arrayfun(@(S)ComputerVision.TextMask(S,TextSize,Var{:}),compose("%is",TextMasks),UniformOutput=false);
	TextMasks=pagetranspose(MATLAB.ElMat.PadCat(4,TextMasks{:},Padder=false,Alignment=[1,2,-2,0]));
	if isfield(ShowSeconds,'Location')
		Start=ShowSeconds.Location;
	elseif HasROI
		Start=cat(3,ROI(:,:,1),PlaneSize-ROI(:,:,1)).^2;
		[~,Start]=max(min(Start(:,1,:)+reshape(Start(:,2,:),[],2,1),[],1),[],'all');
		if isempty(LocationOrder)
			LocationOrder=[Flags.NorthWest,Flags.NorthEast,Flags.SouthWest,Flags.SouthEast];
		end
		Start=LocationOrder(Start);
	else
		Start=Flags.NorthWest;
	end
	Subs=size(TextMasks,1:2);
	switch Start
		case Flags.NorthWest
			Start=[0,0];
		case Flags.NorthEast
			Start=[PlaneSize(1)-Subs(1),0];
		case Flags.SouthWest
			Start=[0,PlaneSize(2)-Subs(2)];
		case Flags.SouthEast
			Start=(PlaneSize-Subs);
	end
	Subs=arrayfun(@colon,Start+1,Start+Subs,UniformOutput=false);
	Video(Subs{:},:,:)=MATLAB.Ops.LogicalAssign(Video(Subs{:},:,:),TextMasks(:,:,:,Index),Color);
end
Video=pagetranspose(Video);

% -------- Optional file output --------
if~isempty(OutputPath)
	Writer=VideoWriter(OutputPath,'MPEG-4');
	if isempty(FrameRate)
		Writer.FrameRate=double(TSize)/(ShowSeconds.Range(2)-ShowSeconds.Range(1));
	else
		Writer.FrameRate=FrameRate;
	end
	Writer.Quality=100;
	Writer.open;
	warning off MATLAB:audiovideo:VideoWriter:mp4FramePadded
	Writer.writeVideo(gather(Video));
	Writer.close;
end

end

%[appendix]{"version":"1.0"}
%---
%[text:image:9a31]
%   data: {"align":"baseline","height":100,"src":"data:image\/jpeg;base64,\/9j\/4AAQSkZJRgABAgAAAQABAAD\/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL\/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL\/wAARCABkAGQDASIAAhEBAxEB\/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL\/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6\/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL\/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6\/9oADAMBAAIRAxEAPwDw7ac527upHtXonh+ceFvh1ea\/FFGmo3k5gtJ3XeWTIGB6YKyHnGSozngVwDL8u4DknGD3rt9BudN13wPc+Gr7UYbO6t5ftFlLcsEjUZ6ZyMnLODnJw+QDjAeGl7z72dvUrBy9523s7epp65E3inwX4d1C6jg\/tW7u1sjcBduQWkUZx7qD04ycAZIrD1\/w3pWgPPb\/ANvefqMG0\/ZBZsu4Ng4DZI6c9\/TvWtqF5p+m6D4a8OWutWsl5BfJcSXkBV4bf53+YknBwX6cZC5O3IrY1nUNOvPC2oR67qWh6hcwRN9intJAZWOBtJQZKsWCk7Tt5weBz01KcJpt\/FZa+dtfmddWlTqKTlbmstXte2uz3PLjHnuMYIyoHbj8BUO0M5LnnGR+HFSbgAQU64znt1\/wphDmM7VPGPw4\/wDrV5KPCVxFkAIOQBuzxUm0yQZD5IxlcDp9c1BhhIflwAeuOeP\/ANVXLMmFi7oCFHGeMiiWiuhz0V0PDfZYCcfM\/Qk8qPT0qrLy+WBbDDv1p026VgTks3Jx3prDYMEYweSe9KKtr1Jira9SLBdyFwFHAyOgppQhyqkYJp2085xk8nJqQspVdowB05q7ml7DSemSmcdcdffpRTfKLc7j+Joo0C8e5NHETHwvzBjheuRUEiBemeOeB0PpVkb1OzkDrgnH60lwOAygKvVR3qU9SVJ3Ke0GTIUbc9OnUVKMLFjk5BP0Ap3qvAwOfaoi3I3E8+g7Vd7ml7lgFyEHHTjB54qX5eDklSQAQc45GR7\/AEqgzMz9cAA9e1WVlByTll2jJyeSP8\/rUuJDgWIIGluAp4IwDgfdGM8f5\/OiQCZwsSEg8deemav26mKx8xuZZDtBPoCCT9eapRQyzsGcbEUDDN8oC\/dHP1NZKV232MFK7b7FY4JbAHAyeeQc9P8APtS4LqACvIxktjPHFO+zDAKOCeSRnnr\/AD6n8qayNGeV5A4P8jzV3XQ1unsRbfmbB2ggH1x7U0nDZ4yB0pWwWAbcSR29ajbIUNkZI\/l3rRGiVx33ud1FVwrEZyf0op28y+Vdy7HMehUAZyc9zU6srMuQdp5A9896qD5Qwyc4zg\/X\/wDXUkatJ3C8Yy3HFZuK3MZRW46WJgSzYJYnpVcoQQNpIxk56AVeDjBGNxAwQMdPX2pjRxuNy8Me2MjFClbcUZtblI5bGMjGCMdBWnp2mXN\/MXiWIImMySSrGmT0BZiBk8nHXg+hqsbXEnyuuDg4Bru\/7HEdpaDzEiigto5ljbGZHdVdj7nJ259FUdqVWtGEeZ7f5irYiFOnzPbb5sybnR7yyhNxMIJIoQrMI7iNyM8chWOB0GemSKwnlM2f3uNy8BemcdD+Wa6K61H7POLhNrGBwWEn3XHQqwHUEEgjuDjvWDq1pDY6lJHHMzRMFmgL8vskUOu7p821hn3rOklOPMlYzoJTjz2t+JXwyyKMnZwACM+vbmo8AffGQAT+p\/8Ar\/nU3mQxnghyCuMfj\/jUTsHGUHAUcevr\/KtFc1VyOXGTtyNo6\/T0qInLtuX5ueKmK7VOWyQD0bg+h\/Q1CANpySemcc+n+NXE0iNPXGenHU0UeXv5BVR6UVZd13Lfm7lOEBAO4nH50KV67gM9FxjdnvmmKp8wgcsOAuOT\/nvQyj5mGADk7Sc8nHp+NZWRlZbEwOzO2RipPzMOAfpUycRNjBY9c+lUVPIJPB5B9v8AIqdZWb\/VgHjGT9OamUSJQZIi5kGeAPXg11V9cF7i2mWUhTZwEEfdYiNVPPfDBh7EEdRXMwyiQ7QoB9R0PofetKxu1e2kt71ZjHCDskiwGiyegz95cknZxz0K5bMTXMnF6GU0pRcZabGdfXD3dx9nt0kkaYhRGikl2PHAHU5qvr8kcmqukbpIIIobcyIwKuYokjLKe6kqSD3BHSrc1xZ6dg6ebma7OSl1Oqx+T\/uoC3zDHD7uM8AEBhgspU8jnrXVTioQ5UdtKMacOVDt3Oe3b3q2mWDfxYGQCvXvUEMTOwyBjsP\/AK1TuNsYUMdvUj1PrnvUya2Jm03Yb5e2Tgn2yfT+XSoQwySQTgYbPXr\/AJ\/KpSxB3feJU8n+HNV26seBkcc+1OI467kmwtyWP5UUzDFmIcKSSSPeiqsOz7lncwYFG3N0GOmc54poyCSRy3Q9ueP8KZEAxUMdq9eB2p5ydrFhggj8ajYi1tBG3GTGAMcZ98g1PHKdh3YLAAcY9P6YHWokzsAYAIC2c9zg0pfOQBkEknb02k5OPypNX0Bq+hKUAfjHODkdh+PNXre4KWtxGAOQAWHes4uWJZTjJ4H0\/wDrcU6Ji+7cxJYbcD+Z9uKzlG61Mpw5lqOUAkggFuCOKafLAGVB3HgA9PrUZwNo3cHqOvNGVIHXHfGPwqrFWJcjJ3kEduQf1qORyFxxxyAOetRbhuG3OAc5z1ozkspB3AcVSiUojOehBxu5HrmgkZz2OD69sYp3zMRzwDg4GaQqC2OMZ44xiqLuM4HAzj6UVITzkEKDzjNFFwuKyheFOSSen6U9uRkYAPGe3JqPeSVGBuHB+lBkVidowVz3pWYrMTphSTggj3FSKqkZycEHI6enFMTAG7G4gd+fanIw4BIJPXjrkUMGPMfyFiTuIJAA9if5Um7aTjBUDJ7Y\/wA5\/Wllb7rPuKsO\/UY44\/Som6quBtBwwGcEiktdxJX3HmQqdynDDB3AYx6\/zpDJlhkAep96ar\/MQQCDnt+NMVskAnrkfhVWHyjzgjnp25oXLbu\/v15pFYq3ADE5HXH5fnTR8oI\/vDnp+FFh2JSwyy4C7jkf5NNIOQo6be\/86TBOPQcDPWlK8gcA5oFsMzjqDRT2JU45GO1FAyE\/dLd8\/wBaf0Ax6UUU2Ux+0CLcOpXmo\/Tk8DiiikhIWQlRkHneRSxc4J68UUU+gdBI+EbgHG3GamKLtdsdjx2oopS3JluRk\/KTgce30qPJ49un5UUU0UiWI5U5A7\/yNEUjEsTgnHpRRSZL6jio9KKKKkk\/\/9k=","width":100}
%---
