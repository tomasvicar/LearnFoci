clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';
path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\dva_pacienti_tif';


counts={};

bad=0;
all=0;


folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders2=dir([path '/' folders(k).name]);
    
    for kk=3:length(folders2)
        folders3=dir([path '/' folders(k).name '/' folders2(kk).name]);
        for kkk=3:length(folders3)
            
            folders_new=[folders_new [path '/' folders(k).name '/' folders2(kk).name '/' folders3(kkk).name]];
            
        end
    end
end
folders=folders_new;

folders=sort(folders);



result_value=[];
result_folder_names={};


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
        
        
        res_table=readtable(save_results_table_unet);
        
        tmp=repmat({folder},[size(res_table,1),1]);
        res_table= addvars(res_table,tmp,'NewVariableNames','Folder');
        tmp=repmat({name},[size(res_table,1),1]);
        res_table= addvars(res_table,tmp,'NewVariableNames','ImgName');
        
        if ~isempty(res_table)
            for k=1:res_table.MaxCellNum(1)
                count=sum(res_table.CellNum==k);
                result_value=[result_value,count];
                
                folder_name=split(folder,{'\','/'});
                result_folder_names=[result_folder_names,folder_name{end}];
                
            end
        end
        
    end

end




boxplot(result_value,result_folder_names)

