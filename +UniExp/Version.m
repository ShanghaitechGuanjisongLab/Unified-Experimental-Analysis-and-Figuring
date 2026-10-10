function V = Version
persistent pVersion
if isempty(pVersion)
	pVersion.Me=matlab.mpm.Version('20.12.0');
	if~isempty(metafunction('TextAnalytics.CheckUpdateFromGitHub'))
		warning('off','TextAnalyticsException:Thread_parallelism_not_supported');
		TextAnalytics.CheckUpdateFromGitHub('https://github.com/ShanghaitechGuanjisongLab/Unified-Experimental-Analysis-and-Figuring/releases','统一实验分析作图',pVersion.Me);
	end
	pVersion.Dependencies=array2table([ ...
		"ComputerVision"		"1.2.0"		"https://github.com/Ebola-Chan-bot/Computer-Vision/releases"
		"GlobalOptimization"	"3.3.1"		"https://github.com/Ebola-Chan-bot/Global-Optimization/releases"
		"Image5D"				"3.3.2"		"https://github.com/Ebola-Chan-bot/Image5D/releases"
		"ImageProcessing"		"3.10.2"	"https://github.com/Ebola-Chan-bot/Image-Processing/releases"
		"ParallelComputing"		"8.2.1"		"https://github.com/Ebola-Chan-bot/Parallel-Computing/releases"
		"TextAnalytics"			"1.0.7"		"https://github.com/Ebola-Chan-bot/Text-Analytics/releases"
		],VariableNames=["Namespace","Version","URL"]);
	pVersion.Dependencies.Version=matlab.mpm.Version(pVersion.Dependencies.Version);
	pVersion.MATLAB='R2026a';
	for D=1:height(pVersion.Dependencies)
		Namespace=pVersion.Dependencies.Namespace(D);
		MpmVersion=Namespace+".Version";
		EarliestVersion=pVersion.Dependencies.Version(D);
		URL=pVersion.Dependencies.URL(D);
		if isempty(metafunction(MpmVersion))
			warning('UniExp:Exception:Lack_dependence','UniExp:Exception:Lack_dependence：<a href="%s">%s v%s</a>',URL,Namespace,EarliestVersion);
		else
			MpmVersion=feval(MpmVersion).Me;
			if isa(MpmVersion,'matlab.mpm.Version')
				for F=["Major","Minor","Patch"]
					if EarliestVersion.(F)<MpmVersion.(F)
						break;
					elseif EarliestVersion.(F)>MpmVersion.(F)
						warning('UniExp:Exception:Dependence_version_too_low','UniExp:Exception:Dependence_version_too_low：<a href="%s">%s v%s</a>',URL,Namespace,EarliestVersion);
						break;
					end
				end
			else
				warning('UniExp:Exception:Dependence_version_too_low','UniExp:Exception:Dependence_version_too_low：<a href="%s">%s v%s</a>',URL,Namespace,EarliestVersion);
			end
		end
	end
end
V=pVersion;