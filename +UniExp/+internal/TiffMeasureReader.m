classdef TiffMeasureReader<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize double
		NumPieces double
		CollectData
		Reader Image5D.OmeTiffRWer
		ProcessData={}
	end
	methods
		function obj=TiffMeasureReader(TiffPath)
			Reader=Image5D.OmeTiffRWer.OpenRead(TiffPath);
			obj.Reader=Reader;
			SizeZ=Reader.SizeZ;
			obj.PieceSize=prod([uint32(Reader.SizeP),Reader.SizeX,Reader.SizeY,SizeZ,Reader.SizeC]);
			obj.NumPieces=Reader.SizeT;
			obj.CollectData=SizeZ;
		end
		function Data=Read(obj,Start,End)
			Data=obj.Reader.ReadPixels(Start-1,End-Start+1);
		end
	end
end