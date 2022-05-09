classdef OirRegisterRW<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		Metadata
	end
	properties(SetAccess=immutable,GetAccess=private)
		Reader OmeBioformats5D.OirReader5D
		Writer OBT5.OmeBigTiff5D
		TagLogical
		FileFixed
		Transforms
	end
	methods
		function obj = OirRegisterRW(OirPath,TiffPath,FixedImage,Memory)
			persistent optimizer metric
			if isempty(optimizer)
				[optimizer, metric] = imregconfig('multimodal');
				metric.NumberOfSpatialSamples = 500;
				metric.NumberOfHistogramBins = 50;
				metric.UseAllPixels = true;
				optimizer.GrowthFactor = 1.050000;
				optimizer.Epsilon = 1.50000e-06;
				optimizer.InitialRadius = 6.25000e-03;
				optimizer.MaximumIterations = 100;
			end
			Reader=OmeBioformats5D.OirReader5D(OirPath);
			obj.Reader=Reader;
			obj.Metadata=GetMetadata(Reader);
			obj.TagLogical=startsWith(obj.Metadata.DeviceNames,'CD');
			ChannelIndex=find(~obj.TagLogical);
			SizePXYZ=prod([uint32(Reader.SizeP) Reader.SizeX Reader.SizeY Reader.SizeZ]);
			obj.PieceSize=SizePXYZ*Reader.SizeC;
			obj.NumPieces=Reader.SizeT;
			NumChannels=numel(ChannelIndex);
			Sample=mean(Reader.ReadArray(X=0,Y=0,C=ChannelIndex,Z=0,T=1:floor(Memory/(SizePXYZ*NumChannels))),5,"native");
			SizeC=min(size(FixedImage,3),size(Sample,3));
			SizeZ=min(size(FixedImage,4),size(Sample,4));
			tforms=cell(SizeZ,SizeC);
			RefObj=imref2d(size(Sample,[1 2]));
			%不可以用CZ，因为尺寸不一定全覆盖
			for C=1:SizeC
				for Z=1:SizeZ
					tforms{Z,C}=imregtform(Sample(:,:,Z,C),FixedImage(:,:,Z,C),'affine',optimizer,metric);
					Sample(:,:,Z,C)=imwarp(Sample(:,:,Z,C),tforms{Z,C},OutputView=RefObj);
				end
			end
			Sample(Sample<mean(Sample,[1 2]))=0;
			obj.FileFixed=Sample;
			obj.Transforms=MATLAB.DataTypes.Cell2Mat(tforms);
			import OBT5.*
			obj.Writer=OmeBigTiff5D.Create(TiffPath,CreationDisposition.Overwrite,SizeX=Reader.SizeX,SizeY=Reader.SizeY,SizeT=Reader.SizeT,SizeZ=Reader.SizeZ,SizeC=NumChannels,DimensionOrder=DimensionOrder.XYTZC,PixelType=obj.Metadata.PixelType,ChannelColors=obj.Metadata.ChannelColors);
		end
		function Data=Read(obj,Start,End)
			Data={obj.Reader.ReadArray(X=0,Y=0,T=Start:End,Z=0,C=0),obj.TagLogical,obj.FileFixed,obj.Transforms};
		end		
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels5D(Data{1},[],[],Start:End);
			Data(1)=[];
		end
	end
end