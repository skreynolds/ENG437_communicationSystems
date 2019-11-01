function dmin = dmincalc(M)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Min Hamming Distance Calculator
% Input: complete codeword matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [r,c] = size(M);
    
    % Prespecify best possible Hamming distance
    dmin = 7;
    
    for i = 1:(c-1)
        for j = (i+1):c
            %fprintf('%d %d\n',i,j)
            dist = sum(mod(M(:,i) + M(:,j),2));
            % Store progressively worse Hamming distance
            if dist < dmin
                dmin = dist;
            end
        end
    end
end