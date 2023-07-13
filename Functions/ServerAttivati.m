function s_a = ServerAttivati(Marcatura,MaxServer,Pre,H)
% ServerAttivati è una funzione che restituisce il numero di server che
% risultano attivati in base alla marcatura presente, al numero di token
% richiesti in ingresso e il numero di server totali.
%
% INPUT:
%    - Marcatura:
%      la marcatura corrente.
%    - MaxServer:
%      il numero massimo di server disponibili.
%    - Input:
%      il numero di token richiesto in input.
% OUTPUT:
%    - s_a:
%      il numero di server che risultano contemporaneamente attivi date le
%      configurazioni presenti.
%
% AUTORI:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro

% Se la marcatura non inibisce la transizione
if all(H==0 | (H>0 & Marcatura<H))
    % Calcolo quante volte potrebbe essere abilitata la transizione in base
    % alla marcatura presente
    s_a = floor(min(Marcatura./Pre));
    % Se il numero di server che possono essere attivati supera il numero
    % massimo alloea si assegna il valore massimo che può assumere
    if sum(Pre)==0 || s_a>MaxServer
        s_a=MaxServer;
    end
else
    % Se la marcatura inibisce la transizione allora non è attivo alcun
    % server
    s_a=0;
end
end

