function [sys,x0,str,ts] = LG_Sfun_Double_P2Q_Q1_FM_Dis(t,x,u,flag,...
    xQ10,yQ10,zQ10,a10,b10,a20,b20) 
%%
 switch flag
    case 0
    [sys,x0,str,ts]=mdlInitializeSizes(xQ10,yQ10,zQ10,a10,b10,a20,b20); 
    case 1
    sys=mdlDerivatives(t,x,u); 
    case 3
    sys=mdlOutputs(t,x,u); 
    case { 2, 4, 9 }
    sys = []; 
    otherwise 
    error(['Unhandled flag = ',num2str(flag)]); 
end 
function [sys,x0,str,ts]=mdlInitializeSizes(xQ10,yQ10,zQ10,a10,b10,a20,b20)
%% 
sizes = simsizes; 
sizes.NumContStates = 26; 
sizes.NumDiscStates = 0; 
sizes.NumOutputs = 26; 
sizes.NumInputs = 11; 
sizes.DirFeedthrough = 0; 
sizes.NumSampleTimes = 1; 
sys = simsizes(sizes);

% x0 = [xp0;0;yp0;0;zp0;0; ...
%     deg2rad(a10);deg2rad(0);deg2rad(b10);deg2rad(0);...
%     0.1526;0;0;0;deg2rad(0);0; ...
%     deg2rad(a20);deg2rad(0);deg2rad(b20);deg2rad(0);...
%     -0.1526;0;0;0;deg2rad(0);0;];  

x0 = [xQ10;0;yQ10;0;zQ10;0; ...
    0;0;0.1526;0;deg2rad(0);0; ...
    deg2rad(a10);deg2rad(0);deg2rad(b10);deg2rad(0); ...
    deg2rad(a20);deg2rad(0);deg2rad(b20);deg2rad(0); ...
    0;0;-0.1526;0;deg2rad(0);0;];

% x0 = [0;0;0;        xP0;yP0;zP0;     ...
%     deg2rad(0);0;  deg2rad(a10);deg2rad(b10);...
%     0;-0.0268;0;        deg2rad(0);deg2rad(0);deg2rad(0);...
%     deg2rad(0);0;  deg2rad(a20);deg2rad(b20);...
%     0;0.0268;0;        deg2rad(0);deg2rad(0);deg2rad(0)];  

% x0= [dx0,dy0,dz0;  x0;y0;z0;...
%      da1;db1;  a1;b1;  ...
%      dphi1;dtheta1;dpsi1;phi10;theta10;psi10;...
%      da2;db2;  a2;b2;  
%      dphi2;dtheta2;dpsi2;phi20;theta20;psi20]

%Air Force Parameters:
str = []; 
ts = [0 0]; 
function sys=mdlDerivatives(t,x,u) 
%% Model states and controllors:
xQ1 = x(1); dxQ1 = x(2);
yQ1 = x(3); dyQ1 = x(4);
zQ1 = x(5); dzQ1 = x(6);

phi1 = x(7); dphi1 = x(8);
theta1 = x(9); dtheta1 = x(10);
psi1 = x(11); dpsi1 = x(12);

alpha1 = x(13); dalpha1 = x(14);
beta1 = x(15); dbeta1 = x(16);

alpha2 = x(17); dalpha2 = x(18);
beta2 = x(19); dbeta2 = x(20);

phi2 = x(21); dphi2 = x(22);
theta2 = x(23); dtheta2 = x(24);
psi2 = x(25); dpsi2 = x(26);

Fz1=u(1);Mx1=u(2);My1=u(3);Mz1=u(4);
Fz2=u(5);Mx2=u(6);My2=u(7);Mz2=u(8);
Fxp = u(9);
Fyp = u(10);
Fzp = u(11);

% Parameters:
% Quadcopter Parameters:
mQ1 = 0.55;
mQ2 = 0.55;
g = 9.8;

Ix1=0.0023;
Iy1=0.0028;
Iz1=0.0046;
Ix2=0.0023;
Iy2=0.0028;
Iz2=0.0046;

