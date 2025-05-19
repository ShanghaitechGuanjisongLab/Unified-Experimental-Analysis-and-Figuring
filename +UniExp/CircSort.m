%[text] 对回合信号进行循环移位，以使每个细胞尽可能具有确定的相对活动顺序
%[text] 此函数对多回合多细胞时间信号序列进行排序，但假定回合信号是可以随意循环移位，而非具有固定时相的。此方法适用于随机截取而没有特定标志性同步事件的信号。
%[text] ## 语法
%[text] ```matlabCodeExample
%[text] [Sorted,Cells,TrialOffset] = UniExp.CircSort(Signal)
%[text] ```
%[text] ## 输入参数
%[text] Signal(:,:,:)，回合细胞时间序列信号，第1维时间，第2维细胞，第3维回合
%[text] ## 返回值
%[text] Sorted(:,:)，归一化和排序后的回合平均信号。第1维时间，第2维是经过重排序的细胞。归一化的方法是通过线性变换使得数据最小值为0，平均值为1。
%[text] Cells(:,3)table，细胞详情，一行一个细胞，按照Sorted重排后的顺序排列。包含以下列：
%[text] - Index，细胞在原本输入Signal中的位置
%[text] - Phase，细胞的信号集中相，指示Sorted中的一个时间点，该细胞的信号集中在该时点附近，用作实际的排序指标。
%[text] - PLV，细胞的锁相值，反映细胞在序列中位置的稳定度，越大越稳定；最小为0则表示该细胞在序列中没有任何位置倾向性。 \
%[text] TrialOffset(:,1)，每个回合的循环偏移。可以使用circshift对输入Signal的每个回合分别进行循环移位，得到序列时相对齐的信号。
%[text] **See also** [circshift](<matlab:doc circshift>)
function [Sorted,Cells,TrialOffset] = CircSort(Signal)
persistent Pi2
if isempty(Pi2)
	Pi2=2*pi;
end
[TimeLength,NumTrials]=size(Signal,1,3);
Phases=linspace(-pi,pi,TimeLength+1);
TimeIndex=0:TimeLength-1;
Signal=Signal-min(Signal,1);
Signal=Signal./mean(Signal,1);
Signal(ismissing(Signal))=1;
TrialOffset=ones(NumTrials,1);
Signal=reshape(Signal(mod(TimeIndex+TimeIndex.',TimeLength)+1,:,:),TimeLength,TimeLength,[],NumTrials).*exp(Phases(2:end).'*1i);
Sorted=Signal(:,1,:,1);
for T=2:NumTrials
	Sorted=Sorted+Signal(:,:,:,T);
	[~,TrialOffset(T)]=max(sum(abs(sum(Sorted,1)),3),[],2);
	Sorted=Sorted(:,TrialOffset(T),:);
end
Cells=table;
Cells.Phase=squeeze(sum(Sorted,1));
Cells.PLV=abs(Cells.Phase);
OverallOffset=-angle(sum(Cells.Phase))/Pi2;
[Cells.Phase,Cells.Index]=sort((RemToAbsMin(angle(Cells.Phase)/Pi2+OverallOffset,1)+0.5)*TimeLength+1);
OverallOffset=int16(RemToAbsMin(OverallOffset,1)*TimeLength);
TrialOffset=RemToAbsMin(1-int16(TrialOffset)+OverallOffset,TimeLength);
Sorted=reshape(circshift(abs(Sorted(:,:,Cells.Index)),OverallOffset,1),TimeLength,[])/NumTrials;
end
function R=RemToAbsMin(Phase,Cycle)
R=mod(Phase,Cycle);
Logical=R>Cycle/2;
R(Logical)=R(Logical)-Cycle;
end

%[appendix]{"version":"1.0"}
%---
