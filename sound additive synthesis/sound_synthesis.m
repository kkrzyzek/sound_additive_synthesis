%sound additive synthesis

close all
clear all
clc

[s1,Fs]=audioread('smyczek.wav');

T=1/Fs;                     %okres
L=length(s1);               %dlugosc sygna³u
t=(0:L-1)*T;                %wektor sygna³u (sygnal*okres)
                             
nt=floor(0.02*Fs);          %dlugosc ramki(t)
N=floor(length(s1)/nt);     %ilosc ramek

suma=0;

%RMS sygnalu
for i=1:N  
y(i)=s1(i)*s1(i); 
suma=suma+y(i);
end

suma=suma/N;
RMS=sqrt(suma);

odch_org=std(s1);

fftr=abs(fft(s1)); %fft sygnalu
fftr=fftr(1:length(s1)/2);
fftr=fftr./max(fftr);

f=(0:floor((L-2)/2))*1/(L*T); %wektor czestotliwosci

figure(1)
subplot(2,1,1)
plot(t,s1)
title('Przebieg czasowy sygnalu zrodlowego');
xlabel('t[s]');
ylabel('amp');

subplot(2,1,2)
plot(f,fftr)
title('Widmo amplitudowe sygnalu zrodlowego');
xlabel('f[Hz]');
ylabel('amp');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%synteza addytywna z widma logarytmicznego%


fftr=20*log10(fftr);
[a,b]=findpeaks(fftr,'THRESHOLD',1,'MINPEAKDISTANCE',400);

%figure(2)
%plot(b,a,'+')

t=(0:L-1)*T;

for i=1:L
    y(L)=0;
end

a=10.^(a./20); %skala logarytmiczna na wartosci odpowiadajace cisnieniu akustycznemu
b=b*1/(L*T);

%synteza
for i=1:length(a)
y=y+a(i).*sin((2*pi*b(i)).*t);
end

%obwiednia
for i=1:length(s1)  
y(i)=y(i)*abs(s1(i));
end

%unormowane RMS
sumay=0;

for i=1:N   
z(i)=y(i)*y(i);   
sumay=sumay+z(i);
end

sumay=sumay/N;
RMSy=sqrt(sumay);
k=RMS/RMSy;
y=k*y;

sound(y,Fs);
audiowrite('smyczek_synteza.wav',y,Fs);

figure(3)
subplot(2,1,1)
plot(y)
title('Przebieg czasowy - synteza');
xlabel('t[s]');
ylabel('amp');

% fft - synteza
ffty=abs(fft(y));
ffty=ffty(1:length(y)/2);
ffty=ffty./max(ffty);
fy=(0:floor((L-2)/2))*1/(L*T);

odch_synteza=std(y);
b2=abs(((odch_org-odch_synteza)/odch_org)*100);

figure(3)
subplot(2,1,2)
plot(fy, ffty)
title('Widmo amplitudowe sygnalu zsyntetyzowanego');
xlabel('f[Hz]');
ylabel('amp');

%saveas(1, 'sygnal_org', 'bmp');
%saveas(3, 'synteza', 'bmp');