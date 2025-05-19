%[text] 寻找周期性序列
%[text] 于FindSequence，此方法需要提供完整信号，并假定序列会周期性循环，而提供的信号是在这些周期中随机截取的一段，因而可能不像经过Cue调制后的那样具有固定的起始相位。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] [Sequence,PLV]=UniExp.FindPeriodicSequence(MaxTimes);
%[text] ```
%[text] ## 输入参数
%[text] Signal(:,:,:)，第1维回合，第2维时间，第3维细胞。如果包含缺失值，将全部用0填充。
%[text] PlvTolerable(1,1)，序列能够容忍的PLV下限，可以理解为要求该序列在至少多少回合中出现。该值的范围是\[0,回合数\]。
%[text] ## 返回值
%[text] Cells(:,:)，序列中包含的细胞。第1维按照显著性从高到低（而非时相）顺序排列序列中可能包含的细胞索引。第2维从低到高排列不同的假定频率，例如第1列假定采样时段内有1个周期，第2列假定2个周期，以此类推。
%[text] Phases(:,:)complex，序列中细胞在第1回合的时相，和Cells一一对应，用单位复数表示，可以用angle函数取得其辐角以按时相排列细胞。
%[text] Significance(:,:)，序列截至该细胞之前的显著性P值，在第1维上从小到大排列（即显著性由高到低），与Cells一一对应。例如，在位置3上的P值为0.05，表示该序列中有3个细胞的显著性水平达到0.05，在Cells表中的前3个位置上记录了具体是哪3个细胞。第一行恒为0。
%[text] **See also** [UniExp.PeriodicSequencePLV](<matlab:doc UniExp.PeriodicSequencePLV>) [angle](<matlab:doc angle>)
function [Cells,Phases,PLV]=FindPeriodicSequence(Signal)
Signal(ismissing(Signal))=0;
[NumTrials,TimeLength,NumCells]=size(Signal);
Signal=fft(Signal,[],2);
Signal=Signal(:,2:ceil((TimeLength+1)/2),:);
NumFrequencies=size(Signal,2);

Signal=Signal./abs(Signal);
%所有回合×频率×细胞的相位。

%如果有两个细胞存在序列关系，则它们在任何同一回合内的相位差应该相同，即具有较大的锁相值（PLV）
PhaseDiff=abs(sum(Signal.*conj(permute(Signal,[1,2,4,3])),1));

%为各频率找到PLV最大的细胞对作为序列的前两个细胞
PhaseDiff(:,:,1:NumCells+1:end)=NaN;
[Cells,PLV]=deal(NaN(NumCells,NumFrequencies));
PLV(1,:)=NumTrials;
Phases=NaN(size(Signal));
[PLV(2,:),Cells(1,:),Cells(2,:)]=MATLAB.DataFun.MaxSubs(PhaseDiff,3:4);
IndexOffset=1:NumFrequencies;
Index=((Cells(1:2,:)-1)*NumFrequencies+IndexOffset).';
Phases(:,:,1:2)=reshape(Signal(:,Index),NumTrials,NumFrequencies,2);
SequenceLength=2;
SequencePhase=Phases(:,:,1);
while true
	Logical=~(PLV(SequenceLength,:)>PlvTolerable);%不能用<，因为要考虑NaN
	if all(Logical)
		break;
	end
	Signal(:,Index)=NaN;
	Signal(:,Logical,:)=NaN;
	SequencePhase=SequencePhase+Phases(:,:,SequenceLength);
	if SequenceLength>=NumCells
		break;
	end
	SequenceLength=SequenceLength+1;
	[PLV(SequenceLength,:),Cells(SequenceLength,:)]=max(abs(sum(Signal.*conj(SequencePhase./abs(SequencePhase)),1)),[],3);
	Index=(Cells(SequenceLength,:)-1)*NumFrequencies+IndexOffset;
	Cells(SequenceLength,Logical)=NaN;
	Phases(:,:,SequenceLength)=Signal(:,Index);
	Phases(:,Logical,SequenceLength)=NaN;
end
Cells=Cells(1:SequenceLength,:);
PLV=PLV(1:SequenceLength,:);
Phases=sum(Phases(:,:,1:SequenceLength),1);
Phases=permute(Phases./abs(Phases),[3,2,1]);
end

%[appendix]{"version":"1.0"}
%---
