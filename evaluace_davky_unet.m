clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';



counts={};

bad=0;
all=0;


folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders_new=[folders_new [path '/' folders(k).name]];
end
folders=folders_new;

folders=sort(folders);


for folder_num=1:length(folders)
    
    
    folder=folders{folder_num};

    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)


    names=subdir([folder '/*3D*.tif']);
    names={names(:).name};

    count=[];
    
    

    for img_num=1:length(names)
        img_num
    
        name=names{img_num};


        name_mask=strrep(name,'3D_','mask_');
        mask_name_split=strrep(name,'3D_','mask_split');

        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');

        
        save_unet_foci_detection_res=strrep(name,'3D_','unet_foci_detection_res');
        save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');
        
        
        save_unet_foci_detection_res_points=strrep(name,'3D_','unet_foci_detection_res_points');
        save_unet_foci_detection_res_points=strrep(save_unet_foci_detection_res_points,'.tif','.mat');
        
        
        save_unet_foci_segmentation_res=strrep(name,'3D_','unet_foci_segmentation_res');
        
        
        save_results_table_unet=strrep(name,'3D_','results_table_unet');
        save_results_table_unet=strrep(save_results_table_unet,'.tif','.csv');
        

        L_res=bwlabeln(imread(save_unet_foci_segmentation_res));
        L_nuc_mask=bwlabeln(imread(mask_name_split));
        
        [a,b,c]=read_3d_rgb_tif(name);
        
        nuc_volumes=regionprops3(L_nuc_mask,'Volume');
        nuc_volumes=nuc_volumes.Volume;
        
        r_table = regionprops3(L_res,a,'MaxIntensity','MeanIntensity');
        r_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityR';
        r_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityR';
        
        g_table = regionprops3(L_res,b,'MaxIntensity','MeanIntensity');
        g_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityG';
        g_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityG';
        
        
        rg_table = regionprops3(L_res,a.*b,'MaxIntensity','MeanIntensity');
        rg_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityRG';
        rg_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityRG';
        
        other_table = regionprops3(L_res,L_nuc_mask,'MaxIntensity','Volume');
        other_table.Properties.VariableNames{'MaxIntensity'}='CellNum';
        tmp=nuc_volumes(other_table.CellNum);
        other_table = addvars(other_table,tmp,'NewVariableNames','NucVolume');
        tmp(:)=max(L_nuc_mask(:));
        other_table = addvars(other_table,tmp,'NewVariableNames','MaxCellNum');
        
        res_table=[r_table,g_table,rg_table,other_table];
        
        writetable(res_table,save_results_table_unet)
        
        drawnow

        
    end

end




