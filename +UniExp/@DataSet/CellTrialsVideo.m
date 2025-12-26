%[text] 为指定细胞和回合生成视频
%[text] 所有指定的细胞和回合必须来自同一个TIFF文件，且那个TIFF只允许有一个颜色通道。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] Video=obj.CellTrialsVideo(CellUID,TrialUID);
%[text] %生成视频并返回Video像素张量
%[text] 
%[text] Video=obj.CellTrialsVideo(___,OutputPath);
%[text] %与上述任意语法组合使用，额外要求输出视频文件到指定路径
%[text] 
%[text] Video=obj.CellTrialsVideo(___,ZLayer);
%[text] %与上述任意语法组合使用，额外指定Tiff文件中的Z层号，从0开始
%[text] ```
%[text] ## 输入参数
%[text] CellUID(:,1)uint16，细胞UID。所有细胞必须属于同一只鼠的同一个Z层
%[text] TrialUID(:,1)uint16，回合UID。所有回合必须属于同一个会话，且相对于Tag有相同的开始和结束偏移量
%[text] OutputPath(1,1)string，可选，输出视频路径。如不指定此参数，则不输出视频文件。
%[text] ZLayer(1,1)uint8，可选，Tiff文件中的Z层号，从0开始。如果Tiff文件中不止一个Z层，必须指定此参数。
%[text] ## 返回值
%[text] Video(:,:,3,:)uint8，生成的视频像素数组。第1维Y，第2维X，第3维RGB，第4维时间。
%[text] **See also** [UniExp.CellTrialsVideo](<matlab:doc UniExp.CellTrialsVideo>)
function Video=CellTrialsVideo(obj,CellUID,TrialUID,varargin)
ZLayer={};
OutputPath={};
for V=1:numel(varargin)
	if isnumeric(varargin{V})
		ZLayer={'Z',varargin{V}};
	else
		OutputPath=varargin(V);
	end
end
TrialsSharedInfo=unique(obj.TableQuery(["TiffPath","SeriesInterval"],TrialUID=TrialUID));
switch height(TrialsSharedInfo)
	case 0
		UniExp.Exception.Trials_Block_information_not_found.Throw;
	case 1
		%正常情况
	otherwise
		UniExp.Exception.Trials_come_from_different_Blocks.Throw(TrialsSharedInfo);
end
SelectedCells=obj.Cells(ismember(obj.Cells.CellUID,CellUID),["Center","Radius","ZLayer"]);
if~isscalar(MATLAB.Ops.UniqueN(SelectedCells.ZLayer))
	UniExp.Exception.Cells_have_different_ZLayers.Throw;
end
SampleRange=obj.Trials.SampleRange(ismember(obj.Trials.TrialUID,TrialUID),:);
Range=MATLAB.Ops.UniqueN(SampleRange{:,["Start","End"]}-SampleRange.Tag,1);
if~isrow(Range)
	UniExp.Exception.Trials_have_different_Start_and_End_offsets.Throw(Range);
end
Video=UniExp.CellTrialsVideo(TrialsSharedInfo.TiffPath,OutputPath{:},reshape([SelectedCells.Center{:,["X","Y"]},SelectedCells.Radius{:,["X","Y"]}],[],2,2),sort(SampleRange.Start)-1,Range(2)-Range(1)+1,struct(Range=Range.*TrialsSharedInfo.SeriesInterval),ZLayer{:});
end

%[appendix]{"version":"1.0"}
%---
