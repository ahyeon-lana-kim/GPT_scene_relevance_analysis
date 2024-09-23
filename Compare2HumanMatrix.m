# NOTES: The following script runs the permutation test to compare the scene relevance scores between GPT matrix and human matrix

clear;

GPT4_Spoiled=GPT4_Spoiled+triu(nan(size(GPT4_Spoiled))); %remove upper triangular
Manual_Spoiled = Manual_Spoiled + triu(nan(size(Manual_Spoiled)));

irrelevant=GPT4_Spoiled(Manual_Spoiled==0);
relevant=GPT4_Spoiled(Manual_Spoiled==1);
pivotal=GPT4_Spoiled(Manual_Spoiled==2);

% compute real difference in means
relevant_irrelevant=mean(relevant)-mean(irrelevant);
pivotal_irrelevant=mean(pivotal)-mean(irrelevant);
pivotal_relevant=mean(pivotal)-mean(relevant);

% permutation test
GPT4_Spoiled(isnan(GPT4_Spoiled))=[]; % turn into vector

for i=10000
    permutedValues=GPT4_Spoiled(randperm(length(GPT4_Spoiled))); % shuffle values in the vector
    I=mean(permutedValues(1:length(irrelevant))); % get the mean of random irrelevant scenes
    R=mean(permutedValues(length(irrelevant)+1:length(irrelevant)+length(relevant))); % get the mean of random relevant scenes
    P=mean(permutedValues(length(irrelevant)+length(relevant)+1:end)); % get the mean of random crucial scenes

    % now compute the differences between the random means
    RI(i)=R-I;
    PI(i)=P-I;
    PR(i)=P-R;
end

% compare the real difference in means to the random means to get p-values
pval_RI=1-sum(relevant_irrelevant>=RI)/length(RI)
pval_PI=1-sum(pivotal_irrelevant>=PI)/length(PI)
pval_PR=1-sum(pivotal_relevant>=PR)/length(PR)

