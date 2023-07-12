function s=array2string(array)
%
% Authors:
%    - Caponi Luca
%    - Catalini Federico
%    - Di Biase Alessandro
    s='[';
    for i=1:length(array)-1
        s=[s,' ',num2str(array(i)),','];
    end
    s=[s,' ',num2str(array(end)), ']'];
end