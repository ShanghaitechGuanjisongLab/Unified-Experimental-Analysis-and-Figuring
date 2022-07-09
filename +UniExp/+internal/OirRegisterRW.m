classdef OirRegisterRW<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		Metadata
	end
	properties(SetAccess=immutable,GetAccess=private)
		Reader Image5D.OirReader
		Writer Image5D.OmeTiffRWer
		TagLogical
		Transforms
		SizeZ
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
			import Image5D.*
			obj.Reader=OirReader(OirPath);
			[Devices,Colors]=obj.Reader.DeviceColors;
			obj.Metadata=struct(ChannelColors=Colors,DeviceNames=Devices,SeriesInterval=obj.Reader.SeriesInterval);
			obj.TagLogical=startsWith(obj.Metadata.DeviceNames,'CD');
			ChannelIndex=find(~obj.TagLogical);
			SizeX=obj.Reader.SizeX;
			SizeY=obj.Reader.SizeY;
			if ~all([SizeX,SizeY]==size(FixedImage,[1,2]))
				UniExp.UniExpException.Image_size_does_not_match.Throw;
			end
			SizePXYZ=prod([uint32(2) SizeX SizeY obj.Reader.SizeZ]);
			SizeC=double(obj.Reader.SizeC);
			obj.PieceSize=SizePXYZ*SizeC;
			obj.NumPieces=obj.Reader.SizeT;
			Sample=TryRead(obj.Reader,0,min(floor(Memory/(SizePXYZ*SizeC)),obj.NumPieces));
			Sample=mean(permute(Sample(:,:,ChannelIndex,:,:),[1 2 5 3 4]),3);
            SizeC=min(size(FixedImage,3),size(Sample,4));
			obj.SizeZ=min(size(FixedImage,4),size(Sample,5));
			tforms=cell(SizeC,obj.SizeZ);
			%不可以用CZ，因为尺寸不一定全覆盖
			for Z=1:obj.SizeZ
				for C=1:SizeC
					tforms{C,Z}=imregtform(Sample(:,:,1,C,Z),FixedImage(:,:,C,Z),'affine',optimizer,metric);
				end
			end
			obj.Transforms=MATLAB.DataTypes.Cell2Mat(tforms);
			Colors=Colors(:,ChannelIndex);
			Colors(4,:)=1;
			obj.Writer=OmeTiffRWer.Create(TiffPath,PixelType.UINT16,SizeX,SizeY,ChannelColor.New(flipud(Colors)),obj.SizeZ,obj.NumPieces,DimensionOrder.XYTCZ);
		end
		function Data=Read(obj,Start,End)
			Data={permute(TryRead(obj.Reader,Start-1,End-Start+1,0,obj.SizeZ),[1 2 5 3 4]),obj.TagLogical,obj.Transforms};
		end		
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data{1},Start-1,End-Start+1);
			Data(1)=[];
		end
	end
end