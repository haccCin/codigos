function [ feed ] = estAlt(starWide, endWide, comp, total, perce, ...
    partRef, percen)
%ESTALT Summary of this function goes here
%   Detailed explanation goes here


%% Função para estimar a altura do retângulo

% 1 - Calcula-se onde irá residir um ponto da projeção da contagem espectr
% al total na linha de dois compostos conhecidos pela seguinte expressão:

%     projeção total = alpha * c1 + beta * c2 + gamma * c3

% onde os valores para c1 são as coordenadas de um vetor para o composto 1
% nas diferentes partições, ou seja (implementado)

%    c1 = {c_11,c_12,c_13,c_14}, c_{ij} = valor composto i, partição j
% A projeção total será determinada pelo método dos mínimos quadrados. 

% para descobrir o valor dessa projeção do total na linha que dois
% compostos cujos percentuais são conhecidos, faz-se

%     P_12 = alpha * c1 + beta * c2
%     P_13 = alpha * c1 + gamma * c3
%     P_23 = beta * c2 + gamma * c3
%
% onde P_{ij} são os valores da projeção do total nas linhas contendo os
% compostos i e j.

% 2 - Determina-se qual a coordenada baricêntrica é negativa e para  
% que respectivo vetor de compostos isso está ocorrendo. 

% 3 - Calcula-se o vetor determinado pelo ponto da projeção do MMQ e pelo
% vetor cuja coordenada baricêntrica é negativa. 

% 4 -Ao longo da linha em que estão determinados os pontos a projeção do 
% MMQ e o vetor de coordenada baricêntrica negativa, serão feitas várias
% determinações de pontos, seguindo para isso um valor de passo ao longo da
% linha. Para cada novo passo, será deteminada a coordenada baricêntrica
% desse novo ponto. Se ela der negativa em algum momento, é porque a
% perspectiva de ponto é negativa. A saída desse trecho de código serão
% duas estruturas de dados, uma contendo os pontos que estão inseridos
% dentro do triângulo de vetores de compostos, e a outra estrutura de dados
% conterá os valores das projeções determinadas pelos MMQ para os
% respectivos pontos da estrutura descrita para os pontos.

% 5 - Passo 5 será determinar a projeção dos pontos do desconhecido a
% partir dos pontos determinados no ponto 4. Essa projeção será feita
% tomando por base que por hipotese esse desconhecido tem uma participação
% dada pelo valor em percen.

% 6 - Os valores que virão do passo anterior serão as contagens espectrais
% totais para os compostos nas diferentes partições. Essas contagens
% espectrais totais precisam ser dividadas pelo tamanha da partição. É o
% que  será feito nesse passo. Além disso, o resultado dessa divisão será
% normalizado pelo maior valor. 

% 7 - O passo 6 irá extrair os valores de máximo e mínimo da celula de
% dados que surgirá a partir do resultado do passo 5. 


%% passo um

% projeção do total no plano definido pelos três compostos conhecidos.

partRef = [starWide endWide ; partRef]; % une as partições de referência 
                                        % com a partição definida no
                                        % momento. 
tamRef = size(partRef);
for l = 1 : tamRef(1,1)
    r = (partRef(l,2) - partRef(l,1));
    matSoma(l,:) =  somCanais(partRef(l,:), comp, r, perce );
    matSomaTot(l,1) = somCanais(partRef(l,:), total, r, [1]);
end
  %realiza a soma das contagens espectrais dos compostos e contagens 
  % espectrais totais nas partiçoes de referência. 
  
  
tamMatSoma = size(matSoma);
tamMatTot = size(matSomaTot);
matUm = ones(1, tamMatSoma(1,2)); 
matUmTot = ones(1, tamMatTot(1,2));
mS = [matSoma; matUm]; 
                       % adiciona-se valores 1 à matriz soma de compostos 
                       % para atender à condição de soma baricêntrica. 
mT = [matSomaTot;matUmTot];
                       % atendimento à soma  baricêntrica
