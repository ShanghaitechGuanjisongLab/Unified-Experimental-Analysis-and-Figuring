function V = Version
V.Me='v14.1.1';
V.ParallelComputing=ParallelComputing.Version;
V.GlobalOptimization=GlobalOptimization.Version;
V.ImageProcessing=ImageProcessing.Version;
V.Image5D=Image5D.Version;
V.TextAnalytics=TextAnalytics.Version;
V.MATLAB='R2022b';
persistent NewVersion
if isempty(NewVersion)
	NewVersion=TextAnalytics.CheckUpdateFromGitHub('https://github.com/ShanghaitechGuanjisongLab/Unified-Experimental-Analysis-and-Figuring/releases','统一实验分析作图',V.Me);
end