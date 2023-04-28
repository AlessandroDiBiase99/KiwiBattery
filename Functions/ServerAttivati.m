function s_a = ServerAttivati(Marcatura,MaxServer,Input)
    s_a = min(Marcatura./Input);
    if s_a>MaxServer
        s_a=MaxServer;
    end
end

