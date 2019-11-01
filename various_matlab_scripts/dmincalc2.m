function dmin = dmincalc2(M)
    
    weights = sum(M);
    I = (weights<=3);
    new_M = M(:,I);
    [~,c] = size(new_M);
    
    dmin = 22;
    
    for i = 1:(c-1)
        for j = (i+1):c
            dist = sum(mod(new_M(:,i) + new_M(:,j),2));
            if dist < dmin
                dmin = dist;
            end
        end
    end
end