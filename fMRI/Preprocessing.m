% Script created by Ina Thome & Nestor Zaragoza, University of Marburg, 01 September 2022
% Script is designed to preprocess the FRAPPS task as part of the FRAPPS study. 
%preprocessing steps: slicetiming, realign, coregister, segment, normalize, smooth

clear 

Exp_dir = ('/scratch/thome/FRAPPS_BIDS/derivatives/preprocessing/FRAPPS');%path to the Bids directory
%to select or unselect participants comment them in or out 
subjMat = { 
%'sub-01',;...
'sub-02',;...
'sub-03',;...
'sub-04',;...
'sub-05',;...
'sub-06',;...
'sub-07',;...
'sub-08',;...
'sub-09',;...
'sub-10',;...
'sub-11',;...
'sub-12',;...
'sub-13',;...
'sub-14',;...
'sub-15',;...
%'sub-16',;...%FD more than 0.3 --> excluded


'sub-17',;...
'sub-18',;... 
'sub-19',;...
'sub-20',;...
%'sub-21',;...%low behavioral performance in FRAPPS <60% --> excluded
'sub-22',;...

'sub-23',;...
'sub-24',;...
'sub-25',;...
'sub-26',;... %FD more than 0.3 --> excluded
'sub-27',;...

'sub-28',;...
'sub-29',;...
'sub-30',;...
'sub-31',;...
'sub-32',;... 
'sub-33',;...
'sub-34',;...
%}
};

%start subject loop
for s = 1:length(subjMat)
    cd([ Exp_dir '/' subjMat{s} '/func/'])
    
   
    % Initialise SPM
    % --------------------------------------------------------------------------
    spm_figure('GetWin','Graphics');
    spm('Defaults','fMRI');
    spm_jobman('initcfg');

    clear matlabbatch
    
    
    % check whether files have been zipped, if not unzpip them by using
    % gunzip
    
    if exist([Exp_dir '/' subjMat{s} '/func/' subjMat{s} '_task-frapps_bold-dummy-scans.nii']) == 0 
        disp('FRAPPS task has not been unzipped; unzipping now')
        gunzip([Exp_dir '/' subjMat{s} '/func/' subjMat{s} '_task-frapps_bold-dummy-scans.nii.gz'])
    else 
        disp('FRAPPS task is already unzipped; doing nothing')
    end 
   
    
    if exist([Exp_dir '/' subjMat{s} '/anat/' subjMat{s} '_T1w.nii']) == 0
        disp('Anatomical image has not been unzipped; unzipping now')
        gunzip([Exp_dir '/' subjMat{s} '/anat/' subjMat{s} '_T1w.nii.gz'])
    else 
        disp('Anatomical image is already unzipped; doing nothing')
    end
    
    %select functonal data
    clear dataFNC
        SourceDir = ([Exp_dir '/' subjMat{s} '/func/sub*task-frapps_bold-dummy-scans.nii']); %change for or add the name for the new 3d files e.g.: frapps_new*.nii excluding already the first four scans
        files ={};
        files = dir(SourceDir);
    for i = 1:length(files)
        dataFNC {i,1} = ([Exp_dir '/' subjMat{s} '/func/' files(i,1).name]);
    end 
    
    %expand 4d image into 3d nifti files
    func_images = spm_select('expand', dataFNC);
    func_images = cellstr(func_images);
    
    %path to anatomical image
    anat_image = strcat(Exp_dir, '/' ,subjMat{s}, '/anat/', subjMat{s}, '_T1w.nii,1');
    
    
 

%%slice timing correction 

matlabbatch{1}.spm.temporal.st.scans = {func_images};
matlabbatch{1}.spm.temporal.st.nslices = 48;
matlabbatch{1}.spm.temporal.st.tr = 1.53;
matlabbatch{1}.spm.temporal.st.ta = 0; %with multiband acquisition can be set to 0
matlabbatch{1}.spm.temporal.st.so = [0
                        65
                       130
                     192.5
                     257.5
                       320
                       385
                       450
                     512.5
                     577.5
                       640
                       705
                     767.5
                     832.5
                     897.5
                       960
                      1025
                    1087.5
                    1152.5
                    1217.5
                      1280
                      1345
                    1407.5
                    1472.5
                         0
                        65
                       130
                     192.5
                     257.5
                       320
                       385
                       450
                     512.5
                     577.5
                       640
                       705
                     767.5
                     832.5
                     897.5
                       960
                      1025
                    1087.5
                    1152.5
                    1217.5
                      1280
                      1345
                    1407.5
                    1472.5]; % Use slice timing in ms. - reference use specific time. TR/2 in ms 
matlabbatch{1}.spm.temporal.st.refslice = 765; % Tr/2 in ms
matlabbatch{1}.spm.temporal.st.prefix = 'a';

%%Spatial realigment
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));                                                                                   
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';


%coregister 
matlabbatch{3}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{3}.spm.spatial.coreg.estimate.source = {anat_image};
matlabbatch{3}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%segmentation
matlabbatch{4}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{4}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{4}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{4}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm = {'/export/data/mridsk001_sqfs/opt_global/SPM/spm12LI/tpm/TPM.nii,1'};
matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{4}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{4}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm = {'/export/data/mridsk001_sqfs/opt_global/SPM/spm12LI/tpm/TPM.nii,2'};
matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{4}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{4}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm = {'/export/data/mridsk001_sqfs/opt_global/SPM/spm12LI/tpm/TPM.nii,3'};
matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{4}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{4}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm = {'/export/data/mridsk001_sqfs/opt_global/SPM/spm12LI/tpm/TPM.nii,4'};
matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{4}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{4}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm = {'/export/data/mridsk001_sqfs/opt_global/SPM/spm12LI/tpm/TPM.nii,5'};
matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{4}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{4}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm = {'/export/data/mridsk001_sqfs/opt_global/SPM/spm12LI/tpm/TPM.nii,6'};
matlabbatch{4}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{4}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{4}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{4}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{4}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{4}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{4}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{4}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{4}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{4}.spm.spatial.preproc.warp.write = [0 1];

%normalize
matlabbatch{5}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{5}.spm.spatial.normalise.write.subj.resample(2) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{5}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{5}.spm.spatial.normalise.write.woptions.prefix = 'w';

%smoothing
matlabbatch{6}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{6}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{6}.spm.spatial.smooth.dtype = 0;
matlabbatch{6}.spm.spatial.smooth.im = 0;
matlabbatch{6}.spm.spatial.smooth.prefix = 's';


%% run SPM, write success or failure in logfile
    try
        spm_jobman('run',matlabbatch);
        processing='successfull';
    catch
        processing='failed';
    end    
    clear matlabbatch
    timestamp=datestr(now,'dd-mm-yyyy_HH:MM:SS');
    fid = fopen(fullfile(Exp_dir,'log_prepro_frapps.txt'), 'a'); %'w' for write, 'a' for append
    fprintf(fid,'%s %s %s %s %s\n', timestamp, 'subject', subjMat{s}, 'preprocessing', processing); %%;
    fclose(fid);  % Closes file.
    
end
