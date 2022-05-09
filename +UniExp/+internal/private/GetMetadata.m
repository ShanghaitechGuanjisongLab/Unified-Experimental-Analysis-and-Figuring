function Metadata=GetMetadata(Reader)
PixelType=char(Reader.PixelType);
if startsWith(PixelType,'i')
	PixelType=['u' PixelType];
end
ReaderCC=Reader.ChannelColors;
WriterCC=zeros(4,NumChannels,'uint8');
for C=1:NumChannels
	CCStruct=ReaderCC(ChannelIndex(C));
	WriterCC(:,C)=[CCStruct.A;CCStruct.B;CCStruct.G;CCStruct.R];
end
Metadata=struct(ChannelColors=typecast(WriterCC(:),'int32'),DeviceNames=Reader.DeviceNames,PixelType=PixelType,ScannerType=Reader.ScannerType,ZStack=Reader.ZStack,FrameRate=Reader.FrameRate);