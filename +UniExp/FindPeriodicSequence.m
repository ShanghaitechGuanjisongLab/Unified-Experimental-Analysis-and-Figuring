%[text] 寻找周期性序列
%[text] 于FindSequence，此方法需要提供完整信号，并假定序列会周期性循环，而提供的信号是在这些周期中随机截取的一段，因而可能不像经过Cue调制后的那样具有固定的起始相位。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] [Sequence,PLV]=UniExp.FindPeriodicSequence(MaxTimes);
%[text] ```
%[text] ## 输入参数
%[text] Signal(:,:,:)，第1维回合，第2维时间，第3维细胞。
%[text] ## 返回值
%[text] Cells(:,:)，序列中包含的细胞。第1维按照显著性从高到低（而非时相）顺序排列序列中可能包含的细胞索引。第2维从低到高排列不同的假定频率，例如第1列假定采样时段内有1个周期，第2列假定2个周期，以此类推。
%[text] Phases(:,:)complex，序列中细胞在第1回合的时相，和Cells一一对应，用单位复数表示，可以用angle函数取得其辐角以按时相排列细胞。
%[text] Significance(:,:)，序列截至该细胞之前的显著性P值，在第1维上从小到大排列（即显著性由高到低），与Cells一一对应。例如，在位置3上的P值为0.05，表示该序列中有3个细胞的显著性水平达到0.05，在Cells表中的前3个位置上记录了具体是哪3个细胞。第一行恒为0。
%[text] **See also** [UniExp.PeriodicSequencePLV](<matlab:doc UniExp.PeriodicSequencePLV>)
function [Cells,Phases,Significance]=FindPeriodicSequence(Signal)
	[NumTrials,TimeLength,NumCells]=size(Signal);
	Signal=fft(Signal,[],2);
	Signal=Signal(:,2:ceil((TimeLength+1)/2),:);
	NumFrequencies=size(Signal,2);
	Phases=Signal./abs(Signal);
	Signal=Phases(2:end,:,:).*conj(Phases(1,:,:));
	[Cells,Significance]=deal(zeros(NumCells,NumFrequencies));
	PLV=Signal+permute(Signal,[1,2,4,3]);
	PLV(:,:,1:NumCells+1:end)=NaN;
	[Statistic,Cells(1,:),Cells(2,:)]=MATLAB.DataFun.MaxSubs(sum(abs(PLV),1),3:4);
	NumTrials=NumTrials-1;
	IndexOffset=1:NumFrequencies;
	Significance(2,:)=1-normcdf(Statistic,sqrt(2)*NumTrials,sqrt(NumTrials));
	Index=(Cells(1:2,:)-1)*NumFrequencies+IndexOffset;
	PLV=Signal(:,Index(1,:))+Signal(:,Index(2,:));
	Signal(:,Index)=NaN;
	for C=3:NumCells
		[Statistic,Cells(C,:)] = max(sum(abs(PLV+Signal),1),3);
		Significance(C,:)=normcdf(Statistic,sqrt(C)*NumTrials,sqrt(C*NumTrials/2));
		PLV=PLV+Signal(:,(Cells(C,:)-1)*NumFrequencies+IndexOffset);
		if all(Significance(C,:)<0.95)
			break;
		end
	end
	Cells=Cells(1:C,:);
	Significance=1-Significance(1:C,:);
	Phases=reshape(geomean(Phases,1),[],1);
	Phases=Phases((Cells-1)*NumFrequencies+IndexOffset);
end

%[appendix]{"version":"1.0"}
%---
