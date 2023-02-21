function s=array2string(array)
    s='[';
    for i=1:length(array)-1
        s=[s,' ',num2str(array(i)),','];
    end
    s=[s,' ',num2str(array(end)), ']'];
end