x = (((mS)' * mS))^(-1) * (mS)' * (mT);
                       % realização da projeção pelos mínimos quadrados. 


%% passo dois:determinação da coordenada baricêntrica negativa e vetor.

tamX = size(x);
if any(x<0) == 1
    for u = 1 : tamX(1,1)
        if x(u,1) < 0 
            vetNeg = matSoma(:,u);
            coordNeg = x(u,1);
            pont = u;
        end
    end
else
    esco = randi([1 tamMatSoma(1,2)],1,1);
    vetNeg = matSoma(:,esco);
end



%% passo 3: Cálculo vetor ProjMMQ e CoordBariceNeg

% Primeiro, determina-se para qual ponto ocorre a projeção do total. Depois
%, determinado esse ponto, faz-se a subtração entre esse ponto determinado
% e o correspondente vetor para o qual a coordenada baricêntrica é negativa
%. 

ponto = matSoma * x;
vet = ponto - vetNeg;
M = matSoma * [1/3;1/3;1/3];

%% 4 -  Determinação dos pontos ao longo da linha segundo um passo:

% Nessa etapa, verifica-se diversos pontos que estao em cima da linha
% definida pelo vetor de coordenada baricêntrica negativa e a projeção do
% MMQ.

passo = 0.01;
parou = false;
h = 1 ;
estim = zeros(4,1);
flag = 0;
while parou == false
    newPont = vetNeg + passo * h * vet;
    newCoorBari = ((matSoma)'* matSoma)^(-1) * matSoma' * newPont;
    
    if any((newCoorBari) < 0) == 1 && h > 1
        parou = true;
        ponto  = matSoma * newCoorBari;
    else
        ponto  = matSoma * newCoorBari;
        estim(:,h) = ponto;
        divBari(:,h) = newCoorBari;
        flag = 1;
    end
    h = h + 1;
end
if flag == 0
    estim = vetNeg;
end
 

%% 5 - Projeção do desconhecido a partir dos pontos e do percen

% No próximo passo, os pontos determinados no passo anterior pela  reta que
% liga a projeção MMQ e o vértice de coordenada baricêntrica negativa serão
% utilizados para fazer uma projeção do desconhecido na região acima do
% plano definido pelos vetores de compostos. 

tamPercen = size(percen);
tamEst = size(estim);
resul2 = cell(1, tamPercen(1,2));
for t = 1 : tamPercen(1,2)
    percenDesc= percen(1,t);
    for q = 1 : tamEst(1,2)
        desc = (matSomaTot - ((1- percenDesc) * estim(:,q)))/(percenDesc);
        valDesc(:,q) = desc;
        maxiValu = max(valDesc);
    end
    resul2{1,t} = valDesc;
end

%% Extra - Determinação do total como função de todos os compostos

% Esse passo extra será feito para se verificar se os valores advindo dos
% passo anterior realmente fornecem coordenadas baricêntricas positivas.
% Isso será feito para cada coluna da matriz inserida em cada uma das
% células do passo anterior, ou seja, uma determinada célula contém uma
% matriz com 4 linhas e 'n' colunas, o mesmo valendo para a segunda
% célula.

% for j = 1 : tamPercen(1,2)
%     tamValDesc = size(valDesc);
%     for  o = 1 : tamValDesc(1,2)
%         fita = [matSoma resul2{1,j}(:,o)]; 
%         values{1,j}(:,o) = ((fita)' * (fita))^(-1) * (fita)' * matSomaTot;
%     end
% end

%% 6 - Divisão dos resultados pelo tamanho da partição

% Os diferentes resultados serão divididos pelo tamanho da partição. Como
% entrada para esse trecho de código, tem-se uma célula de tamanho 2, uma
% celula para cada valor de percentual, e dentro de cada uma das células
% existem matrizes com os valores de estimatica de desconhecido para uma
% determinada coluna. A quantidade de colunas que uma matriz irá conter
% dentro de uma célula dependerá da quantidade de passoas realizados na
% etapa anterior. 

resul7 = cell(1,tamPercen(1,2));
for s = 1 : tamPercen(1,2)
   tamMat = size(resul2{1,s});
   for r = 1 : tamMat(1,2)
       tamLin = size(resul2{1,2}(:,r));
       for p = 1 : tamLin(1,1)
            temp = (resul2{1,s}(p,r)) / (partRef(p,2) - partRef(p,1));
            resul7{1,s}(p,r) = temp;
       end
   end
end

% Para cada valor de percentual, serão determinados os valores de
% máximo e mínimo do composto desconhecido em cada uma das partições. Para
% o primeir valor percentual, a saida será uma matriz de dimensão
% (Partições X 2), onde na primeira linha conterá as informações a 
% respeito da primeira partição, sendo que  coluna um será o valor de
% mínimo e a coluna dois conterá o valor de máximo. Essa matriz ficará em
% uma posição de célula. A segunda posição de célula conterá os valores
% para o segundo valor percentual.

resul3 = cell(1, tamPercen(1,2));
ref = [inf(tamMat(1,1),1) zeros(tamMat(1,1),1)];
for l = 1 : tamPercen(1,2)
    matAna = resul7{1,l};
    tamMat = size(matAna);
    for i = 1 : tamMat(1,1)
        for e = 1 : tamMat(1,2)
            if matAna(i,e) < ref(i,1) && matAna(i,e) > 0
                ref(i,1) = matAna(i,e);
            end
            if matAna(i,e) > ref(i,2) && matAna(i,e) > 0
                ref(i,2) = matAna(i,e);
            end
        end
    end
end
resul = ref;

%% Extração  dos valores máximos e mínimos globais do passo anterior

% Trecho de código para extração dos valores de máximo e mínimo do passo
% anterior.


tamResul = size(resul);
maxSai = 0;
minSai = inf;
sai1 = 0; sai2 = 0;
for b = 1 : tamResul(1,1)
   for g = 1 : tamResul(1,2)
       if g == 1
           if resul(b,g) < minSai
               sai1 = resul(b,g);
               minSai = resul(b,g);
            end
        end
        if g == 2
            if resul(b,g) > maxSai
                sai2 = resul(b,g);
                maxSai = resul(b,g);
            end
        end
    end
end
feed = [sai1 sai2];



%passo solicitado por Silvio. Depois comentar ou apagar.
%for ji = 1 : 0.01 : 2
%    D = (1 - ji) *  M + ji * matSomaTot;
%    newD = [D;1];
%    newmS = [mS  newD];
%    coord = ((newmS' * newmS)^(-1)) * (newmS)' * mT;
%    totSi = (newmS(1:end-1,:)) * coord;
%    residuo = abs(sum(totSi) - sum(matSomaTot)); 
%    residuo
%end
    
end




