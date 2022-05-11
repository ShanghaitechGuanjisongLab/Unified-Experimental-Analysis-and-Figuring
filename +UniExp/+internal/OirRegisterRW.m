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
			obj.Metadata=UniExp.internal.GetMetadata(Reader);
			obj.TagLogical=startsWith(obj.Metadata.DeviceNames,'CD');
			ChannelIndex=find(~obj.TagLogical);
			SizePXYZ=prod([uint32(Reader.SizeP) Reader.SizeX Reader.SizeY Reader.SizeZ]);
			obj.PieceSize=SizePXYZ*double(Reader.SizeC);
			obj.NumPieces=Reader.SizeT;
			NumChannels=numel(ChannelIndex);
			Sample=mean(Reader.ReadArray(X=0,Y=0,T=1:min(floor(Memory/(SizePXYZ*NumChannels)),Reader.SizeT),C=ChannelIndex,Z=0),3,"native");
			SizeC=min(size(FixedImage,3),size(Sample,4));
			SizeZ=min(size(FixedImage,4),size(Sample,5));
			tforms=cell(SizeC,SizeZ);
			RefObj=imref2d(size(Sample,[1 2]));
			%不可以用CZ，因为尺寸不一定全覆盖
			for Z=1:SizeZ
				for C=1:SizeC
					tforms{C,Z}=imregtform(Sample(:,:,1,C,Z),FixedImage(:,:,C,Z),'affine',optimizer,metric);
					Sample(:,:,1,C,Z)=imwarp(Sample(:,:,1,C,Z),tforms{C,Z},OutputView=RefObj);
				end
			end
			Sample(Sample<mean(Sample,[1 2]))=0;
			obj.FileFixed=rot90(Sample,2);
			obj.Transforms=MATLAB.DataTypes.Cell2Mat(tforms);
			import OBT5.*
			obj.Writer=OmeBigTiff5D.Create(TiffPath,CreationDisposition.Overwrite,SizeX=Reader.SizeX,SizeY=Reader.SizeY,SizeT=Reader.SizeT,SizeC=NumChannels,SizeZ=Reader.SizeZ,DimensionOrder=DimensionOrder.XYTCZ,PixelType=obj.Metadata.PixelType,ChannelColors=obj.Metadata.ChannelColors(ChannelIndex));
		end
		function Data=Read(obj,Start,End)
			Debug=Start<=933&&End>=933;
			Data={obj.Reader.ReadArray(X=0,Y=0,T=Start:End,C=0,Z=0),obj.TagLogical,obj.FileFixed,obj.Transforms,Debug};
		end		
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels5D(Data{1},[],[],Start:End);
			Data(1)=[];
		end
	end
end