classdef VideoRoiReader<ParallelComputing.IBlockRWer&VideoReader
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		PixelIndex
		CollectData
		ProcessData
	end
	methods
		function obj = VideoRoiReader(VideoRoiPath)
			obj@VideoReader(VideoRoiPath{1}(1));
			Data=obj.readFrame;
			obj.PieceSize=numel(typecast(Data(:),'uint8'));
			obj.NumPieces=obj.NumFrames;
			[SizeY,SizeX]=size(Data,1,2);
			RoiPath=VideoRoiPath{1}(2);
			[Cx,Cy,Rx,Ry] = UniExp.internal.ImageJRoiReadout(RoiPath);
			[~,RoiPath]=fileparts(RoiPath);
			Cx=reshape(Cx,1,1,[]);
			Cy=reshape(Cy,1,1,[]);
			Rx=reshape(Rx,1,1,[]);
			Ry=reshape(Ry,1,1,[]);
			Data=((1:SizeX)-Cx).^2./Rx.^2+((1:SizeY)'-Cy).^2./Ry.^2<=1;
			NumRois=size(Data,3);
			[obj.PixelIndex,PixelYX]=deal(cell(NumRois,1));
			for R=1:NumRois
				Index=find(Data(:,:,R));
				[Y,X]=ind2sub([SizeY,SizeX],Index);
				PixelYX{R}=[Y,X];
				obj.PixelIndex{R}=Index;
			end
			obj.CollectData={obj.FrameRate,PixelYX,RoiPath};
			obj.ProcessData={obj.PixelIndex};
		end
		function Data = Read(obj,Start,End)
			Data=obj.read([Start,End]);
		end
	end
end