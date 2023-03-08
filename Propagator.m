function [p] = Propagator(lambda,pixel,M,N,z)

p = zeros(M,N);
k=2*pi/lambda;
screenx=pixel*M;
screeny=pixel*N;
fx=linspace(-M/2/screenx,(M/2-1)/screenx,M);
fy=linspace(-N/2/screeny,(N/2-1)/screeny,N);
[Fx,Fy]=meshgrid(fx,fy);

term=1-(lambda.*Fx).^2-(lambda.*Fy).^2;

if term>=0
    p=exp(-1i*k*z.*sqrt(term));
end
