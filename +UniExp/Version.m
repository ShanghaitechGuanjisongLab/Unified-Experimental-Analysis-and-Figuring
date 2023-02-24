function V = Version
V.Me='13.0.0';
V.ParallelComputing=ParallelComputing.Version;
V.GlobalOptimization=GlobalOptimization.Version;
V.ImageProcessing=ImageProcessing.Version;
V.Image5D=Image5D.Version;
V.MATLAB='R2022b';
persistent NewVersion
if isempty(NewVersion)
	try
		NewVersion=webread('https://github.com/ShanghaitechGuanjisongLab/Unified-Experimental-Analysis-and-Figuring/releases');
	catch ME
		if any(ME.identifier==["MATLAB:webservices:ConnectionRefused","MATLAB:webservices:UnknownHost"])
			NewVersion=[];
			return;
		else
			ME.rethrow;
		end
	end
	NewVersion=char(htmlTree(NewVersion).findElement('section:first-child span.wb-break-all').extractHTMLText);
	if ~strcmp(NewVersion(2:end),V.Me)
		disp(['统一实验分析作图' NewVersion '已发布，<a href="https://github.com/ShanghaitechGuanjisongLab/Unified-Experimental-Analysis-and-Figuring/releases">立即更新</a>']);
	end
end