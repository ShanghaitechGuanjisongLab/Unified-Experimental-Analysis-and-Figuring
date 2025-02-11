function [data,Ysiz,d1,d2,numFrame,dir_nm,file_nm]=CnmfeChooseData(nam)
	Reader=Image5D.OmeTiffRWer.OpenRead(nam);
	data=struct;
	data.Y=Reader.ReadPixels;
	data.Ysiz=size(data.Y,[1,2,5]);
	Ysiz = data.Ysiz;
	d1 = Ysiz(1);   %height
	d2 = Ysiz(2);   %width
	numFrame = Ysiz(3);    %total number of frames
	[dir_nm,file_nm]=fileparts(nam);
	fprintf('\nThe data has been mapped to RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1, d2, numFrame, prod(Ysiz)*8/(2^30));
end