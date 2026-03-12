clc
clear all

% path = "C:\Users\Manuel Hernandez\Documents\GitHub\ChannelEmulation\Multirate\simulation\";
path = "C:\MasterSoC4p_DE2115-main\driver\";

V_INTERP = 2;
QM = 3;
QN = 13;
DATAPATH = QM+QN;

fs = 2000;
fs_int = 2000*V_INTERP;
fmax = 100;
N = 128;
t_fin = N/fs;
kappa = 10;
alpha = pi/3;

T = 0:1/fs:t_fin-1/fs;
T_int = 0:1/fs_int:t_fin-1/fs_int;


vonMisses = funcKLVonMisses(t_fin,fmax,fs,kappa,alpha,T);
data2intpol = real(vonMisses.spect);
% data2intpol = sin(2*pi*55*T)';



% dataintpol_sw = sin(2*pi*55*T_int);

% figure(1)
% plot(T, data2intpol)


interpolado_real = zeros(V_INTERP*N,1);
interpolado_PF = zeros(V_INTERP*N,1);
data_dec = floor(data2intpol.*2^QN);
data_hex = dec2hex(data_dec, DATAPATH/4);

%% Inicio del proceso
t_interp  = 0:1/V_INTERP:1-1/V_INTERP;
index = 1;
for ii = 3:N

    p0 = data2intpol(ii-2);                       
    b0 = (data2intpol(ii) + data2intpol(ii-2) ) /2;       
    p1 = (2*data2intpol(ii-1) - data2intpol(ii-2)) - b0;      
    p2 = b0 - data2intpol(ii-1);                  

    for jj = 1:V_INTERP
        interpolado_real(index) = (p0 + p1*t_interp(jj) + p2*(t_interp(jj)^2));
        index = index + 1;
    end
    
end

for ii=index:N*V_INTERP
    if(ii <= (N-1)*V_INTERP)
       interpolado_real(ii) = data2intpol(end-1);
    else 
       interpolado_real(ii) = data2intpol(end); 
    end
end

% figure(2)
% plot(T_int, interpolado_real)
% hold on
% plot(T_int, dataintpol_sw)
% title("Interpolado vs Sobremuestreo")
% legend('Técnica', 'Sobremuestreado');
% hold off

fid = fopen(path+'input_data.txt', 'w+');

for jj = 1:N
    fprintf(fid, '%s\n', data_hex(jj, :));
end

fclose(fid);

fid = fopen(path+'expected_results.txt', 'w+');

for jj = 1:V_INTERP*N
    interpolado_PF(jj) = floor(interpolado_real(jj)*2^QN);
    interpolado_HX(jj,:) = dec2hex(interpolado_PF(jj,1), DATAPATH/4);
    fprintf(fid, '%s\n', interpolado_HX(jj, :));
end

fclose(fid);

test = [0, 709, 1408, 2101, 2774, 3431, 4058, 4658, 5221, 5748, 6229, 6666, 7051, 7385, 7663, 7884, 8046, 8148, 8190, 8170, 8091, 7949, 7750, 7490, 7178, 6809, 6393, 5925, 5417, 4864, 4280, 3658, 3015, 2344, 1661, 960, 257, 65082, 64381, 63683, 63004, 62338, 61702, 61090, 60515, 59972, 59476, 59021, 58619, 58264, 57967, 57724, 57541, 57416, 57353, 57350, 57408, 57528, 57706, 57943, 58236, 58585, 58984, 59435, 59928, 60466, 61038, 61647, 62282, 62945, 63623, 64320, 65021, 194, 898, 1600, 2285, 2957, 3603, 4227, 4815, 5370, 5882, 6353, 6775, 7148, 7466, 7729, 7934, 8080, 8166, 8190, 8155, 8057, 7901, 7684, 7412, 7082, 6702, 6268, 5792, 5268, 4710, 4111, 3487, 2832, 2161, 1468, 770, 61, 64893, 64187, 63498, 62818, 62164, 61530, 60931, 60361, 59835, 59346, 58908, 58516, 58179, 57894, 57669, 57500, 57393, 57346, 57360, 57435, 57570, 57765, 58017, 58327, 58689, 59104, 59564, 60072, 60617, 61202, 61816, 62462, 63127, 63814, 64509, 65216, 385, 1092, 1787, 2472, 3134, 3777, 4389, 4971, 5513, 6016, 6472, 6882, 7239, 7544, 7791, 7980, 8110, 8178, 8187, 8133, 8021, 7846, 7616, 7326, 6984, 6586, 6144, 5651, 5121, 4548, 3946, 3309, 2653, 1971, 1281, 575, 65407, 64697, 64000, 63309, 62640, 61986, 61365, 60770, 60215, 59695, 59223, 58795, 58420, 58095, 57828, 57616, 57465, 57374, 57344, 57374, 57465, 57617, 57828, 58097, 58420, 58797, 59223, 59699, 60215, 60774, 61365, 61991, 62640, 63314, 64000, 64703, 65407, 580, 1281, 1976, 2653, 3314, 3946, 4552, 5121, 5655, 6144, 6590, 6984, 7328, 7616, 7848, 8021, 8134, 8187, 8178, 8110, 7979, 7791, 7541, 7239, 6879, 6472, 6013, 5513, 4967, 4389, 3773, 3134, 2467, 1787, 1787, 385, 385]';

for ii = 1:V_INTERP*N
    if(test(ii) > 2^(DATAPATH-1))
        test(ii) = (test(ii)*2^(-QN) - 2^QM).*2^(QN);
    end
end
error = abs(interpolado_PF - test);

figure
plot(interpolado_PF)
hold on
plot(test)
plot(error);
legend('sw', 'hw', 'error')
title("Interpolado");
