function [ resul, minRes, minDif ] = link( start, target, canais, numMin,...
    ref, col, minRes, minDif, estPe)
%LINK Summary of this function goes here
%   Detailed explanation goes here

%% Função para fazer a linkagem  entre duas soluções

% função que irá realiar a linkagem entre duas soluções. As diretrizes para
% essas linkagem são as seguintes:

% 1- Para realizar a linkagem entre as 2 soluções, pensa-se em uma maneira
% de discretizar as caracteristicas de cada uma das 2 soluções, tanto a
% solução alvo, como a solução start. . Essa discretização ocorrerá em
% nível de altura, assim  como no nível de largura. 

% 2- No sentido de linkar a altura do retângulo em cada um das duas
% soluções, pode-se verificar qual solução tem mais altura relativamente 
% uma a outra, calculando a diferença de altura entre elas. Essa diferença 
% de altura entre as soluções será discretizada, segundo um determinado 
% passo
% que irá dividir essa distância em diferentes pequenos segmentos. A
% solução de pior métrica pode ter sua altura diminuida (no caso da pior 
% solução for a solução de maior altura), desde que a altura de pior 
% métrica não ultrapasse o valor mínimo da solução variada, 
% ou pode ter sua altura aumentada desde que não ultrapasse o máximo da 
% solução variada. A altura do retângulo precisa ter seu parâmetro de
% posição da altura modificado caso ultrapasse a metade. 
% (no caso da pior solução ser a solução mais baixa). O mesmo vale para a 
% largura, verificam-se os canais presentes em cada uma das soluções, e 
% caso a melhor solução tenha mais canais presentes, pode-se inserir os 
% canais faltantes da melhor solução na pior solução. Caso contrário, 
% pode-se extrair os canais excedentes da pior solução e verificar o 
% comportamento da solução. 

% Calcula-se a métrica das soluções start e target. Se a métrica da solução
% start for melhor que a da solução target, inverte-se a atribuição de cada
% solução. 

% Para o caso da linkagem na largura dos canais: O inicio da solução start
% pode acontecer antes do inicio da solução target e o fim da solução start
% pode acontecer antes do fim da solução target. Isso acontecendo, a
% linkagem entre a solução target  e start vai se dar a partir do inicio
% das duas solução: O inicio da  solução start caminhará em direção ao
% inicio da solução target, e a cada passo serão calculados os valores
% pertinentee. Assim que os dois inicio conincidirem, os fins caminharão um
% em direção ao outro. A cada passo, serão calculados os valores. Isso
% também acontecerá se o inicio da target acontecer antes do inicio da
% start, e o fim da target acontecer antes do fim da start. A solução
% target pode estar contida dentro da solução start. Nessa situação, o
% início da targer será diminuída até o início da solução start, e a cada
% passo dado os valores pertinentes serão calculados. Depois de ocorrer a
% coincidência entre os inícios, o fim da target caminhará em direção ao
% fim da start. 

% A função irá definir uma matriz contendo todos os valores de canais
% presentes na solução start e target. Depois da definição dessas matrizes,
% serão verificados o canais que estão presentes em start e ausentes em
% target. O contrário também é feito, ou seja, os canais presentes em
% target e ausentes em start. 

% são construidas duas estruturas de dados auxiliares. A primeira delas,
% 'exisStarTarg', são os valores de canais que estão presentes em start e
% não presentes em target. Se existirem valores nulos nessa estrutura,
% esses canais devem ser excluidos da soluição start. A contagem de
% diferenças entre as duas soluções levará em conta a quantidade de valores
% nulos entre existStartTare exisTarStar. Ao se extrair um canal de start,
% a diferença entre as duas soluções diminui de 1.

