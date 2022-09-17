function [Numerator,Denominator,XCorrs] = NxcInvariant(Fixed,MaxTranslationStep)
Fixed=double(Fixed);
Numerator=LocalSum(Fixed);
%1,2参数不能少，否则SizeY会把后续维度全部乘上
[SizeX,SizeY]=size(Fixed,1,2);
XRange=SizeX-MaxTranslationStep:SizeX+MaxTranslationStep;
YRange=SizeY-MaxTranslationStep:SizeY+MaxTranslationStep;
Numerator=Numerator(XRange,YRange,:,:);
Denominator=LocalSum(Fixed.*Fixed);
Denominator=sqrt(max(Denominator(XRange,YRange,:,:)*SizeX*SizeY-Numerator.*Numerator,0));
Denominator(Denominator<sqrt(eps(max(Denominator,[],[1,2]))))=Inf;
XCorrs=fft2(rot90(Fixed,2),SizeX*2-1,SizeY*2-1);
function A = LocalSum(A)
[m,n]=size(A,1,2);
A = cumsum(padarray(A,[m n]),1);
A = cumsum(A(1+m:end-1,:,:,:,:)-A(1:end-m-1,:,:,:,:),2);
A = A(:,1+n:end-1,:,:,:)-A(:,1:end-n-1,:,:,:);