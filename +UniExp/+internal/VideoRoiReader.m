classdef VideoRoiReader<ParallelComputing.IBlockRWer&VideoReader
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		PixelIndex
		ProcessData
	end
	properties(SetAccess=immutable,GetAccess=protected)
		GpuLimit
	end
	properties(SetAccess=protected)
		CollectData
	end
	methods
		function obj = VideoRoiReader(VideoRoiPath)
			obj@VideoReader(VideoRoiPath{1}(1));
			Data=obj.readFrame;
			obj.PieceSize=numel(typecast(Data(:),'uint8'));
			obj.GpuLimit=floor(double(intmax('int32'))/numel(Data));
			obj.NumPieces=obj.NumFrames;
			[SizeY,SizeX]=size(Data,1,2);
			RoiPath=VideoRoiPath{1}(2);
			[Cxy,Rxy] = UniExp.internal.ImageJRoiReadout(RoiPath);
			[~,RoiPath]=fileparts(RoiPath);
			Cx=reshape(Cxy(:,1),1,1,[]);
			Cy=reshape(Cxy(:,2),1,1,[]);
			Rx=reshape(Rxy(:,1),1,1,[]);
			Ry=reshape(Rxy(:,2),1,1,[]);
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
		function [Data,PiecesRead] = Read(obj,Start,End,~)
			if nargin>3
				End=min(End,Start+obj.GpuLimit);
			end
			Data=obj.read([Start,End]);
			PiecesRead=size(Data,4);
		end
	end
end