% Payload parameters:
mP = 0.2;
Lr = 1 ;
%% Generalized Force
M = [mP+mQ1+mQ2,0,0,0,0,0,Lr.*(mP+mQ2).*cos(beta1).*sin(alpha1),Lr.*( ...
  mP+mQ2).*cos(alpha1).*sin(beta1),(-1).*Lr.*mQ2.*cos(beta2).*sin( ...
  alpha2),(-1).*Lr.*mQ2.*cos(alpha2).*sin(beta2),0,0,0;0,mP+mQ1+mQ2, ...
  0,0,0,0,(-1).*Lr.*(mP+mQ2).*cos(alpha1).*cos(beta1),Lr.*(mP+mQ2).* ...
  sin(alpha1).*sin(beta1),Lr.*mQ2.*cos(alpha2).*cos(beta2),(-1).* ...
  Lr.*mQ2.*sin(alpha2).*sin(beta2),0,0,0;0,0,mP+mQ1+mQ2,0,0,0,0,(-1) ...
  .*Lr.*(mP+mQ2).*cos(beta1),0,Lr.*mQ2.*cos(beta2),0,0,0;0,0,0,Ix1, ...
  0,(-1).*Ix1.*sin(theta1),0,0,0,0,0,0,0;0,0,0,0,Iy1.*cos(phi1).^2+ ...
  Iz1.*sin(phi1).^2,(Iy1+(-1).*Iz1).*cos(phi1).*cos(theta1).*sin( ...
  phi1),0,0,0,0,0,0,0;0,0,0,(-1).*Ix1.*sin(theta1),(Iy1+(-1).*Iz1).* ...
  cos(phi1).*cos(theta1).*sin(phi1),cos(theta1).^2.*(Iz1.*cos(phi1) ...
  .^2+Iy1.*sin(phi1).^2)+Ix1.*sin(theta1).^2,0,0,0,0,0,0,0;Lr.*(mP+ ...
  mQ2).*cos(beta1).*sin(alpha1),(-1).*Lr.*(mP+mQ2).*cos(alpha1).* ...
  cos(beta1),0,0,0,0,Lr.^2.*(mP+mQ2).*cos(beta1).^2,0,(-1).*Lr.^2.* ...
  mQ2.*cos(alpha1+(-1).*alpha2).*cos(beta1).*cos(beta2),(-1).* ...
  Lr.^2.*mQ2.*cos(beta1).*sin(alpha1+(-1).*alpha2).*sin(beta2),0,0, ...
  0;Lr.*(mP+mQ2).*cos(alpha1).*sin(beta1),Lr.*(mP+mQ2).*sin(alpha1) ...
  .*sin(beta1),(-1).*Lr.*(mP+mQ2).*cos(beta1),0,0,0,0,Lr.^2.*(mP+ ...
  mQ2),Lr.^2.*mQ2.*cos(beta2).*sin(alpha1+(-1).*alpha2).*sin(beta1), ...
  (-1).*Lr.^2.*mQ2.*(cos(beta1).*cos(beta2)+cos(alpha1+(-1).*alpha2) ...
  .*sin(beta1).*sin(beta2)),0,0,0;(-1).*Lr.*mQ2.*cos(beta2).*sin( ...
  alpha2),Lr.*mQ2.*cos(alpha2).*cos(beta2),0,0,0,0,(-1).*Lr.^2.* ...
  mQ2.*cos(alpha1+(-1).*alpha2).*cos(beta1).*cos(beta2),Lr.^2.*mQ2.* ...
  cos(beta2).*sin(alpha1+(-1).*alpha2).*sin(beta1),Lr.^2.*mQ2.*cos( ...
  beta2).^2,0,0,0,0;(-1).*Lr.*mQ2.*cos(alpha2).*sin(beta2),(-1).* ...
  Lr.*mQ2.*sin(alpha2).*sin(beta2),Lr.*mQ2.*cos(beta2),0,0,0,(-1).* ...
  Lr.^2.*mQ2.*cos(beta1).*sin(alpha1+(-1).*alpha2).*sin(beta2),(-1) ...
  .*Lr.^2.*mQ2.*(cos(beta1).*cos(beta2)+cos(alpha1+(-1).*alpha2).* ...
  sin(beta1).*sin(beta2)),0,Lr.^2.*mQ2,0,0,0;0,0,0,0,0,0,0,0,0,0, ...
  Ix2,0,(-1).*Ix2.*sin(theta2);0,0,0,0,0,0,0,0,0,0,0,Iy2.*cos(phi2) ...
  .^2+Iz2.*sin(phi2).^2,(Iy2+(-1).*Iz2).*cos(phi2).*cos(theta2).* ...
  sin(phi2);0,0,0,0,0,0,0,0,0,0,(-1).*Ix2.*sin(theta2),(Iy2+(-1).* ...
  Iz2).*cos(phi2).*cos(theta2).*sin(phi2),cos(theta2).^2.*(Iz2.*cos( ...
  phi2).^2+Iy2.*sin(phi2).^2)+Ix2.*sin(theta2).^2];

