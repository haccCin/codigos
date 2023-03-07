function  mainRaInt(col)

%MAIN Summary of this function goes here
%   Detailed explanation goes here

%% Chamada principal para os dados 

% Função principal para a chamada dos dados. 'x', 'y', 'z', 'w' e 'k' são,
% respectivamente, os valores de resíduo para cada uma das partições do
% conjunto total de canais, o resíduo trazido por meio do método dos
% mínimos quadrados do Matlab, a soma de cada um dos compostos para cada 
% uma das partições, a soma das contagens espectrais para cada uma das
% partições e 'k' contém dados para cada uma das partições, como o resíduo
% da partição, o resíduo trazido pela chamada ao método do Matlab em cada
% uma das partições, 

cd otimi;
load dados.mat;
estPe = cell(4,1);
estPe{1,1} = [0.15 0.25];
estPe{2,1} = [0.45 0.55];
estPe{3,1} = [0.15 0.25];
estPe{4,1} = [0.05 0.15];
for j = 1 : 1 : 4
    for i = 1:1:30
        str = int2str(i);
        str2 = strcat('../fol_',str);
        copyfile('../otimi/',str2);
        cd ..
        str3 = strcat('fol_',str);
        cd(str3);
        cd ..;
        cd 'residuos';
        [resid, residMat, somComp, somTot, newTot, canais, esc, retor] = ...
            main(col);
        cd ..;
        cd(str3);
        cd 'GRASP';
        x = GRASP( newTot, canais, esc, retor, dat{1,1},10 ,10 ,col, ...
            estPe{j,1});
        save x;
        cd ..
        cd ..
        cd otimi
    end
end
end
