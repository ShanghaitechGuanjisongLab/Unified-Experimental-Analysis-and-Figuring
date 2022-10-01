function Image=Decell(Image)
Mean=mean(Image,[1 2 5]);
Higher=Image>Mean;
Lower=Image<Mean;
for Z=1:size(Image,4)
	I=Image(:,:,:,Z,:);
	I(Higher(:,:,:,Z,:))=mean2(I(Lower(:,:,:,Z,:)));
	Image(:,:,:,Z,:)=I;
end
end