fdq1 = Fxp+(-1).*(dalpha1.^2+dbeta1.^2).*Lr.*(mP+mQ2).*cos(alpha1).*cos( ...
  beta1)+(dalpha2.^2+dbeta2.^2).*Lr.*mQ2.*cos(alpha2).*cos(beta2)+ ...
  2.*dalpha1.*dbeta1.*Lr.*(mP+mQ2).*sin(alpha1).*sin(beta1)+(-2).* ...
  dalpha2.*dbeta2.*Lr.*mQ2.*sin(alpha2).*sin(beta2)+Fz1.*sin(phi1).* ...
  sin(psi1)+Fz2.*sin(phi2).*sin(psi2)+Fz1.*cos(phi1).*cos(psi1).* ...
  sin(theta1)+Fz2.*cos(phi2).*cos(psi2).*sin(theta2);

fdq2 = Fyp+(-1).*(dalpha1.^2+dbeta1.^2).*Lr.*(mP+mQ2).*cos(beta1).*sin( ...
  alpha1)+(dalpha2.^2+dbeta2.^2).*Lr.*mQ2.*cos(beta2).*sin(alpha2)+( ...
  -2).*dalpha1.*dbeta1.*Lr.*(mP+mQ2).*cos(alpha1).*sin(beta1)+2.* ...
  dalpha2.*dbeta2.*Lr.*mQ2.*cos(alpha2).*sin(beta2)+(-1).*Fz1.*cos( ...
  psi1).*sin(phi1)+(-1).*Fz2.*cos(psi2).*sin(phi2)+Fz1.*cos(phi1).* ...
  sin(psi1).*sin(theta1)+Fz2.*cos(phi2).*sin(psi2).*sin(theta2);

fdq3 = Fzp+(-1).*g.*(mP+mQ1+mQ2)+Fz1.*cos(phi1).*cos(theta1)+Fz2.*cos( ...
  phi2).*cos(theta2)+(-1).*dbeta1.^2.*Lr.*(mP+mQ2).*sin(beta1)+ ...
  dbeta2.^2.*Lr.*mQ2.*sin(beta2);

fdq4 = Mx1+dpsi1.*dtheta1.*(Ix1+(Iy1+(-1).*Iz1).*cos(2.*phi1)).*cos( ...
  theta1)+(-1).*(Iy1+(-1).*Iz1).*cos(phi1).*(dtheta1.^2+(-1).* ...
  dpsi1.^2.*cos(theta1).^2).*sin(phi1);

fdq5 = cos(phi1).*(My1+2.*dphi1.*dtheta1.*(Iy1+(-1).*Iz1).*sin(phi1))+( ...
  1/4).*((-4).*Mz1.*sin(phi1)+2.*dpsi1.*(Iy1+(-1).*Iz1).*cos(2.* ...
  phi1).*cos(theta1).*((-2).*dphi1+dpsi1.*sin(theta1))+(-2).*dpsi1.* ...
  cos(theta1).*(2.*dphi1.*Ix1+dpsi1.*((-2).*Ix1+Iy1+Iz1).*sin( ...
  theta1)));

fdq6 = dphi1.*dpsi1.*((-1).*Iy1+Iz1).*cos(theta1).^2.*sin(2.*phi1)+(-1).* ...
  (Mx1+dtheta1.^2.*((-1).*Iy1+Iz1).*cos(phi1).*sin(phi1)).*sin( ...
  theta1)+cos(theta1).*(dphi1.*dtheta1.*Ix1+Mz1.*cos(phi1)+My1.*sin( ...
  phi1)+dpsi1.*dtheta1.*((-2).*Ix1+Iy1+Iz1).*sin(theta1)+(-1).* ...
  dtheta1.*(Iy1+(-1).*Iz1).*cos(2.*phi1).*(dphi1+dpsi1.*sin(theta1)) ...
  );

