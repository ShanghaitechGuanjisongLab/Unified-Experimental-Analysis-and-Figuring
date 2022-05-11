classdef TiffMeasureReader<ParallelComputing.IBlockRWer&OBT5.OmeBigTiff5D
	properties(SetAccess=immutable)
		PieceSize double
		NumPieces double
		Metadata
	end
	methods
		function obj=TiffMeasureReader(TiffPath)
			obj@OBT5.OmeBigTiff5D(TiffPath,OBT5.CreationDisposition.OpenRead);
			obj.PieceSize=prod([uint32(obj.SizeP),obj.SizeX,obj.SizeY,obj.SizeZ,obj.SizeC]);
			obj.NumPieces=obj.SizeT;
			obj.Metadata=obj.SizeZ;
		end
		function Data=Read(obj,Start,End)
			Data={obj.ReadPixels5D(T=Start-1:End-1,C=[],Z=[],Y=[],X=[])};%OBT5索引从0开始
		end
	end
end