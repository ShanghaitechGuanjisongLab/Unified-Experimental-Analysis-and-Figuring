function V = Version
V.Me='v20.7.1';
V.ParallelComputing='v8.1.4';
V.GlobalOptimization='v3.1.2';
V.ImageProcessing='v3.6.1';
V.Image5D='v3.3.0';
V.TextAnalytics='v1.0.3';
V.ComputerVision='v1.1.1';
V.MatlabExtension='v20.0.0';
V.MATLAB='R2026a';
persistent NewVersion
if isempty(NewVersion)
	warning('off','TextAnalyticsException:Thread_parallelism_not_supported');
	NewVersion=TextAnalytics.CheckUpdateFromGitHub('https://github.com/ShanghaitechGuanjisongLab/Unified-Experimental-Analysis-and-Figuring/releases','统一实验分析作图',V.Me);
end