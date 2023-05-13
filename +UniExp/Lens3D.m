classdef Lens3D
	%二维透镜模型。此类为预发布的测试版，随时可能更改。
	properties(SetAccess=immutable)
		SpeedFunction
		OdeFunction
		SubsIndex
	end
	methods
		function obj = Lens3D(SpeedFunction)
			%SpeedFunction必须在XYZ平面上处处可微
			persistent Model S
			if isempty(Model)
				syms X(t) Y(t) Z(t) S(Sx,Sy,Sz)
				X1=diff([X;Y;Z]);
				Y1=diff([Y;Z;X]);
				Z1=diff([Z;X;Y]);
				St=S(X(t),Y(t),Z(t));
				Sx=diff(S,Sx);
				Sy=diff(S,Sy);
				Sz=diff(S,Sz);
				Sx1=[Sx;Sy;Sz];
				Sy1=[Sy;Sz;Sx];
				Sz1=[Sz;Sx;Sy];
				Sx1=Sx1(X(t),Y(t),Z(t));
				Sy1=Sy1(X(t),Y(t),Z(t));
				Sz1=Sz1(X(t),Y(t),Z(t));
				Model=4*(St.*diff(X1)-(X1.*Sx1+Y1.*Sy1+Z1.*Sz1).*X1).*(X1.^2+Y1.^2+Z1.^2)==pi*St.^2.*((Y1.*Sy1+Z1.*Sz1).*X1-(Y1.^2+Z1.^2).*Sx1);
			end
			[Equations,Substitutions]=odeToVectorField(subs(Model,S,SpeedFunction));
			obj.OdeFunction=eval(regexprep(char(matlabFunction(Equations,Vars=["t","Y"])),'Y\((\d)\)','Y($1,:)'));
			obj.SpeedFunction=matlabFunction(SpeedFunction);
			[~,obj.SubsIndex]=ismember(["X","Y","Z","DX","DY","DZ"],Substitutions);		
		end
		function [LightPath,TimePoints] = Incident(obj,Start,TimeTo)
			%Start数组，第1维XYZ，第2维位置/速度，第3维点。
			Start(:,2,:)=Start(:,2,:)./vecnorm(Start(:,2,:),2,1).*obj.SpeedFunction(Start(1,1,:),Start(2,1,:),Start(3,1,:));
			Initial(obj.SubsIndex,:)=reshape(Start,6,[]);
			[TimePoints,LightPath]=ode23(@(t,Y)reshape(obj.OdeFunction(t,reshape(Y,6,[])),[],1),[0,TimeTo],Initial);
			LightPath=reshape(LightPath,height(LightPath),6,[]);
			LightPath=LightPath(:,obj.SubsIndex(1:3),:);
		end
	end
end