function [Cxy,Rxy,Zs] = ImageJRoiReadout(RoiSet)
RoiSet=UniExp.internal.ReadImageJROI(RoiSet);
RoiSet=struct2table(vertcat(RoiSet{:})).vnRectBounds;
Cxy=([RoiSet(:,2)+RoiSet(:,4),RoiSet(:,1)+RoiSet(:,3)]+1)/2;
Rxy=[RoiSet(:,4)-RoiSet(:,2),RoiSet(:,3)-RoiSet(:,1)]/2;
if RoiSet.nPosition(1)
	Zs=RoiSet.nPosition;
else
	Zs=ones(size(RoiSet.nPosition));
end