% Ao ser pesquisado exisTargStar, o número de elementos nulos nessa
% estrutura indicarão os canais a serem inseridos em start. Ao ser inserido
% um canal em start, as diferenças entre as duas soluções diminui de 1. Ao
% ser inserido um canal que não esteja contiguo a um determinado intervalo,
% ao se formar a soma de compostos por 'somCanais', os parâmetros de
% entrada para 'somCanais' tomará como parâmetro uma matriz que contém numa
% linha o intervalo de canais a serem somados. Caso o canal não seja
% contiguo, define-se uma nova linha contendo os intervalos que não são
% contiguos. Passa-se ainda para 'somCanais' a estrutura de contagens
% espectrais, a quantidade de canais para cada um do intervalos, e os
% percentuais para desnormalizar os dados. Ou seja, vamos supor que a
% partição escolhida tenha um intervalo de [34 54] e se deseje inserir um
% canal que não seja contiguo a esse intervalo definido, 13, por exemplo.
% Logo, a matriz passada para a função de soma dos compostos receberá como
% parâmetro a matriz [34 54; 13 13]. 

a = 1;
%% Definições iniciais
% Nesse ponto do algoritmo, ele verificará as soluções 'start' e 'target'.
% Verificará qual partição que está variando os seus parâmetros no primeiro
% laço que se inicia com o for tendo a variável de controle 'i'.
% Calculam-se as duas métricas das duas soluções em questão para se
% verificar qual delas tem o menor valor de métrica. Essas duas soluções
% são trocadas caso a solução 'start' tenha uma métrica menor que a solução
% 'target'. Verificam-se quais canais estão presentes na solução 'start' e
% ausentes na solução 'target', e quais estão presentes na solução 'target'
% e ausentes na solução 'start'. A primeira quantidade de diferenças é
% importante para se verificar que canais se extrair da solução start,
% enquanto que a segunda quantidade de diferenças é importante para se
% verificar que canais se inserir na solução start. Caculam-se as
% quantidades de diferenças totais das duas soluções, somando-se as
% quantidades de diferenças. 

resul = start;
tamCanais = size(canais);
for i = 1 : tamCanais(1,1)
    if isequal(canais(i,:),  start{1,1}{1,1}.partEsc)
        partEsc = i;
    end
end
metStar = metrica(start);
metTarg = metrica(target);
if metStar < metTarg
    targTemp = target;
    target = start;
    start = targTemp;
    metTemp = metTarg;
    metTarg = metStar;
    metStar = metTemp;
end
metRef = metStar;
parStar = start{1,1}{1,1}.starWide;
finStar = start{1,1}{1,1}.endWide;
matStart = searCha(parStar,finStar,start{1,1}{1,1}.compostos);
parTar = target{1,1}{1,1}.starWide;
finTar = target{1,1}{1,1}.endWide;
matTarget = searCha(parTar,finTar,target{1,1}{1,1}.compostos);
exisStarTarg = dif(matStart, matTarget);
exisTarStar = dif(matTarget,matStart);
value1 = sum(exisStarTarg(:)==0); 
value2 = sum(exisTarStar(:)==0);
value = value1+value2;
[start{1,1}{1,1}(:).ch] = (matStart)';   % inserção de canais em 'start'
[target{1,1}{1,1}(:).ch] = (matTarget)'; % inserção de canais em 'target'
parou = false;
tamMatStart = size(matStart);
[start{1,1}{1,1}(:).free] = tamMatStart(1,2) - numMin; % numero de liberda. 

