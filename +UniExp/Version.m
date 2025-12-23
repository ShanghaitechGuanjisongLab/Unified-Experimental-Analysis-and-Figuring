function V = Version
V.Me='v20.7.0';
V.ParallelComputing='8.1.4';
V.GlobalOptimization='3.1.2';
V.ImageProcessing='3.6.1';
V.Image5D='3.2.4';
V.TextAnalytics='1.0.3';
V.ComputerVision='1.1.1';
V.MatlabExtension='v19.12.0';
V.MATLAB='R2026a';
persistent NewVersion
if isempty(NewVersion)
	warning('off','TextAnalyticsException:Thread_parallelism_not_supported');
	NewVersion=TextAnalytics.CheckUpdateFromGitHub('https://github.com/ShanghaitechGuanjisongLab/Unified-Experimental-Analysis-and-Figuring/releases','统一实验分析作图',V.Me);
end