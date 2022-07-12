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
		XCorrs
		Numerator
		Denominator
		MovingChannel
	end
	methods(Static,Access=private)
		function A = LocalSum(A)
			[m,n]=size(A,1,2);
			A = cumsum(padarray(A,[m n]),1);
			A = cumsum(A(1+m:end-1,:,:,:,:)-A(1:end-m-1,:,:,:,:),2);
			A = A(:,1+n:end-1,:,:,:)-A(:,1:end-n-1,:,:,:);
		end
		function Data=TryRead(Reader,TStart,TSize,varargin)
			Wait=0x001;
			TryCount=0x1;
			while true
				try
					Data=Reader.ReadPixels(TStart,TSize,varargin{:});
					break;
				catch ME
					if ME.identifier=="Image5D:Memory_copy_failed"
						warning('文件读入失败，可能是持有文件的设备断开了连接，请检查设备。将在%u秒后重试。',Wait);
						pause(Wait);
						Wait=bitshift(Wait,1);
						TryCount=TryCount+1;
						warning('第%u次尝试读入：',TryCount);
					else
						throw(ME);
					end
				end
			end
		end
	end
	methods
		function obj = OirRegisterRW(OirPath,TiffPath,FixedImage,Memory,MaxTranslationStep,MovingChannel)
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
			import UniExp.internal.OirRegisterRW
			obj.Reader=OirReader(OirPath);
			[Devices,Colors]=obj.Reader.DeviceColors;
			obj.Metadata=struct(ChannelColors=Colors,DeviceNames=Devices,SeriesInterval=obj.Reader.SeriesInterval);
			obj.TagLogical=startsWith(obj.Metadata.DeviceNames,'CD');
			[SizeX,SizeY,SizeZ]=size(FixedImage,1,2,4);
			SizePXYZ=2*SizeX*SizeY*SizeZ;
			obj.PieceSize=SizePXYZ*double(obj.Reader.SizeC);
			obj.NumPieces=obj.Reader.SizeT;
			Sample=mean(OirRegisterRW.TryRead(obj.Reader,0,min(floor(Memory/SizePXYZ),obj.NumPieces),MovingChannel-1),5);
			SizeZ=min(size(FixedImage,4),size(Sample,4));
			tforms=cell(SizeZ,1);
			RefObj=imref2d([SizeX,SizeY]);
			%不可以用CZ，因为尺寸不一定全覆盖
			for Z=1:SizeZ
				tforms{Z}=imregtform(Sample(:,:,:,Z),FixedImage(:,:,:,Z),'affine',optimizer,metric);
			end
			Sample=gpuArray(Sample);
			for Z=1:SizeZ
				Sample(:,:,:,Z)=imwarp(Sample(:,:,:,Z),tforms{Z},OutputView=RefObj);
			end
			obj.Transforms=MATLAB.DataTypes.Cell2Mat(tforms);
			ColorLogical=~obj.TagLogical;
			Colors=Colors(:,ColorLogical);
			Colors(4,:)=1;
			obj.Writer=OmeTiffRWer.Create(TiffPath,PixelType.UINT16,SizeX,SizeY,ChannelColor.New(flipud(Colors)),SizeZ,obj.NumPieces,DimensionOrder.XYCZT);
			Sample=double(Sample);
			obj.Numerator=OirRegisterRW.LocalSum(Sample);
			XRange=SizeX-MaxTranslationStep:SizeX+MaxTranslationStep;
			YRange=SizeY-MaxTranslationStep:SizeY+MaxTranslationStep;
			obj.Numerator=obj.Numerator(XRange,YRange,:,:);
			obj.Denominator=OirRegisterRW.LocalSum(Sample.*Sample);
			obj.Denominator=sqrt(max(obj.Denominator(XRange,YRange,:,:)*SizeX*SizeY-obj.Numerator.*obj.Numerator,0));
			obj.Denominator(obj.Denominator<sqrt(eps(max(obj.Denominator,[],[1,2]))))=Inf;
			obj.XCorrs=gather(fft2(rot90(Sample,2),SizeX*2-1,SizeY*2-1));
			obj.Numerator=gather(obj.Numerator);
			obj.Denominator=gather(obj.Denominator);
			obj.MovingChannel=nnz(ColorLogical(1:MovingChannel));
		end
		function Data=Read(obj,Start,End)
			Data={UniExp.internal.OirRegisterRW.TryRead(obj.Reader,Start-1,End-Start+1),obj.TagLogical,obj.Transforms,obj.XCorrs,obj.Numerator,obj.Denominator,obj.MovingChannel};
		end		
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data{1},Start-1,End-Start+1);
			Data(1)=[];
		end
	end
end