fdq7 = Lr.*cos(beta1).*(2.*dalpha1.*dbeta1.*Lr.*(mP+mQ2).*sin(beta1)+sin( ...
  alpha1).*(Fxp+Lr.*mQ2.*((dalpha2.^2+dbeta2.^2).*cos(alpha2).*cos( ...
  beta2)+(-2).*dalpha2.*dbeta2.*sin(alpha2).*sin(beta2))+Fz2.*sin( ...
  phi2).*sin(psi2)+Fz2.*cos(phi2).*cos(psi2).*sin(theta2))+(-1).* ...
  cos(alpha1).*(Fyp+(dalpha2.^2+dbeta2.^2).*Lr.*mQ2.*cos(beta2).* ...
  sin(alpha2)+2.*dalpha2.*dbeta2.*Lr.*mQ2.*cos(alpha2).*sin(beta2)+( ...
  -1).*Fz2.*cos(psi2).*sin(phi2)+Fz2.*cos(phi2).*sin(psi2).*sin( ...
  theta2)));

fdq8 = Lr.*((-1).*cos(beta1).*(Fzp+(-1).*g.*(mP+mQ2)+Fz2.*cos(phi2).*cos( ...
  theta2)+dalpha1.^2.*Lr.*(mP+mQ2).*sin(beta1)+dbeta2.^2.*Lr.*mQ2.* ...
  sin(beta2))+sin(beta1).*(sin(alpha1).*(Fyp+Lr.*mQ2.*((dalpha2.^2+ ...
  dbeta2.^2).*cos(beta2).*sin(alpha2)+2.*dalpha2.*dbeta2.*cos( ...
  alpha2).*sin(beta2))+(-1).*Fz2.*cos(psi2).*sin(phi2))+cos(alpha1) ...
  .*(Fxp+Lr.*mQ2.*((dalpha2.^2+dbeta2.^2).*cos(alpha2).*cos(beta2)+( ...
  -2).*dalpha2.*dbeta2.*sin(alpha2).*sin(beta2))+Fz2.*sin(phi2).* ...
  sin(psi2))+Fz2.*cos(phi2).*cos(alpha1+(-1).*psi2).*sin(theta2)));

fdq9 = (-1).*Lr.*cos(beta2).*((-1).*(dalpha1.^2+dbeta1.^2).*Lr.*mQ2.*cos( ...
  alpha1).*cos(beta1).*sin(alpha2)+2.*dalpha1.*dbeta1.*Lr.*mQ2.*sin( ...
  alpha1).*sin(alpha2).*sin(beta1)+(-2).*dalpha2.*dbeta2.*Lr.*mQ2.* ...
  sin(beta2)+Fz2.*sin(alpha2).*sin(phi2).*sin(psi2)+Fz2.*cos(phi2).* ...
  cos(psi2).*sin(alpha2).*sin(theta2)+cos(alpha2).*((dalpha1.^2+ ...
  dbeta1.^2).*Lr.*mQ2.*cos(beta1).*sin(alpha1)+2.*dalpha1.*dbeta1.* ...
  Lr.*mQ2.*cos(alpha1).*sin(beta1)+Fz2.*cos(psi2).*sin(phi2)+(-1).* ...
  Fz2.*cos(phi2).*sin(psi2).*sin(theta2)));

fdq10 =Lr.*((-1).*cos(beta2).*((-1).*Fz2.*cos(phi2).*cos(theta2)+mQ2.*(g+ ...
  dbeta1.^2.*Lr.*sin(beta1)+dalpha2.^2.*Lr.*sin(beta2)))+sin(beta2) ...
  .*((dalpha1.^2+dbeta1.^2).*Lr.*mQ2.*cos(beta1).*sin(alpha1).*sin( ...
  alpha2)+Lr.*mQ2.*cos(alpha1).*((dalpha1.^2+dbeta1.^2).*cos(alpha2) ...
  .*cos(beta1)+2.*dalpha1.*dbeta1.*sin(alpha2).*sin(beta1))+Fz2.* ...
  cos(psi2).*sin(alpha2).*sin(phi2)+(-1).*cos(alpha2).*(2.*dalpha1.* ...
  dbeta1.*Lr.*mQ2.*sin(alpha1).*sin(beta1)+Fz2.*sin(phi2).*sin(psi2) ...
  )+(-1).*Fz2.*cos(phi2).*cos(alpha2+(-1).*psi2).*sin(theta2)));

fdq11 = Mx2+dpsi2.*dtheta2.*(Ix2+(Iy2+(-1).*Iz2).*cos(2.*phi2)).*cos( ...
  theta2)+(-1).*(Iy2+(-1).*Iz2).*cos(phi2).*(dtheta2.^2+(-1).* ...
  dpsi2.^2.*cos(theta2).^2).*sin(phi2);

