classdef TiffTransformer<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize double
		NumPieces double
		CollectData
		ProcessData
	end
	properties
		Reader Image5D.OmeTiffRWer
		Writer Image5D.OmeTiffRWer
	end
	methods
		function obj=TiffTransformer(TiffPath,TransMatrix,OutputDirectory)
			import Image5D.*
			[~,Filename]=fileparts(TiffPath);
			if exist('OutputDirectory','var')
				obj.Reader=OmeTiffRWer.OpenRead(TiffPath);
				obj.Writer=OmeTiffRWer.Create(fullfile(OutputDirectory,Filename+".变换.tif"),obj.Reader.ImageDescription);
			else
				obj.Reader=OmeTiffRWer.OpenRW(TiffPath);
				obj.Writer=obj.Reader;
			end
			if obj.Reader.SizeZ~=numel(TransMatrix)
				UniExp.UniExpException.ZLayers_of_the_moving_ROI_and_file_do_not_match.Throw(Filename);
			end
			obj.PieceSize=prod([uint32(obj.Reader.SizeX),obj.Reader.SizeY,obj.Reader.SizeP,obj.Reader.SizeC,obj.Reader.SizeZ]);
			obj.NumPieces=obj.Reader.SizeT;
			obj.ProcessData=TransMatrix;
			obj.CollectData=obj.NumPieces;
		end
		function Data=Read(obj,Start,End)
			Data=obj.Reader.ReadPixels(Start-1,End-Start+1);
		end
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data{1},Start-1,End-Start+1);
			Data(1)=[];
		end
	end
end