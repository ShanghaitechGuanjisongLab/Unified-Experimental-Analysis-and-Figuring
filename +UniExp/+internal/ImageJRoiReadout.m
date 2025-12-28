function [Cxy,Rxy,Zs] = ImageJRoiReadout(RoiSet)
RoiSet=ReadImageJROI(RoiSet);
if ~iscell(RoiSet)
	RoiSet = {RoiSet};
end
RoiSet=struct2table(vertcat(RoiSet{:}));
Positions=RoiSet.vnRectBounds;
Cxy=([Positions(:,2)+Positions(:,4),Positions(:,1)+Positions(:,3)]+1)/2;
Rxy=[Positions(:,4)-Positions(:,2),Positions(:,3)-Positions(:,1)]/2;
if RoiSet.nPosition(1)
	Zs=RoiSet.nPosition;
else
	Zs=ones(size(RoiSet.nPosition));
end