fdq12 = cos(phi2).*(My2+2.*dphi2.*dtheta2.*(Iy2+(-1).*Iz2).*sin(phi2))+( ...
  1/4).*((-4).*Mz2.*sin(phi2)+2.*dpsi2.*(Iy2+(-1).*Iz2).*cos(2.* ...
  phi2).*cos(theta2).*((-2).*dphi2+dpsi2.*sin(theta2))+(-2).*dpsi2.* ...
  cos(theta2).*(2.*dphi2.*Ix2+dpsi2.*((-2).*Ix2+Iy2+Iz2).*sin( ...
  theta2)));

fdq13 = dphi2.*dpsi2.*((-1).*Iy2+Iz2).*cos(theta2).^2.*sin(2.*phi2)+(-1).* ...
  (Mx2+dtheta2.^2.*((-1).*Iy2+Iz2).*cos(phi2).*sin(phi2)).*sin( ...
  theta2)+cos(theta2).*(dphi2.*dtheta2.*Ix2+Mz2.*cos(phi2)+My2.*sin( ...
  phi2)+dpsi2.*dtheta2.*((-2).*Ix2+Iy2+Iz2).*sin(theta2)+(-1).* ...
  dtheta2.*(Iy2+(-1).*Iz2).*cos(2.*phi2).*(dphi2+dpsi2.*sin(theta2)) ...
  );

fdq = [fdq1,fdq2,fdq3,fdq4,fdq5,fdq6,fdq7,fdq8,fdq9,fdq10,fdq11,fdq12,fdq13]';
dummy = M\fdq;

xQ1dot = dxQ1;
dxQ1dot = dummy(1);
yQ1dot = dyQ1;
dyQ1dot = dummy(2);
zQ1dot = dzQ1;
dzQ1dot = dummy(3);

phi1dot = dphi1;
dphi1dot = dummy(4);
theta1dot = dtheta1;
dtheta1dot = dummy(5);
psi1dot = dpsi1;
dpsi1dot = dummy(6);

alpha1dot = dalpha1;
dalpha1dot = dummy(7);
beta1dot = dbeta1;
dbeta1dot = dummy(8);

alpha2dot = dalpha2;
dalpha2dot = dummy(9);
beta2dot = dbeta2;
dbeta2dot = dummy(10);

phi2dot = dphi2;
dphi2dot = dummy(11);
theta2dot = dtheta2;
dtheta2dot = dummy(12);
psi2dot = dpsi2;
dpsi2dot = dummy(13);


sys = [xQ1dot;dxQ1dot;yQ1dot;dyQ1dot;zQ1dot;dzQ1dot;...
    phi1dot;dphi1dot;theta1dot;dtheta1dot;psi1dot;dpsi1dot;...
    alpha1dot;dalpha1dot;beta1dot;dbeta1dot;...
    alpha2dot;dalpha2dot;beta2dot;dbeta2dot;...
    phi2dot;dphi2dot;theta2dot;dtheta2dot;psi2dot;dpsi2dot;]; 
function sys=mdlOutputs(t,x,u)
%% Model states and controllors:
xQ1 = x(1); dxQ1 = x(2);
yQ1 = x(3); dyQ1 = x(4);
zQ1 = x(5); dzQ1 = x(6);

phi1 = x(7); dphi1 = x(8);
theta1 = x(9); dtheta1 = x(10);
psi1 = x(11); dpsi1 = x(12);

alpha1 = x(13); dalpha1 = x(14);
beta1 = x(15); dbeta1 = x(16);

alpha2 = x(17); dalpha2 = x(18);
beta2 = x(19); dbeta2 = x(20);

phi2 = x(21); dphi2 = x(22);
theta2 = x(23); dtheta2 = x(24);
psi2 = x(25); dpsi2 = x(26);

Fz1=u(1);Mx1=u(2);My1=u(3);Mz1=u(4);
Fz2=u(5);Mx2=u(6);My2=u(7);Mz2=u(8);
Fxp = u(9);
Fyp = u(10);
Fzp = u(11);
%% TransForm Matrix
sys = [xQ1;dxQ1;yQ1;dyQ1;zQ1;dzQ1;...
    phi1;dphi1;theta1;dtheta1;psi1;dpsi1;...
    alpha1;dalpha1;beta1;dbeta1;...
    alpha2;dalpha2;beta2;dbeta2;...
    phi2;dphi2;theta2;dtheta2;psi2;dpsi2;]; 

function sys=mdlGetTimeOfNextVarHit(t,x,u)
sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

function sys=mdlTerminate(t,x,u)
sys = [];