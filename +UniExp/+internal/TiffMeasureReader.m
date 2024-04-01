classdef TiffMeasureReader<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize double
		NumPieces double
		ProcessData={}
	end
	properties(SetAccess=protected)
		CollectData
		Reader
	end
	properties(SetAccess=immutable,GetAccess=protected)
		GpuLimit
		ReaderGetFun
	end
	methods
		function obj=TiffMeasureReader(TiffPath)
			obj.ReaderGetFun=@()Image5D.OmeTiffRWer.OpenRead(TiffPath);
			try
				Reader=obj.ReaderGetFun();
			catch ME
				if ME.identifier=="Image5D:Image5DException:File_open_failed"
					error(ME.identifier,'%s: %s',ME.identifier,TiffPath);
				else
					ME.rethrow;
				end
			end
			obj.Reader=Reader;
			SizeZ=Reader.SizeZ;
			PieceElements=prod([uint32(Reader.SizeX),Reader.SizeY,SizeZ,Reader.SizeC]);
			obj.PieceSize=PieceElements*uint32(Reader.SizeP);
			obj.NumPieces=Reader.SizeT;
			obj.CollectData=SizeZ;
			obj.GpuLimit=floor(double(intmax('int32'))/double(PieceElements));
		end
		function [Data,PiecesRead]=Read(obj,Start,End,~)
			if nargin>3
				End=min(End,Start+obj.GpuLimit-1);
			end
			[Data,obj.Reader]=TryRead(obj.Reader,obj.ReaderGetFun,Start-1,End-Start+1);
			PiecesRead=size(Data,5);
		end
	end
end