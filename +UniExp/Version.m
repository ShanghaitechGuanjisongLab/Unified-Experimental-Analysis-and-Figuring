function V = Version
V.Me='v18.0.0';
V.ParallelComputing='8.1.0';
V.GlobalOptimization='3.1.1';
V.ImageProcessing='3.6.1';
V.Image5D='3.0.1';
V.TextAnalytics='1.0.3';
V.ComputerVision='1.0.0';
V.MatlabExtension='v18.3.0';
V.MATLAB='R2023b';
persistent NewVersion
if isempty(NewVersion)
	warning('off','TextAnalyticsException:Thread_parallelism_not_supported');
	NewVersion=TextAnalytics.CheckUpdateFromGitHub('https://github.com/ShanghaitechGuanjisongLab/Unified-Experimental-Analysis-and-Figuring/releases','统一实验分析作图',V.Me);
end