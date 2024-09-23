clear;

groupS = GPT4_Spoiled; % GPTS matrix
groupS(3,:) = nan; % no spoiler representation in the brain
groupS(:,3) = nan; % no spoiler representation in the brain

groupT = GPT4_Twisted; % GPTT matrix

% Get lower triangular values for S_L
temp = nan(size(groupS));
temp = triu(temp);
S_L = groupS + temp;
S_L = S_L(~isnan(S_L));

% Get lower triangular values for T_L
temp = nan(size(groupT));
temp = triu(temp);
T_L = groupT + temp;
T_L = T_L(~isnan(T_L));

% At this point, S_L and T_L should have the same number of elements (741)

% Verify sizes
disp(['Size of S_L: ', num2str(length(S_L))]);
disp(['Size of T_L: ', num2str(length(T_L))]);

% load reps - spoiled subjects
load('load_your_result.mat');

% diagonal removal
X = eye(41); X(X==1)=nan;

% create reactivation matrices
EB = boundSceneE;
for iSub=1:7
    ss=boundSceneE(:,:,iSub);
    group=EB;
    group(:,:,iSub)=[];
    temp=corr(squeeze(nanmean(group,3)),ss,'rows','pairwise');
    idx=find(isnan(nanmean(temp)));
    temp(idx,:)=nan;
    boundSceneEs(:,:,iSub)=temp+X;
end
boundSceneEs(1,:,:)=[]; %representation of clip
boundSceneEs(:,1,:)=[]; %representation of clip


% load reps for twist subjects
load('load_your_result.mat');

% Create reactivation matrices
EB = boundSceneE;
for iSub = 1:10
    ss = boundSceneE(:,:,iSub);
    group = EB;
    group(:,:,iSub) = [];  % Remove the iSub-th slice from group
    temp = corr(squeeze(nanmean(group, 3)), ss, 'rows', 'pairwise');
    idx = find(isnan(nanmean(temp)));
    temp(idx,:) = nan;
    boundSceneEt(:,:,iSub) = temp + X;
end

% load reps for notwist subjects
load('load_your_result.mat');

% create reactivation matrices
EB = boundSceneE;

for iSub=1:10
    ss = boundSceneE(:,:,iSub);
    group=EB;
    group(:,:,iSub)=[];
    temp=corr(squeeze(nanmean(group,3)),ss,'rows','pairwise');
    idx=find(isnan(nanmean(temp)));
    temp(idx,:)=nan;
    boundSceneEn(:,:,iSub)=temp+X;
end
boundSceneEn(1,:,:)=[]; %representation of clip
boundSceneEn(:,1,:)=[]; %representation of clip


% correlate templates with ss matrices

% start with the spoiled subjects

for iSub=1:7

    group=boundSceneEs;
    ssEs=group(:,:,iSub);
    
    % past correlations
    ssEsP=tril(ssEs);
    ssEsP(ssEsP==0)=nan;
    ssEsP=ssEsP(~isnan(ssEsP));
         
     % future correlations
    ssEsF=triu(ssEs);
    ssEsF(ssEsF==0)=nan;
    ssEsF=ssEsF(~isnan(ssEsF));
    
     %within group
    [past]=dist_and_fisher(ssEsP,S_L,'correlation');
    [future]=dist_and_fisher(ssEsF,S_L,'correlation');
     
    Corrs_ss(iSub)=past-future;

    % between groups
    [past]=dist_and_fisher(ssP,T_L,'correlation');
    [future]=dist_and_fisher(ssF,T_L,'correlation');
    
    Corrs_st(iSub)=past-future;
end

% move on to the twist subjects

for iSub=1:10
    
    group=boundSceneEt;
    ssET=group(:,:,iSub);
        
    % past correlations
    ssP=tril(ss);
    ssP(ssP==0)=nan;
    ssP=ssP(~isnan(ssP));

    % future correlations
    ssF=triu(ss);
    ssF(ssF==0)=nan;
    ssF=ssF(~isnan(ssF));
   
    %within group
    [past]=dist_and_fisher(ssP,T_L,'correlation');
    [future]=dist_and_fisher(ssF,T_L,'correlation');
     
    Corrs_tt(iSub)=past-future;

    % between groups
    [past]=dist_and_fisher(ssP,S_L, 'correlation');
    [future]=dist_and_fisher(ssF,S_L,'correlation');
    
    Corrs_ts(iSub)=past-future;
end

% twist/no twist group should have similar reactivations UNTIL the twist
groupT(:,37:39)=nan;
groupT(37:39,:)=nan;
temp=nan(size(groupT));
temp=triu(temp);
T_L=groupT+temp;
T_L=T_L(~isnan(T_L));

groupS(:,38:40)=nan;
groupS(38:40,:)=nan;
temp=nan(size(groupS));
temp=triu(temp);
S_L=groupS+temp;
S_L=S_L(~isnan(S_L));


for iSub=1:10
    
    group=boundSceneEn;
    ssEn=group(:,:,iSub);
    
    % past correlations
    ssP=tril(ss);
    ssP(ssP==0)=nan;
    ssP=ssP(~isnan(ssP));
    
    % future correlations
    ssF=triu(ss);
    ssF(ssF==0)=nan;
    ssF=ssF(~isnan(ssF));
    
    
    %within group
    [past]=dist_and_fisher(ssP,T_L,'correlation');
    [future]=dist_and_fisher(ssF,T_L,'correlation');

    Corrs_nt(iSub)=past-future;

    % between groups
    [past]=dist_and_fisher(ssP,S_L,'correlation');
    [future]=dist_and_fisher(ssF,S_L,'correlation');

    Corrs_ns(iSub)=past-future;
end

% test if correlations within groups are larger than correlations between
% groups
[p1,h,stats] = ranksum(Corrs_ss,Corrs_st); %spoiled group
[p2,h,stats] = ranksum(Corrs_tt,Corrs_ts); %twist group
[p3,h,stats] = ranksum(Corrs_nt,Corrs_ns); %no twist group
[h p4 c t4]=ttest([Corrs_ss Corrs_tt Corrs_nt],[Corrs_st Corrs_ts Corrs_ns],"Tail","right"); %pooled subjects


% plot the templates
figure('units','normalized','outerposition',[0 0 1 1])
clims = [0 1];
subplot(1,2,1)
imagesc(groupS,clims)
title('Spoiler template')
axis square
colorbar

subplot(1,2,2)
imagesc(groupT,clims)
title('Twist template')
axis square
colorbar
