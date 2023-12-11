function V = Version
V.Me='v17.1.0';
V.ParallelComputing=ParallelComputing.Version;
V.GlobalOptimization=GlobalOptimization.Version;
V.ImageProcessing=ImageProcessing.Version;
V.Image5D=Image5D.Version;
V.TextAnalytics=TextAnalytics.Version;
V.ComputerVision=ComputerVision.Version;
V.MatlabException='v18.0.0';
V.MATLAB='R2023b';
persistent NewVersion
if isempty(NewVersion)
	warning('off','TextAnalyticsException:Thread_parallelism_not_supported');
	NewVersion=TextAnalytics.CheckUpdateFromGitHub('https://github.com/ShanghaitechGuanjisongLab/Unified-Experimental-Analysis-and-Figuring/releases','统一实验分析作图',V.Me);
end