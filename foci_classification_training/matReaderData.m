function [window_k] = matReaderData(filename)


    load(filename);
    
    p=randi(5)-3;
    q=randi(5)-3;
    r=randi(3)-2;
%     window_k=window_k(3+p:end-3+p,3+q:end-3+q,2+r:end-2+r,:);
    window_k=window_k(4+p:end-4+p,4+q:end-4+q,2+r:end-2+r,:);

    if rand()>0.5
        window_k=fliplr(window_k);
    end
    if rand()>0.5
        window_k=flipud(window_k);
    end
    window_k=rot90(window_k,randi(4)-1);
    if rand()>0.5
        window_k=fliplr(window_k);
    end
    if rand()>0.5
        window_k=flipud(window_k);
    end
    
    min_v=rand()*0.6-0.3;
    max_v=1+rand()*0.6-0.3;
    window_k(:,:,:,1)=single(mat2gray(window_k(:,:,:,1),[min_v max_v]))-0.5;
    min_v=rand()*0.6-0.3;
    max_v=1+rand()*0.6-0.3;
    window_k(:,:,:,2)=single(mat2gray(window_k(:,:,:,2),[min_v max_v]))-0.5;

%     window_k=window_k(4:end-4,4:end-4,2:end-2,:);
%     window_k=single(mat2gray(double(window_k),[90,600])-0.5);
%     window_k=single(mat2gray(window_k,[90,600])-0.5);
%     window_k=single((window_k-mean(window_k(:)))/std(window_k(:))) ;
end
