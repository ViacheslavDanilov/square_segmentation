function [ img ] = GetTestImage( sz )

r = sz *0.3; % radius of a circle
img = ones(sz,sz) * 255;
margin1 = round(0.05 * sz);
margin2 = round(0.1 * sz);
img(margin1:sz-margin1, margin1:sz-margin1) = 0;
img(margin2:sz-margin2, margin2:sz-margin2) = 200;
for i=1:sz
    for j=1:sz
        if ((i-sz/2)^2 + (j-sz/2)^2 <= r^2)
            img(i,j) = 255;
        end
    end
end

end

