classdef OirRegisterRW<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		CollectData
		ProcessData
	end
	properties(SetAccess=immutable,GetAccess=private)
		Reader Image5D.OirReader
		Writer Image5D.OmeTiffRWer
	end
	properties(Access=private)
		Progress(1,1)uint8
	end
	methods(Static,Access=public)
		function Data=TryRead(Reader,TStart,TSize,varargin)
			Wait=0x001;
			TryCount=0x1;
			while true
				try
					Data=Reader.ReadPixels(TStart,TSize,varargin{:});
					break;
				catch ME
					if ME.identifier=="Image5D:Image5DException:Memory_copy_failed"
						warning('文件读入失败，可能是持有文件的设备断开了连接，请检查设备。将在%u秒后重试。',Wait);
						pause(Wait);
						Wait=bitshift(Wait,1);
						TryCount=TryCount+1;
						warning('第%u次尝试读入：',TryCount);
					else
						rethrow(ME);
					end
				end
			end
		end
	end
	methods
		function obj = OirRegisterRW(OirPath,TiffPath,MovingChannel,ClearGpu,FIOrTM,MemoryOrSampleSize)
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
			obj.CollectData=struct(ChannelColors=Colors,DeviceNames=Devices,SeriesInterval=obj.Reader.SeriesInterval);
			TagLogical=startsWith(obj.CollectData.DeviceNames,'CD');
			FIMode=isnumeric(FIOrTM);
			if FIMode
				[SizeX,SizeY,SizeZ]=size(FIOrTM,1,2,4);
			else
				SizeX=double(obj.Reader.SizeX);
				SizeY=double(obj.Reader.SizeY);
				SizeZ=numel(FIOrTM);
			end
			SizePXYZ=2*SizeX*SizeY*SizeZ;
			obj.PieceSize=SizePXYZ*double(obj.Reader.SizeC);
			obj.NumPieces=obj.Reader.SizeT;%20
			fprintf('共%u帧：\n|----------------------------------------------------------------------------------------------------|\n|',obj.NumPieces);
			obj.Progress=0;
			if ClearGpu
				gpuDevice().reset;
			end
			if FIMode
				SampleHalf=floor(min(MemoryOrSampleSize/SizePXYZ,obj.NumPieces)/2);
				MovingImage=gpuArray(mean(cat(5,OirRegisterRW.TryRead(obj.Reader,0,SampleHalf,MovingChannel-1),OirRegisterRW.TryRead(obj.Reader,obj.NumPieces-SampleHalf,SampleHalf,MovingChannel-1)),5));
				SizeZ=min(size(FIOrTM,4),size(MovingImage,4));
				FIOrTM=gpuArray(FIOrTM(:,:,:,1:SizeZ));
				MovingImage=MovingImage(:,:,:,1:SizeZ);
				tforms=cell(SizeZ,1);
				%不可以用CZ，因为尺寸不一定全覆盖
				%% 策略测试：对齐质心、去细胞
				FIOrTM=imgaussfilt(double(FIOrTM),20);
				MovingImage=imgaussfilt(MovingImage,20);
				[Ys,Xs] = meshgrid(1:SizeY,1:SizeX);
				sumFixedIntensity = sum(FIOrTM,[1 2 3]);
				sumMovingIntensity = sum(MovingImage,[1 2 3]);
				FIRow=double(reshape(FIOrTM,1,[],1,SizeZ));
				MIRow=double(reshape(MovingImage,1,[],1,SizeZ));
				Translation=permute([pagemtimes(FIRow,Ys(:))./sumFixedIntensity-pagemtimes(MIRow,Ys(:))./sumMovingIntensity,pagemtimes(FIRow,Xs(:))./sumFixedIntensity-pagemtimes(MIRow,Xs(:))./sumMovingIntensity],[2 4 1 3]);
				initTform = affinetform2d;
				FIOrTM=gather(FIOrTM);
				MovingGathered=gather(MovingImage);
				for Z=1:SizeZ
					initTform.A(1:2,3) = Translation(:,Z);
					tforms{Z}=imregtform(MovingGathered(:,:,:,Z),FIOrTM(:,:,:,Z),'rigid',optimizer,metric,InitialTransformation=initTform);
				end
				%%
				% 			for Z=1:SizeZ
				% 				MovingImage(:,:,:,Z)=imwarp(MovingImage(:,:,:,Z),tforms{Z},OutputView=imref2d(size(MovingImage,[1 2])));
				% 			end
				Transforms=vertcat(tforms{:});
			else
				SampleIndex=uint16(linspace(0,double(obj.NumPieces-1),MemoryOrSampleSize));
				MovingImage=zeros(SizeX,SizeY,1,SizeZ,MemoryOrSampleSize,'gpuArray');
				for T=1:MemoryOrSampleSize
					MovingImage(:,:,:,:,T)=OirRegisterRW.TryRead(obj.Reader,SampleIndex(T),1,MovingChannel-1);
				end
				Transforms=FIOrTM;
			end
			ColorLogical=~TagLogical;
			obj.Writer=OmeTiffRWer.Create(TiffPath,PixelType.UINT16,SizeX,SizeY,ChannelColor.FromOirColors(Colors(:,ColorLogical)),SizeZ,obj.NumPieces,DimensionOrder.XYCZT);
			obj.ProcessData={TagLogical,Transforms,structfun(@gather,ImageProcessing.Nxc2TPreprocess(permute(MovingImage-imgaussfilt(MovingImage,20)+mean(MovingImage,1:2),[1,2,3,4,6,5]),[SizeX,SizeY]),UniformOutput=false),nnz(ColorLogical(1:MovingChannel)),SampleIndex+1};
			%GPU内存不会自动清理，必须手动清理
			gpuDevice([]);
		end
		function Data=Read(obj,Start,End)
			Data={UniExp.internal.OirRegisterRW.TryRead(obj.Reader,Start-1,End-Start+1),Start,End};
		end
		function Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data,Start-1,End-Start+1);
			ProgressAdd=End*50/obj.NumPieces-obj.Progress;
			fprintf(repmat('🐭',1,ProgressAdd));
			obj.Progress=obj.Progress+ProgressAdd;
			if obj.Progress>=50
				fprintf('|\n');
			end
		end
	end
end