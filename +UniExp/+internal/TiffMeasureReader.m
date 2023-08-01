classdef TiffMeasureReader<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize double
		NumPieces double
		CollectData
		Reader Image5D.OmeTiffRWer
		ProcessData={}
	end
	properties(SetAccess=immutable,GetAccess=protected)
		GpuLimit
	end
	methods
		function obj=TiffMeasureReader(TiffPath)
			Reader=Image5D.OmeTiffRWer.OpenRead(TiffPath);
			obj.Reader=Reader;
			SizeZ=Reader.SizeZ;
			PieceElements=prod([uint32(Reader.SizeX),Reader.SizeY,SizeZ,Reader.SizeC]);
			obj.PieceSize=PieceElements*Reader.SizeP;
			obj.NumPieces=Reader.SizeT;
			obj.CollectData=SizeZ;
			obj.GpuLimit=floor(double(intmax('int32'))/double(PieceElements));
		end
		function [Data,PiecesRead]=Read(obj,Start,End,~)
			if nargin>3
				
			end
			Data=obj.Reader.ReadPixels(Start-1,End-Start+1);
		end
	end
end