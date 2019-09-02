function [] = update_x(arg1,arg2)

%fprintf(strcat(arg1,"A.csv"))
A = csvread(strcat(arg1,"A.csv"));
x_old = csvread(strcat(arg1,"x.csv"));
y = csvread(strcat(arg1,"y.csv"));
mu = csvread(strcat(arg1,"mu.csv"));

%%% Init variables OPF
S_base = 100; %MVA
n = size(y,1);
c = zeros(n,1);

%% COST FUNCTION 
R = 0.00304;
c(7) = R; %Minimize power loss

rho=arg2;

n_childs = floor((n-7)/3);
B = zeros(3,n);
B(1,5)=2;
B(2,6)=2;
B(3,2)=-1;
B(3,7)=1;

B2 = zeros(3,n);
B2(1,8)=2;
B2(2,9)=2;
B2(3,2)=-1;
B2(3,7)=1;

D = zeros(n,1); 
E = zeros(n,1);

D(1,1) = 1;
E(7,1) = 1;

% Problem OPF: 
cvx_begin quiet
    variable x(n,1)
    minimize(square(c'*x) + mu'*x + .5*rho*(x-y)'*(x-y));
    x(1)<=1.1; %Vmax
    x(1)>=.9;  %Vmin  
    x(2)<=1.1; %Vmax
    x(2)>=.9;  %Vmin
    x(3)<= 20/S_base;
    norm(B*x,2) <= x(1) + x(7);
    norm(B2*x,2) <= x(1) + x(7);
cvx_end
csvwrite(strcat(arg1,"x.csv"),x)
residuo = norm(x-y,2);
dlmwrite('estado.dat',x','-append');
dlmwrite('residuo.dat',residuo,'-append');
dlmwrite('costo.dat',c'*x,'-append');
end