%% Inicio de verificação das diferenças. 
while value > 0 && parou == false
    
    %%% Verificação de dados iniciais. Canais na solução 'start', canais na
    %%% solução target, calculo das metricas de cada um e recalculo após a
    %%% adoção de uma nova solução 'start'. Impressão das matrizes de
    %%% canais 'start' e 'target'. Troca das suas soluções, a 'start'
    %%% converte-se em 'target' e vice-versa, caso a 'start' apresente uma
    %%% métrica melhor que a 'target'. Mais uma vez, verificação dos canais
    %%% presentes em 'start' e ausentes em 'target', e presentes em
    %%% 'target' e ausentes em 'start'. somam-se as diferenças totais, e
    %%% cria-se uma lista para inserir soluções que sejam melhores que a
    %%% solução 'start'. 
    
    impressi = fopen('aaimpreVir','a');
    parStar = start{1,1}{1,1}.starWide;
    finStar = start{1,1}{1,1}.endWide;
                                        % início e fim da solução start
    parTar = target{1,1}{1,1}.starWide;
    finTar = target{1,1}{1,1}.endWide;
                                        % início e fim da solução target.
    matTarget = searCha(parTar,finTar,target{1,1}{1,1}.compostos);
    matStart = searCha(parStar,finStar,start{1,1}{1,1}.compostos);
                                        % canais inseridos em cada uma das
                                        % soluções. 
    impressaoVir(impressi,[matStart 0 matTarget 0 metStar metTarg]);
    fclose(impressi);
    metRef = metStar;
    metStar = metrica(start);
    metTarg = metrica(target);
                                        % métricas associadas a cada uma
                                        % das soluções. 
    if metStar < metTarg
        targTemp = target;
        target = start;
        start = targTemp;
        metTemp = metTarg;
        metTarg = metStar;
        metStar = metTemp;
    end
                                        % troca das métricas. 
    matStar = (start{1,1}{1,1}.ch);
    exisStarTarg = dif(matStar', matTarget);
                                        % Canais na solução start e
                                        % ausentes em target. 
    exisTarStar = dif(matTarget,matStar);
                                        % Canais na solução target e
                                        % ausentes na solução start. 
    tamStar  = size(exisStarTarg);
    tamTarg = size(exisTarStar);
    value1 = sum(exisStarTarg(:)==0); 
    value2 = sum(exisTarStar(:)==0);
                                        % verifica-se as quantidades de
                                        % diferenças pela presenaça de
                                        % zeros na solução e soma-se. 
    value = value1+value2;
    lista = cell(value,1);
    positi = 1;
    liber = tamStar(1,1) - numMin;
    for i = 1 : tamStar(1,1)
        %%% A partir desse ponto verificam-se todas as diferenças, uma a
        %%% uma. Primeiro verifica-se a matriz que indica os canais
        %%% presentes em 'start' e ausentes em 'target', e esses canais, um
        %%% por vez são extraídos, e verificada a qualidade da da nova
        %%% solução 'start' com esse canal extraido. Se o canal extraído
        %%% estiver na primeira posição da solução 'start', verificam
        copStar1 = start;
        copTot1 = start{1,1}{1,1}.total;
        copComp1 = start{1,1}{1,1}.compostos;
        if exisStarTarg(i,1) == 0 && tamStar(1,1) >= numMin
            [mat1,mat2] = defInter(matStar,i,0);
            if ~isempty(mat1) && ~isempty(mat2)
                resul1 = fus([mat1;mat2],matStar, copTot1, copComp1, ...
                    canais, partEsc,0, start{1,1}{1,1}.perce, ref, col,...
                    estPe);
                
                strSta = num2str(i);
                conca = strcat('retirado_canal_linkagem_link_', strSta, '\n');
                fprintf(conca); 
                                    % impressão na tela após ter verificada
                                    % uma diferença. 
                copStar1{1,1}{1,1} = resul1.part;
                param1 = copStar1{1,1};
                [partTemp, somAproxTemp, matPercTemp] = ...
                    data(param1, start{1,1}{1,1}.perce, col);
                            % cálculo de cada um dos parâmetros das
                            % partições
                
                [apxPart, toPart, pontNeg, condMatApx, resApxMMQ, resApxZ, ...
                    resApxArtIcc, resApxArtIsc,  somPartZ, somPartArtIcc, ...
                    somPartArtIsc] = impress(matPercTemp, somAproxTemp, ...
                    partTemp, '');
                            % determinação de variáveis para preparação da
                            % escrita dos arquivos que associarão métricas
                            % e percentuais. 
                valApx= [resApxMMQ resApxZ resApxArtIcc resApxArtIsc];
                valDif = [(apxPart - toPart)  somPartZ somPartArtIcc ... 
                    somPartArtIsc];
                            % preparação para a escrita dos arquivos. 
                [minRes, minDif] = divMetGrasp(matPercTemp, valApx, valDif, ...
                condMatApx, minRes, minDif); 
                            % escrita dos arquivos que associarão métricas
                            % e percentuais
                dat1 = {partTemp; matPercTemp(:,1);somAproxTemp;...
                    matPercTemp};
                            % preparação da variável para dar continuidade
                            % à execução do algoritmo. 
                [dat1{1,1}{1,1}(:).ch] = (resul1.ch);
                tamSol1 = size(dat1{1,1}{1,1}.ch);
                [dat1{1,1}{1,1}(:).free] = tamSol1(1,1) - numMin;
                metDat3 = metrica(dat1);
                if metDat3 < metStar && positi <= value1
                    lista{positi,1} = dat1;
                    positi = positi + 1;
                    if metDat3 < metRef
                        resul = dat1;
                        metRef = metDat3;
                    end
                end
            else
                if ~isempty(mat1)
                    ch = mat1;
                    partTemp = defPart(ch(1,1), ch(end,1),... 
                        start{1,1}{1,1}.total, start{1,1}{1,1}.compostos,...
                        canais, partEsc, start{1,1}{1,1}.perce,ref, col, ...
                        estPe);
                    copStar1{1,1}{1,1} = partTemp;
                    param = copStar1{1,1};
                    [partTemp, somAproxTemp, matPercTemp] = ...
                        data(param, start{1,1}{1,1}.perce, col);
                    dat2 = {partTemp; matPercTemp(:,1);somAproxTemp; ...
                        matPercTemp};
                            %informações das partições 
                    [apxPart, toPart, pontNeg, condMatApx, resApxMMQ, ...
                        resApxZ, resApxArtIcc, resApxArtIsc,  somPartZ, ...
                        somPartArtIcc, somPartArtIsc] = ...
                        impress(matPercTemp, somAproxTemp, partTemp, '');
                            % variáveis para preparção dos arquivos a sere,
                            % serem escritos. Essa linha não escreve nada. 
                            
                    valApx= [resApxMMQ resApxZ resApxArtIcc resApxArtIsc];
                    valDif = [(apxPart - toPart)  somPartZ somPartArtIcc ... 
                        somPartArtIsc];
                            % preparação para a escrita dos arquivos. 
                    [minRes, minDif] = divMetGrasp(matPercTemp, valApx, ...
                        valDif, condMatApx, minRes, minDif);         
                            % escrita dos arquivos. 
                    [dat2{1,1}{1,1}(:).ch] = ch;
                    tamSol2 = size(dat2{1,1}{1,1}.ch);
                    [dat2{1,1}{1,1}(:).free] = tamSol2(1,1) - numMin;
                    metDat1 = metrica(dat2);
                    if metDat1 < metStar && positi <= value1
                        lista{positi,1} = dat2;
                        positi = positi + 1;
                        if metDat1 < metRef
                            resul = dat2;
                            metRef = metDat1;
                        end
                    end
                else
                    ch = mat2;
                    partTemp = defPart(ch(1,1), ch(end,1),...
                        start{1,1}{1,1}.total, start{1,1}{1,1}.compostos,...
                        canais, partEsc, start{1,1}{1,1}.perce, ref, col,...
                        estPe);
                    copStar1{1,1}{1,1} = partTemp;
                    param = copStar1{1,1};
                    [partTemp, somAproxTemp, matPercTemp] = ...
                        data(param, start{1,1}{1,1}.perce, col);
                    dat3 = {partTemp; matPercTemp(:,1);somAproxTemp; ...
                        matPercTemp};
                            %informações das partições 
                    [apxPart, toPart, pontNeg, condMatApx, resApxMMQ, ...
                        resApxZ, resApxArtIcc, resApxArtIsc,  somPartZ, ...
                        somPartArtIcc, somPartArtIsc] = ...
                        impress(matPercTemp, somAproxTemp, partTemp, '');
                            % variáveis para preparção dos arquivos a sere,
                            % serem escritos. 
                    valApx= [resApxMMQ resApxZ resApxArtIcc resApxArtIsc];
                    valDif = [(apxPart - toPart)  somPartZ somPartArtIcc ... 
                        somPartArtIsc];
                            % preparação para a escrita dos arquivos. 
                    [minRes, minDif] = divMetGrasp(matPercTemp, valApx, ...
                        valDif, condMatApx, minRes, minDif);         
                            % escrita dos arquivos. 
                    [dat3{1,1}{1,1}(:).ch] = ch;
                    tamSol3 = size(dat3{1,1}{1,1}.ch);
                    [dat3{1,1}{1,1}.free] = tamSol3(1,1) - numMin;
                    metDat2 = metrica(dat3);
                    if metDat2 < metStar && positi <= value1
                        lista{positi,1} = dat3;
                        positi = positi + 1;
                        if metDat2 < metRef
                            resul = dat3;
                            metRef = metDat2;
                        end
                    end   
                end
            end
        end
    end
    for k = 1 : tamTarg(1,1)
       copStar2 = start;
       copTot2 = start{1,1}{1,1}.total;
       copComp2 = start{1,1}{1,1}.compostos; 
       if exisTarStar(k,1) == 0
           l = start{1,1}{1,1}.ch;
           p = matTarget(1,k);
           [matIns, pos] = insert(p,l);
           [mat1,mat2] = defInter(matIns,pos,1);
           if ~isempty(mat1) && ~isempty(mat2)
                resul2 = fus([mat1;mat2], matStar, copTot2, copComp2, ...
                    canais, partEsc, 1, start{1,1}{1,1}.perce, ref, col, ...
                    estPe);
                
                strSta = num2str(i);
                conca = strcat('inserido_canal_linkagem_link_', strSta, '\n');
                fprintf(conca);
                                    % impressão na tela após ter verificada
                                    % uma diferença.
                
                copStar2{1,1}{1,1} = resul2.part;
                param2 = copStar2{1,1};
                [partTemp, somAproxTemp, matPercTemp] = ...
                    data(param2,start{1,1}{1,1}.perce, col);
                dat4 = {partTemp; matPercTemp(:,1);somAproxTemp; ...
                    matPercTemp};
                [apxPart, toPart, pontNeg, condMatApx, resApxMMQ, ...
                        resApxZ, resApxArtIcc, resApxArtIsc,  somPartZ, ...
                        somPartArtIcc, somPartArtIsc] = ...
                        impress(matPercTemp, somAproxTemp, partTemp, '');
                            % variáveis para preparção dos arquivos a sere,
                            % serem escritos. Essa linha não escreve nada.
                valApx= [resApxMMQ resApxZ resApxArtIcc resApxArtIsc];
                valDif = [(apxPart - toPart)  somPartZ somPartArtIcc ... 
                        somPartArtIsc];
                            % preparação para a escrita dos arquivos. 
                [minRes, minDif] = divMetGrasp(matPercTemp, valApx, ...
                        valDif, condMatApx, minRes, minDif);         
                            % escrita dos arquivos
                [dat4{1,1}{1,1}(:).ch] = (resul2.ch);
                tamSol4 = size(dat4{1,1}{1,1}.ch);
                [dat4{1,1}{1,1}(:).free] = tamSol4(1,1) - numMin;
                metDat4 = metrica(dat4);
                if metDat4 < metStar && positi <= value
                    lista{positi,1} = dat4;
                    positi = positi + 1;
                    if metDat4 < metRef
                        resul = dat4;
                        metRef = metDat4;
                    end
                end
            end
       end
    end
    if positi > 1
        valor = randi([1 positi-1],1,1);
        start = lista{valor,1};
    else
        parou = true;
    end
    value = value - 1;
    strSta = num2str(value);
    conca = strcat('Retirada_uma_diferenca_', strSta, '\n');
    fprintf(conca);
end
end

