clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('utils')
addpath('3DNucleiSegmentation_training')

% load('../names_foci_sample.mat')
% names_orig=names;

% names=subdir('../..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
% names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
% names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder_used\*3D_*.tif');
names=subdir('E:\foky_tmp\man_nahodny_vzorek_tif\*data_*.tif');

names={names(:).name};


gpu=1;

load('test3_value_aug_mult.mat')

tp=0;
fp=0;
fn=0;
for img_num=1:100
    
    img_num
    
    name=names{img_num};
    
    name_2D=strrep(name,'data_','2D_');
%     name_orig=names_orig{img_num};
    
    name_mask=strrep(name,'data_','mask_');
    mask_name_split=strrep(name,'data_','mask_split');
    
    
    name_mask_foci=strrep(name,'data_','mask_foci_');
    
    
    save_control_seg=strrep(name,'data_','control_seg_foci');
    save_control_seg=strrep(save_control_seg,'.tif','');
    
    save_manual_label=strrep(name,'data_','manual_label_');
    save_manual_label=strrep(save_manual_label,'.tif','.mat');
    
    
%     save_features=strrep(name,'data_','features_window_');
    save_features=strrep(name,'data_','features_window2_');
    save_features=strrep(save_features,'.tif','.mat');


    save_features_for_celnum=strrep(name,'data_','features_cellnum_');
    save_features_for_celnum=strrep(save_features_for_celnum,'.tif','.mat');
    
    
    save_unet_foci_detection_mask=strrep(name,'data_','unet_foci_detection_mask');
    save_unet_foci_detection_mask=strrep(save_unet_foci_detection_mask,'.tif','.mat');
    
    
    save_unet_foci_detection_data=strrep(name,'data_','unet_foci_detection_data');
    save_unet_foci_detection_data=strrep(save_unet_foci_detection_data,'.tif','.mat');
    
    
    save_unet_foci_detection_res=strrep(name,'data_','unet_foci_detection_res');
    save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');
    

    
    save_unet_foci_segmentation_res_t29=strrep(name,'data_','unet_foci_segmentation_res_t29');
    
    
    save_final_results_unet_control_t29=strrep(name,'data_','final_results_unet_control_t29');
    save_final_results_unet_control_t29=strrep(save_final_results_unet_control_t29,'.tif','');
    


     load(save_unet_foci_detection_res)
        
        rgb_2d=imread(name_2D);
        
        rgb_2d=cat(3,norm_percentile(rgb_2d(:,:,1),0.005),norm_percentile(rgb_2d(:,:,2),0.005),norm_percentile(rgb_2d(:,:,3),0.005));
        
        
        rgb_2d=imresize(rgb_2d,[size(vys,1) size(vys,2)]);
        
        h=0.3;
        d=12;
        t=2.9;

        load(save_unet_foci_detection_res)

        [X,Y,Z] = meshgrid(linspace(-1,1,d),linspace(-1,1,d),linspace(-1,1,int16(d/3)));
        sphere=sqrt(X.^2+Y.^2+Z.^2)<1;

        tmp=imdilate(vys,sphere);
        tmp = imhmax(tmp,h);
        tmp = imregionalmax(tmp).*(vys>t);

        detection_results=false(size(tmp));
        s = regionprops(tmp>0,'centroid');
        centroids = round(cat(1, s.Centroid));
        for kp=1:size(centroids,1)
            detection_results(centroids(kp,2),centroids(kp,1),centroids(kp,3))=1;
        end



        if isempty(centroids)
           centroids=zeros(0,3);
        end    
    
    
        [a,b,c]=read_3d_rgb_tif(name);
        
        
        
       a=a(:,:,[2,4:end]);
       b=b(:,:,[2,4:end]);
       c=c(:,:,[2,4:end]);
       
       factor=size(a)./size(vys);
        
    
%         factor=[2,2,1];
        
        centroids(:,1)=centroids(:,1)*factor(1);
        centroids(:,2)=centroids(:,2)*factor(2);
        centroids(:,3)=centroids(:,3)*factor(3);
        
        
        
        
        
        detection_results=false(size(a));
        for kp=1:size(centroids,1)
            detection_results(centroids(kp,2),centroids(kp,1),centroids(kp,3))=1;
        end

        
        


        mask=imread(mask_name_split);
        
        mask=imresize3(uint8(mask),size(a),'nearest')>0;
        
%         lbl_mask=bwlabeln(mask);
        
%         lbl_mask=imresize3(lbl_mask,size(a));
        

        [a,b,c]=preprocess_filters(a,b,c,gpu);

        rgb_2d=cat(3,norm_percentile(mean(a,3),0.001),norm_percentile(mean(b,3),0.001),norm_percentile(mean(c,3),0.001));



        a=norm_percentile(a,0.00001);
        b=norm_percentile(b,0.00001);
        
        ab=a.*b;
        ab_uint_whole=uint8(mat2gray(ab)*255).*uint8(mask);
        clear a b ab c

        result=zeros(size(ab_uint_whole),'uint16');

        
        s = regionprops(mask>0,'BoundingBox');
        bbs = cat(1,s.BoundingBox);
        
        
         for cell_num =1:size(bbs,1)

            bb=round(bbs(cell_num,:));
            ab_uint = ab_uint_whole(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
            detection_results_crop=detection_results(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
%             ab_uint=max(ab_uint,[],3);
            
            
            tic
            %    try
            r=vl_mser(ab_uint,'MinDiversity',0.1,...
                'MaxVariation',0.8,...
                'Delta',1,...
                'MinArea', 50/ numel(ab_uint),...
                'MaxArea',2400/ numel(ab_uint));
            %     catch
            %         r=[] ;
            %     end

            M = zeros(size(ab_uint),'uint16') ;
            for x=1:length(r)
                s = vl_erfill(ab_uint,r(x)) ;
                M(s) = M(s) + 1;
            end
            
            

            M=M>0;
            
%             shape=[5,5,3];
%             [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
%             sphere=sqrt(X.^2+Y.^2+Z.^2)<=1;
%             M=imerode(M,sphere);

            

            shape=[9,9,3];
            [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
            sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
            

            

            pom=-double(ab_uint);
            pom=imimposemin(pom,detection_results_crop);
            wab_krajeny=watershed(pom)>0;
            wab_krajeny(M==0)=0;
            wab_krajeny=imfill(wab_krajeny,'holes');
            
            
            wab_krajeny_orez=wab_krajeny;
            tmp=~wab_krajeny_orez;
%             shape0=size(tmp);
%             tmp=imresize3(uint8(tmp),[shape0(1)*3,shape0(2)*3,shape0(3)],'nearest')>0;
%             D = bwdist(tmp);
            D=bwdistsc(tmp,[1,1,3]);
            D=imhmax(D,1);
%             D=imresize3(D,shape0,'linear');
            wab_krajeny_orez=(watershed(-D)>0) & wab_krajeny_orez;
            
            
            L=bwlabeln(wab_krajeny_orez);
            s=regionprops3(L,detection_results_crop,'MaxIntensity');
            s = s.MaxIntensity;
            for k=1:length(s)
                if s(k)==0
                    L(L==k)=0;
                end
            end
            wab_krajeny=L>0;

            toc

            result(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1)=wab_krajeny;


        end

        wab_krajeny=result;
        
        hold off
        imshow(rgb_2d)
        hold on
        visboundaries(max(wab_krajeny,[],3))
        if ~isempty(centroids)
            plot(centroids(:,1), centroids(:,2), 'ro','MarkerSize',3)
            plot(centroids(:,1), centroids(:,2), 'g*','MarkerSize',3)
        end
        
        print(save_final_results_unet_control_t29,'-dpng')
        
        imwrite_uint16_3D(save_unet_foci_segmentation_res_t29,wab_krajeny)
    
        drawnow;

    
end