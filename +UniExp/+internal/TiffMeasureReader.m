classdef TiffMeasureReader<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize double
		NumPieces double
		Metadata
		Reader OBT5.OmeBigTiff5D
	end
	methods
		function obj=TiffMeasureReader(TiffPath)
			Reader=OBT5.OmeBigTiff5D.Create(TiffPath,OBT5.CreationDisposition.OpenExisting);
			obj.Reader=Reader;
			obj.PieceSize=prod([uint32(Reader.SizeP),Reader.SizeX,Reader.SizeY,Reader.SizeZ,Reader.SizeC]);
			obj.NumPieces=Reader.SizeT;
			obj.Metadata=Reader.SizeZ;
		end
		function Data=Read(obj,Start,End)
			Data={obj.Reader.ReadPixels5D(T=Start-1:End-1,C=[],Z=[],Y=[],X=[])};%OBT5索引从0开始
		end
	end
end