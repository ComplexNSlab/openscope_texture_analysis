%%
curFolder = 'textures240910/';
animals = dir(fullfile(pwd,curFolder));
animals=animals(~ismember({animals.name},{'.','..'}));
animals=animals(arrayfun(@(x)x.isdir==1,animals));

%%
texture = true;
for it1 = 1:length(animals)
  curAnimal = animals(it1).name;
  sessList = dir(fullfile(pwd, curFolder, curAnimal));
  sessList = sessList(~ismember({sessList.name},{'.','..'}));
  sessList = sessList(arrayfun(@(x)x.isdir==1,sessList));
  for it2 = 1:length(sessList)
  %for it2 = 9
    currSess = sessList(it2).name;
    % if(~strcmp(currSess, '1382489290'))
    %   continue;
    % end
    %files = dir(fullfile(pwd, curAnimal, currSess));
    licks = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'licks.csv'));
    stim = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'stim.csv'));
    rewards = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'rewards.csv'));
    %break;  
    Nstim = length(stim.image_name);
    family = zeros(size(stim.image_name));
    sample = zeros(size(stim.image_name));
    if(iscell(stim.image_name(1)))
      texture = true;
    else
      texture = false;
    end
    if(texture)
      for it3 = 1:Nstim
        A = sscanf(stim.image_name{it3},'%*[^0123456789]%d');
        family(it3) = A(1);
        sample(it3) = A(2);
      end
    else
       family = stim.orientation;
    end

    lastFamily = nan(length(licks.frame), 2);
    lastSample = nan(length(licks.frame), 2);
    lastT = nan(size(licks.frame));
    lastStim = nan(size(licks.frame));
    for it3 = 1:length(licks.frame)
      lastFrame = find(licks.frame(it3)-stim.frame > 0, 1, 'last');
      if(licks.frame(it3)<stim.frame(1) || licks.frame(it3) > stim.frame(end) || isempty(lastFrame) || licks.frame(it3)-stim.frame(lastFrame) > 40 || lastFrame == 1)
        continue;
      end
      lastFamily(it3, :) = [family(lastFrame) family(lastFrame-1)];
      lastSample(it3, :) = [sample(lastFrame) sample(lastFrame-1)];
      lastT(it3) = licks.frame(it3)-stim.frame(lastFrame);
      lastStim(it3) = stim.frame(lastFrame);
      if(licks.frame(it3) > stim.frame(end))
        break;
      end
    end
    [~, uniqueStims] = unique(lastStim);
    lastFamily = lastFamily(uniqueStims, :);
    lastSample = lastSample(uniqueStims, :);
    lastT = lastT(uniqueStims, :);
    valid = find(~isnan(lastT));
    lastFamily = lastFamily(valid, :);
    lastSample = lastSample(valid, :);
    if(~texture)
      lastFamily(lastFamily == 0) = 1;
      lastFamily(lastFamily == 90) = 2;
      lastFamily(lastFamily == 180) = 3;
      lastFamily(lastFamily == 270) = 4;
    end
    lastT = lastT(valid, :);
    figure;
    hist(lastT);
    title(sprintf('%s - %s', curAnimal, currSess))
    familyPairs = [family(1:end-1) family(2:end)];
    maxHits = sum(diff(familyPairs')~=0);
    maxFA = sum(diff(familyPairs') == 0);
    [length(find(diff(lastFamily') ~= 0 & ~isnan(diff(lastFamily')))) sum(diff(lastFamily') == 0)]
    [length(find(diff(lastFamily') ~= 0 & ~isnan(diff(lastFamily')))) sum(diff(lastFamily') == 0)]./[maxHits maxFA]
    %break;
  end
%  break;
end

%%
dataHits = lastFamily(find(diff(lastFamily') ~= 0 & ~isnan(diff(lastFamily'))),:);
if(texture)
  CmatHits = zeros(15);
  CmatFA = zeros(15);
else
  CmatHits = zeros(4);
  CmatFA = zeros(4);
end
for it1 = 1:size(dataHits,1)
  CmatHits(dataHits(it1,1),dataHits(it1,2)) = CmatHits(dataHits(it1,1),dataHits(it1,2)) + 1; 
end
dataFA = lastFamily(find(diff(lastFamily') == 0 & ~isnan(diff(lastFamily'))),:);
for it1 = 1:size(dataFA,1)
  CmatFA(dataFA(it1,1),dataFA(it1,2)) = CmatFA(dataFA(it1,1),dataFA(it1,2)) + 1; 
end
figure;
imagesc(CmatHits');
xlabel('pre img');
xlabel('post img');
figure;
imagesc(CmatFA');
xlabel('pre img');
xlabel('post img');
figure;plot(sum(CmatFA),sum(CmatHits,2),'o');
xlabel('FA');
ylabel('Hits');
%%
figure;
hold on;
%plot((licks.frame*[1,1])', (2*ones(size(licks.frame))*[0,1])', 'b-');
%plot((licks.frame*[1,1])', (2*ones(size(licks.frame))*[0,1])', 'b-');
cmap = lines(15);
plot((stim.frame*[1,1])', (2*ones(size(stim.frame))*[0,1])', 'r-');
plot(licks.frame, ones(size(licks.frame)), 'k.');
%xlim([0 1000])
%%

Nstim = length(stim.image_name);
family = zeros(size(stim.image_name));
sample = zeros(size(stim.image_name));
for it1 = 1:Nstim
  A = sscanf(stim.image_name{it1},'%*[^0123456789]%d');
  family(it1) = A(1);
  sample(it1) = A(2);
end

%%
lastFamily = nan(size(licks.frame));
lastSample = nan(size(licks.frame));
lastT = nan(size(licks.frame));
for it1 = 1:length(licks.frame)
  lastFrame = find(licks.frame(it1)-stim.frame > 0, 1, 'last');
  if(isempty(lastFrame))
    continue;
  end
  lastFamily(it1) = family(lastFrame);
  lastSample(it1) = sample(lastFrame);
  lastT(it1) = licks.frame(it1)-stim.frame(lastFrame);
  if(licks.frame(it1) > stim.frame(end))
    break;
  end
end
figure;
hist(lastT);

%% Different try

texture = true;
for it1 = 5:length(animals)
  curAnimal = animals(it1).name;
  sessList = dir(fullfile(pwd, curFolder, curAnimal));
  sessList = sessList(~ismember({sessList.name},{'.','..'}));
  sessList = sessList(arrayfun(@(x)x.isdir==1,sessList));
  for it2 = 3:length(sessList)
    currSess = sessList(it2).name;
    licks = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'licks.csv'));
    stim = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'stim.csv'));
    rewards = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'rewards.csv'));
    Nstim = length(stim.image_name);
    family = zeros(size(stim.image_name));
    sample = zeros(size(stim.image_name));
    if(iscell(stim.image_name(1)))
      texture = true;
    else
      texture = false;
    end
    if(texture)
      for it3 = 1:Nstim
        A = sscanf(stim.image_name{it3},'%*[^0123456789]%d');
        family(it3) = A(1);
        sample(it3) = A(2);
      end
    else
       family = stim.orientation;
    end
    totalFrames = stim.end_frame(end);
    fullData = zeros(totalFrames,1);
    %Nrows = floor(sqrt(size(fullData,1)));
    %Ncols = ceil(size(fullData,1)/Nrows);
    Ncols = 45*20;
    Nrows = ceil(totalFrames/Ncols);
    fullData = nan(Nrows*Ncols,1);
    for it3 = 1:size(stim,1)
      fullData(stim.frame(it3):stim.end_frame(it3)) = family(it3);
    end
    if(~texture)
      fullData(fullData == 0) = 1;
      fullData(fullData == 90) = 2;
      fullData(fullData == 180) = 3;
      fullData(fullData == 270) = 4;
    end
    fullData(licks.frame) = 5;
    if(texture)
      fullData = fullData(fullData > 0);
    else
      fullData = fullData(~isnan(fullData));
    end
    Ncols = 45*20;
    Nrows = ceil(length(fullData)/Ncols);
    fullDataMat = nan(Ncols*Nrows, 1);
    fullDataMat(1:length(fullData)) = fullData;
    fullDataMat = reshape(fullDataMat, [Ncols Nrows]);
    break;
  end
  break;
end

%% Yet one more with the split
% 3 is bad
texture = true;
for it1 = 1:length(animals)
  curAnimal = animals(it1).name;
  sessList = dir(fullfile(pwd, curFolder, curAnimal));
  sessList = sessList(~ismember({sessList.name},{'.','..'}));
  sessList = sessList(arrayfun(@(x)x.isdir==1,sessList));
  for it2 = 1:length(sessList)
    currSess = sessList(it2).name;
    licks = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'licks.csv'));
    stim = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'stim.csv'));
    Nstim = length(stim.image_name);
    family = zeros(size(stim.image_name));
    sample = zeros(size(stim.image_name));
    if(iscell(stim.image_name(1)))
      texture = true;
    else
      texture = false;
    end
    if(texture)
      for it3 = 1:Nstim
        A = sscanf(stim.image_name{it3},'%*[^0123456789]%d');
        family(it3) = A(1);
        sample(it3) = A(2);
      end
    else
       family = stim.orientation;
    end
    totalFrames = stim.end_frame(end);
    fullData = nan(totalFrames,1);
    for it3 = 1:size(stim,1)
      fullData(stim.frame(it3):stim.end_frame(it3)) = family(it3);
    end
    if(~texture)
      fullData(fullData == 0) = 1;
      fullData(fullData == 90) = 2;
      fullData(fullData == 180) = 3;
      fullData(fullData == 270) = 4;
    else
      fullData(fullData == 5) = 1;
      fullData(fullData == 6) = 2;
      fullData(fullData == 9) = 3;
      fullData(fullData == 11) = 4;
      fullData(fullData == 12) = 5;
      fullData(fullData == 13) = 6;
      fullData(fullData == 14) = 7;
      fullData(fullData == 15) = 8;
    end
    lastImg = nan;
    for it3 = 1:length(fullData)
      if(isnan(fullData(it3)))
        fullData(it3) = lastImg+0.02;
      else
        lastImg = fullData(it3);
      end
    end
    %figure;hist(fullData);
    fullDataLicks = fullData;
    fullDataLicks(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = 0;
    onlyLicks = nan(size(fullData));
    onlyLicks(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = fullData(licks.frame(licks.frame <= length(fullData) & licks.frame > 0));
    % Now look for all image changes
    imgChange = diff(fullData);
    invalid = isnan(fullData);
    frame = 1:length(fullData);
    fullData(invalid) = [];
    fullDataLicks(invalid) = [];
    onlyLicks(invalid) = [];
    frame(invalid) = [];
    figure;
    a = plot(frame, fullData);
    hold on;
    b = plot(frame, onlyLicks,'r.');
    ylim([0 10]);
    ylabel('Family label');
    xlabel('frame');
    legend('stim','licks');
    title(sprintf('Ani: %s - Sess: %s - Samp: %d', curAnimal, currSess, length(unique(sample))));
    % familyList = unique(round(fullData));
    % imgChange = find(abs(diff(fullData))>0.1)+1;
    % for it3 = 1:length(familyList)
    %   trialStart = imgChange(find(round(fullData(imgChange)) == familyList(it3)));
    %   trialEnd = zeros(size(trialStart));
    %   prevTrialStart = zeros(size(trialStart));
    %   prevTrialIdxList = zeros(size(trialStart));
    %   for it4 = 1:length(trialStart)
    %     trialEnd(it4) = trialStart(it4)+find(round(fullData(trialStart(it4):end)) ~= familyList(it3), 1, 'first')-2;
    %     prevTrialIdx = round(fullData(trialStart(it4)-1));
    %     prevTrialStart(it4) = find(round(fullData(1:(trialStart(it4)-1))) ~= prevTrialIdx, 1, 'last');
    %     prevTrialIdxList(it4) = prevTrialIdx;
    %   end
    %   sizeForward = max(trialEnd-trialStart);
    %   sizeBackward = max(trialStart-prevTrialStart);
    %   matForward = nan(length(trialStart), sizeForward);
    %   matBackward = nan(length(trialStart), sizeBackward);
    %   matForwardLicks = nan(length(trialStart), sizeForward);
    %   matBackwardLicks = nan(length(trialStart), sizeBackward);
    %   for it4 = 1:length(trialStart)
    %     matForward(it4, 1:length(trialStart(it4):trialEnd(it4))) = ~~fullData(trialStart(it4):trialEnd(it4));
    %     matBackward(it4, sizeBackward-length(prevTrialStart(it4):trialStart(it4)-1)+1:end) = ~~fullData(prevTrialStart(it4):trialStart(it4)-1);
    %     matForwardLicks(it4, 1:length(trialStart(it4):trialEnd(it4))) = ~~fullDataLicks(trialStart(it4):trialEnd(it4));
    %     matBackwardLicks(it4, sizeBackward-length(prevTrialStart(it4):trialStart(it4)-1)+1:end) = ~~fullDataLicks(prevTrialStart(it4):trialStart(it4)-1);
    %   end
    %   perFamilyTrial = [matBackward, matForward];
    %   perFamilyTrialLicks = [matBackwardLicks, matForwardLicks];
    %   perFramilyFrame = -sizeBackward:sizeForward;
    %   break;
    % end
    % Family split
    %break;
  end
  break;
end
unique(sample)
%%
figure;imagesc(perFramilyFrame,  1:length(prevTrialIdxList), perFamilyTrial);
set(gca,'YTick', 1:length(prevTrialIdxList));
set(gca,'YTickLabel', prevTrialIdxList);
%%
figure;imagesc(perFramilyFrame,  1:length(prevTrialIdxList), perFamilyTrialLicks);
set(gca,'YTick', 1:length(prevTrialIdxList));
set(gca,'YTickLabel', prevTrialIdxList);

%%
figure;
a = plot(fullData);
hold on;
b = plot(onlyLicks,'r.');
ylim([0 10]);
ylabel('Family label');
xlabel('frame');
legend('stim','licks');
title(sprintf('%s - %s', curAnimal, currSess));

%%

%%
fullCmatFA = [];
fullCmatHits = [];
texture = true;
for it1 = 1:length(animals)
  curAnimal = animals(it1).name;
  sessList = dir(fullfile(pwd, curFolder, curAnimal));
  sessList = sessList(~ismember({sessList.name},{'.','..'}));
  sessList = sessList(arrayfun(@(x)x.isdir==1,sessList));
  for it2 = 1:length(sessList)
    if(~strcmp(currSess, '1382489290'))
      continue;
    end
  %for it2 = 9
    currSess = sessList(it2).name;
    %files = dir(fullfile(pwd, curAnimal, currSess));
    licks = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'licks.csv'));
    stim = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'stim.csv'));
    rewards = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'rewards.csv'));
    %break;  
    Nstim = length(stim.image_name);
    family = zeros(size(stim.image_name));
    sample = zeros(size(stim.image_name));
    if(iscell(stim.image_name(1)))
      texture = true;
    else
      texture = false;
    end
    if(texture)
      for it3 = 1:Nstim
        A = sscanf(stim.image_name{it3},'%*[^0123456789]%d');
        family(it3) = A(1);
        sample(it3) = A(2);
      end
    else
       family = stim.orientation;
    end

    lastFamily = nan(length(licks.frame), 2);
    lastSample = nan(length(licks.frame), 2);
    lastT = nan(size(licks.frame));
    lastStim = nan(size(licks.frame));
    for it3 = 1:length(licks.frame)
      lastFrame = find(licks.frame(it3)-stim.frame > 0, 1, 'last');
      if(licks.frame(it3)<stim.frame(1) || licks.frame(it3) > stim.frame(end) || isempty(lastFrame) || licks.frame(it3)-stim.frame(lastFrame) > 40 || lastFrame == 1)
        continue;
      end
      lastFamily(it3, :) = [family(lastFrame) family(lastFrame-1)];
      lastSample(it3, :) = [sample(lastFrame) sample(lastFrame-1)];
      lastT(it3) = licks.frame(it3)-stim.frame(lastFrame);
      lastStim(it3) = stim.frame(lastFrame);
      if(licks.frame(it3) > stim.frame(end))
        break;
      end
    end
    [~, uniqueStims] = unique(lastStim);
    lastFamily = lastFamily(uniqueStims, :);
    lastSample = lastSample(uniqueStims, :);
    lastT = lastT(uniqueStims, :);
    valid = find(~isnan(lastT));
    lastFamily = lastFamily(valid, :);
    lastSample = lastSample(valid, :);
    if(~texture)
      lastFamily(lastFamily == 0) = 1;
      lastFamily(lastFamily == 90) = 2;
      lastFamily(lastFamily == 180) = 3;
      lastFamily(lastFamily == 270) = 4;
    end
    if(~texture || length(unique(lastSample(:))) > 1)
      continue;
    end
    lastT = lastT(valid, :);
    figure;
    hist(lastT);
    title(sprintf('%s - %s', curAnimal, currSess))
    familyPairs = [family(1:end-1) family(2:end)];
    maxHits = sum(diff(familyPairs')~=0);
    maxFA = sum(diff(familyPairs') == 0);
    [length(find(diff(lastFamily') ~= 0 & ~isnan(diff(lastFamily')))) sum(diff(lastFamily') == 0)]
    [length(find(diff(lastFamily') ~= 0 & ~isnan(diff(lastFamily')))) sum(diff(lastFamily') == 0)]./[maxHits maxFA]
    dataHits = lastFamily(find(diff(lastFamily') ~= 0 & ~isnan(diff(lastFamily'))),:);
    if(texture)
      CmatHits = zeros(15);
      CmatFA = zeros(15);
    else
      CmatHits = zeros(4);
      CmatFA = zeros(4);
    end
    for it3 = 1:size(dataHits,1)
      CmatHits(dataHits(it3,1),dataHits(it3,2)) = CmatHits(dataHits(it3,1),dataHits(it3,2)) + 1; 
    end
    dataFA = lastFamily(find(diff(lastFamily') == 0 & ~isnan(diff(lastFamily'))),:);
    for it3 = 1:size(dataFA,1)
      CmatFA(dataFA(it3,1),dataFA(it3,2)) = CmatFA(dataFA(it3,1),dataFA(it3,2)) + 1; 
    end
    figure;
    imagesc(CmatHits');
    xlabel('pre img');
    xlabel('post img');
    figure;
    imagesc(CmatFA');
    xlabel('pre img');
    xlabel('post img');
    figure;plot(sum(CmatFA),sum(CmatHits,2),'o');
    sum(CmatFA)
    xlabel('FA');
    ylabel('Hits');
    fullCmatFA = [fullCmatFA; CmatFA];
    fullCmatHits = [fullCmatHits; CmatHits];
    %break;
  end
  break;
end

%%
dataHits = lastFamily(find(diff(lastFamily') ~= 0 & ~isnan(diff(lastFamily'))),:);
if(texture)
  CmatHits = zeros(15);
  CmatFA = zeros(15);
else
  CmatHits = zeros(4);
  CmatFA = zeros(4);
end
for it1 = 1:size(dataHits,1)
  CmatHits(dataHits(it1,1),dataHits(it1,2)) = CmatHits(dataHits(it1,1),dataHits(it1,2)) + 1; 
end
dataFA = lastFamily(find(diff(lastFamily') == 0 & ~isnan(diff(lastFamily'))),:);
for it1 = 1:size(dataFA,1)
  CmatFA(dataFA(it1,1),dataFA(it1,2)) = CmatFA(dataFA(it1,1),dataFA(it1,2)) + 1; 
end
figure;
imagesc(CmatHits');
xlabel('pre img');
xlabel('post img');
figure;
imagesc(CmatFA');
xlabel('pre img');
xlabel('post img');
figure;plot(sum(CmatFA),sum(CmatHits,2),'o');
xlabel('FA');
ylabel('Hits');


%%
%before shift: 1382489290
%shift1 1: 1385516210
%shift2 1: 1385725364
%shift2 2: 1386438327

%targetSess = '1385058813';sessTitle = 'before shift (2 days)';
%targetSess = '1382489290';sessTitle = 'before shift (1 day)';
%targetSess = '1385516210';sessTitle = 'shift 1 (first day)';
%targetSess = '1385725364';sessTitle = 'shift 2 (first day)';
%targetSess = '1386438327';sessTitle = 'shift 2 (second day)';
%targetSess = '1386599970';sessTitle = 'shift 3 (first day)';
%targetSess = '1386759127';sessTitle = 'shift 3 (second day)';
%targetSess = '1387018448';sessTitle = 'shift 3 (third day)';
targetSess = '1387984805';sessTitle = 'shift 3 (4th day)';
%targetSess = '1388223195';sessTitle = 'sampled (1st day)';
%726772
%1385281520
%targetSess = '1383707790';sessTitle = 'before shift';
%targetSess = '1385515639';sessTitle = 'shift 1 (first day)';
%targetSess = '1385725362';sessTitle = 'shift 2 (first day)';
%targetSess = '1386432525';sessTitle = 'shift 2 (second day)';
%targetSess = '1386599966';sessTitle = 'shift 3 (first day)';
%targetSess = '1388933932';sessTitle = 'shift 3 (second day)';

confMatHR = cell(length(animals), 1);
sessType = cell(length(animals), 1);
texture = true;
%for it1 = 1:length(animals)
for it1 = 1
  curAnimal = animals(it1).name;
  sessList = dir(fullfile(pwd, curFolder, curAnimal));
  sessList = sessList(~ismember({sessList.name},{'.','..'}));
  sessList = sessList(arrayfun(@(x)x.isdir==1,sessList));
  confMatHR{it1} = cell(length(sessList), 1);
  confMatFA{it1} = cell(length(sessList), 1);
  sessType{it1} = nan(length(sessList), 1);
  %norminv(hit_rate) - norminv(fa_rate)
  for it2 = 1:length(sessList)
    currSess = sessList(it2).name;
    if(~strcmp(currSess, targetSess))
      continue;
    end
    licks = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'licks.csv'));
    stim = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'stim.csv'));
    rewards = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'rewards.csv'));
    Nstim = length(stim.image_name);
    family = zeros(size(stim.image_name));
    sample = zeros(size(stim.image_name));
    if(iscell(stim.image_name(1)))
      texture = true;
    else
      texture = false;
    end
    if(texture)
      for it3 = 1:Nstim
        A = sscanf(stim.image_name{it3},'%*[^0123456789]%d');
        family(it3) = A(1);
        sample(it3) = A(2);
      end
    else
       family = stim.orientation;
    end
    if(~texture)
      family(family == 0) = 1;
      family(family == 90) = 2;
      family(family == 180) = 3;
      family(family == 270) = 4;
    else
      family(family == 5) = 1;
      family(family == 6) = 2;
      family(family == 9) = 3;
      family(family == 11) = 4;
      family(family == 12) = 5;
      family(family == 13) = 6;
      family(family == 14) = 7;
      family(family == 15) = 8;
    end

    totalFrames = stim.end_frame(end);
    fullData = nan(totalFrames,1);
    
    
    for it3 = 1:size(stim,1)
      fullData(stim.frame(it3):stim.end_frame(it3)) = family(it3);
    end
    
    lastImg = nan;
    for it3 = 1:length(fullData)
      if(isnan(fullData(it3)))
        fullData(it3) = lastImg+0.02;
      else
        lastImg = fullData(it3);
      end
    end


    fullDataLicks = fullData;
    fullDataLicks(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = 0;
    onlyLicks = nan(size(fullData));
    onlyLicks(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = fullData(licks.frame(licks.frame <= length(fullData) & licks.frame > 0));
    onlyLicksHit = nan(size(fullData));
    %onlyLicksHit(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = fullData(licks.frame(licks.frame <= length(fullData) & licks.frame > 0));
    onlyLicksGrace = nan(size(fullData));
    rewData = nan(size(fullData));
    rewData(rewards.frame(rewards.frame <= length(fullData) & rewards.frame > 0)) = fullData(rewards.frame(rewards.frame <= length(fullData) & rewards.frame > 0));
    %onlyLicksGrace(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = fullData(licks.frame(licks.frame <= length(fullData) & licks.frame > 0));
    % Now look for all image changes
    invalid = isnan(fullData);
    frame = 1:length(fullData);
    

    familyList = unique(round(fullData(~isnan(fullData))));
    imgChange = find(abs(diff(fullData))>0.1)+1;
    confMat = zeros(length(familyList));
    confMatHits = zeros(length(familyList));
    confMatFApart = zeros(length(familyList), 1);
    confMatFApartHits = zeros(length(familyList), 1);
    familyLicksAfterChange = cell(length(familyList), 1);
    familyFullLicksAfterChange = cell(length(familyList), 1);
    familyFullLicksAfterChangeSurr = cell(length(familyList), 1);
    familyHits = zeros(length(familyList), 1);
    familyMiss = zeros(length(familyList), 1);
    for it3 = 1:length(familyList)
      familyFullLicksAfterChangeSurr{it3} = [];
    end
    for it3 = 1:length(familyList)
      trialStart = imgChange(find(round(fullData(imgChange)) == familyList(it3)));
      trialEnd = zeros(size(trialStart));
      prevTrialStart = zeros(size(trialStart));
      prevTrialIdxList = zeros(size(trialStart));
      familyLicksAfterChange{it3} = [];
      familyFullLicksAfterChange{it3} = [];
      for it4 = 1:length(trialStart)
          if(isempty(find(round(fullData(trialStart(it4):end)) ~= familyList(it3), 1, 'first')))
              trialEnd(it4) = length(fullData);
          else
            trialEnd(it4) = trialStart(it4)+find(round(fullData(trialStart(it4):end)) ~= familyList(it3), 1, 'first')-2;
          end
        prevTrialIdx = round(fullData(trialStart(it4)-1));
        if(isempty(find(round(fullData(1:(trialStart(it4)-1))) ~= prevTrialIdx, 1, 'last')))
            prevTrialStart(it4) = fullData(1);
        else
            prevTrialStart(it4) = find(round(fullData(1:(trialStart(it4)-1))) ~= prevTrialIdx, 1, 'last');
        end
        prevTrialIdxList(it4) = prevTrialIdx;
        confMat(prevTrialIdx, familyList(it3)) = confMat(prevTrialIdx, familyList(it3)) + 1;
        % 9 and 45
        trialLicks = licks.frame(licks.frame >= trialStart(it4)+9 & licks.frame <= trialStart(it4)+45);
        if(length(trialLicks) > 1)
          addGrace = trialLicks(2:end);
          trialLicks = trialLicks(1);
        else
          addGrace = [];
        end
        trialRewards = rewards.frame(rewards.frame >= trialStart(it4)+9 & rewards.frame <= trialStart(it4)+45);
        if(~isempty(trialRewards))
          familyHits(it3) = familyHits(it3) + 1;
          familyLicksAfterChange{it3} = [familyLicksAfterChange{it3}; trialRewards-trialStart(it4)];
          fullLicks = licks.frame(licks.frame >= trialStart(it4)+9 & licks.frame <= trialStart(it4)+245);
          familyFullLicksAfterChange{it3} = [familyFullLicksAfterChange{it3}; fullLicks-trialStart(it4)];
        else
          familyMiss(it3) = familyMiss(it3) + 1;
        end

        % Now the surrogate
        trialIdx = find(stim.frame == trialStart(it4));
        prevTrial = trialIdx - 6;
        if(prevTrial > 1)
          prevTrialFrame = stim.frame(prevTrial);
          prevTrialIdx = family(prevTrial);
          fullLicks = licks.frame(licks.frame >= prevTrialFrame+9 & licks.frame <= prevTrialFrame+245);
          familyFullLicksAfterChangeSurr{prevTrialIdx} = [familyFullLicksAfterChangeSurr{prevTrialIdx}; fullLicks-prevTrialFrame];
          if(family(prevTrial) ~= family(trialIdx))
              FAlicks = licks.frame(licks.frame >= prevTrialFrame+9 & licks.frame <= prevTrialFrame+45);
              if(~isempty(FAlicks))
                confMatFApart(family(prevTrial)) = confMatFApart(family(prevTrial)) + 1;
                confMatFApartHits(family(prevTrial)) = confMatFApartHits(family(prevTrial)) + 1;
              else
                confMatFApart(family(prevTrial)) = confMatFApart(family(prevTrial)) + 1;
              end
          end
        end

        % End of surrogate
        onlyLicksHit(trialLicks) = fullData(trialLicks);
        if(any(trialLicks))
            trialGraceLicks = licks.frame(licks.frame >= trialStart(it4)+45 & licks.frame <= trialStart(it4)+270);
            trialGraceLicks(trialGraceLicks > length(fullData)) = [];
            if(~isempty(addGrace))
              trialGraceLicks = [addGrace; trialGraceLicks];
            end
            onlyLicksGrace(trialGraceLicks) = fullData(trialGraceLicks);
        end
        if(~isempty(trialLicks))
            confMatHits(prevTrialIdx, familyList(it3)) = confMatHits(prevTrialIdx, familyList(it3)) + 1;
        end
      end
    end
    fullData(invalid) = [];
    fullDataLicks(invalid) = [];
    onlyLicks(invalid) = [];
    frame(invalid) = [];
    onlyLicksHit(invalid) = [];
    onlyLicksGrace(invalid) = [];
    rewData(invalid) = [];
    confMatHR{it1}{it2} = confMatHits./confMat;
    confMatFA{it1}{it2} = confMatFApartHits./confMatFApart;
    if(~texture)
        sessType{it1}(it2) = 0;
    else
        if(length(unique(sample)) == 1)
            sessType{it1}(it2) = 1;
        else
            sessType{it1}(it2) = 2;
        end
    end

    figure;
    frame = frame/60;
    %a = plot(frame, ~~fullData);
    a1 = plot(frame(1:end-1), abs(diff(fullData))>0.5);
    hold on;
    %b = plot(frame, onlyLicks,'r.');
    % b = plot(frame, onlyLicks,'r.');
    % b = plot(frame, onlyLicksHit,'mo','MarkerFaceColor','m');
    % b = plot(frame, onlyLicksGrace,'k.');
    % b = plot(frame, rewData,'bo','MarkerFaceColor','b');
    b = plot(frame, ~isnan(onlyLicks),'r.');
    b = plot(frame, ~isnan(onlyLicksHit),'mo','MarkerFaceColor','m');
    b = plot(frame, ~isnan(onlyLicksGrace),'k.');
    b = plot(frame, ~isnan(rewData),'bo','MarkerFaceColor','b');
    [sum(~isnan(onlyLicksHit)) sum(~isnan(rewData))]
    ylim([0 10]);
    ylabel('Family label');
    xlabel('frame');
    legend('stim','FA', 'Hits?', 'grace');
    title(sprintf('Ani: %s - Sess: %s (%s) - Samp: %d', curAnimal, currSess, sessTitle, length(unique(sample))));

    figure;
    a2 = plot(frame, fullData);
    %a = plot(frame(1:end-1), abs(diff(fullData))>0.5);
    hold on;
    newFamily = find(abs(diff(fullData))>0.5);
    %b = plot(frame(newFamily+1), fullData(newFamily+1),'go');
    b = plot(frame, onlyLicks,'r.');
    b = plot(frame, onlyLicks,'r.');
    b = plot(frame, onlyLicksHit,'mo','MarkerFaceColor','m');
    b = plot(frame, onlyLicksGrace,'k.');
    b = plot(frame, rewData,'bo','MarkerFaceColor','b');
    % b = plot(frame, ~isnan(onlyLicks),'r.');
    % b = plot(frame, ~isnan(onlyLicksHit),'mo','MarkerFaceColor','m');
    % b = plot(frame, ~isnan(onlyLicksGrace),'k.');
    % b = plot(frame, ~isnan(rewData),'bo','MarkerFaceColor','b');
    [sum(~isnan(onlyLicksHit)) sum(~isnan(rewData))]
    ylim([0 10]);
    ylabel('Family label');
    xlabel('frame');
    legend('stim','FA', 'Hits?', 'grace');
    title(sprintf('Ani: %s - Sess: %s (%s) - Samp: %d', curAnimal, currSess, sessTitle, length(unique(sample))));
    break;  
  end 
 % break;
end
unique(sample)
%xlim([10000 40000])

%%
binWidth = 0.25;
newFamily = find(abs(diff(fullData))>0.5);
lickFrames = find(~isnan(onlyLicks));
nextLick = nan(size(newFamily));
prevLick = nan(size(newFamily));
for it1 = 1:length(newFamily)
  if(~isempty(find(lickFrames>newFamily(it1),1,'first')))
    nextLick(it1) = lickFrames(find(lickFrames>newFamily(it1),1,'first'))-newFamily(it1);
  end
  if(~isempty(find(lickFrames<newFamily(it1),1,'last')))
    prevLick(it1) = newFamily(it1)-lickFrames(find(lickFrames<newFamily(it1),1,'last'));
  end
end


figure;
subplot(2, 1, 1);
histogram(nextLick/60,'BinWidth',binWidth);
hold on;
histogram(-prevLick/60,'BinWidth',binWidth);
xlim([-10 10]);
xlabel('time from lick (s)');
title('time from first/last lick before family change');
yl = ylim;
%

surrImgs = find(abs(diff(fullData))<0.5 & abs(diff(fullData))>0.01);
surrImgs = sort(surrImgs(randperm(length(surrImgs), length(newFamily))));
%surrImgs = newFamily+60*20;

lickFrames = find(~isnan(onlyLicks));
nextLick = nan(size(surrImgs));
prevLick = nan(size(surrImgs));
for it1 = 1:length(surrImgs)
  if(~isempty(find(lickFrames>surrImgs(it1),1,'first')))
    nextLick(it1) = lickFrames(find(lickFrames>surrImgs(it1),1,'first'))-surrImgs(it1);
  end
  if(~isempty(find(lickFrames<surrImgs(it1),1,'last')))
    prevLick(it1) = surrImgs(it1)-lickFrames(find(lickFrames<surrImgs(it1),1,'last'));
  end
end
title('time from first/last lick before same-family surrogate');

subplot(2, 1, 2);
histogram(nextLick/60,'BinWidth',binWidth);
hold on;
histogram(-prevLick/60,'BinWidth',binWidth);
xlim([-10 10]);
xlabel('time from lick (s)');
ylim(yl);
sgtitle(sprintf('Ani: %s - Sess: %s (%s)', curAnimal, currSess, sessTitle));

%%
figure;
a = plot(frame, fullData);
hold on;
b = plot(frame, onlyLicks,'g.');
b = plot(frame, onlyLicksHit,'ro');
b = plot(frame, onlyLicksGrace,'k.');
ylim([0 10]);
ylabel('Family label');
xlabel('frame');
legend('stim','licks');
title(sprintf('Ani: %s - Sess: %s - Samp: %d', curAnimal, currSess, length(unique(sample))));
%%
%confMatHR = cell(length(animals), 1);
%sessType = cell(length(animals), 1);
hitRatesGratings = zeros(4);
hitRatesTexture = zeros(8);
faRatesTexture = zeros(8,1);
hitRatesTexturesSamples = zeros(8);
faRatesTexturesSamples = zeros(8,1);

hitRatesGratingsN = 0;
hitRatesTextureN = 0;
faRatesTextureN = 0;
hitRatesTexturesSamplesN = 0;
faRatesTexturesSamplesN = 0;

for it1 = 1:size(confMatHR)
    lastGratings = find(sessType{it1}==0, 1, 'last');
    lastTextures = find(sessType{it1}==1, 1, 'last')-1;
    for it2 = lastGratings:size(confMatHR{it1})
        switch sessType{it1}(it2)
            case 0
                hitRatesGratings = hitRatesGratings + confMatHR{it1}{it2};
                hitRatesGratingsN = hitRatesGratingsN + 1;
            case 1
                if(it2 >= lastTextures)
                    hitRatesTexture = hitRatesTexture + confMatHR{it1}{it2};
                    hitRatesTextureN = hitRatesTextureN + 1;
                    faRatesTexture = faRatesTexture + confMatFA{it1}{it2};
                    faRatesTextureN = faRatesTextureN + 1;
                end
            case 2
                hitRatesTexturesSamples = hitRatesTexturesSamples + confMatHR{it1}{it2};
                hitRatesTexturesSamplesN = hitRatesTexturesSamplesN + 1;
                faRatesTexturesSamples = faRatesTexturesSamples + confMatFA{it1}{it2};
                faRatesTexturesSamplesN = faRatesTexturesSamplesN + 1;
        end
    end
end
hitRatesGratings = hitRatesGratings/hitRatesGratingsN;
hitRatesTexture = hitRatesTexture/hitRatesTextureN;
faRatesTexture = faRatesTexture/faRatesTextureN;
hitRatesTexturesSamples = hitRatesTexturesSamples/hitRatesTexturesSamplesN;
faRatesTexturesSamples = faRatesTexturesSamples/faRatesTexturesSamplesN;
%%
figure;
imagesc((hitRatesGratings+hitRatesGratings')/2)
%caxis([0 1])
xlabel('after change');
ylabel('before change');
colorbar;
set(gca,'XTick', 1:4);
set(gca,'YTick', 1:4);
set(gca,'XTickLabel', [0 90 180 270]);
set(gca,'YTickLabel', [0 90 180 270]);
title('Hit rates (last 2 sessions on protocol 2.5, avg across 4 animals)');
%%
figure;
%imagesc((hitRatesTexture+hitRatesTexture')/2)
imagesc((hitRatesTexture))
%caxis([0 1])
xlabel('after change');
ylabel('before change');
colorbar;
set(gca,'XTick', 1:8);
set(gca,'YTick', 1:8);
set(gca,'XTickLabel', [5 6 9 11 12 13 14 15]);
set(gca,'YTickLabel', [5 6 9 11 12 13 14 15]);
title('Hit rates (last 2 sessions on protocol 2.5, avg across 4 animals)');

%%
figure;
imagesc((faRatesTexture))
%caxis([0 1])
xlabel('after change');
ylabel('before change');
colorbar;
set(gca,'XTick', 1:8);
set(gca,'YTick', 1:8);
set(gca,'XTickLabel', [5 6 9 11 12 13 14 15]);
set(gca,'YTickLabel', [5 6 9 11 12 13 14 15]);
title('Hit rates (last 2 sessions on protocol 2.5, avg across 4 animals)');
%%

hitRatesTexture(isnan(hitRatesTexture)) = 0;
fullMat = hitRatesTexture+diag(faRatesTexture);
figure;
imagesc((fullMat))
%caxis([0 1])
xlabel('after change');
ylabel('before change');
colorbar;
set(gca,'XTick', 1:8);
set(gca,'YTick', 1:8);
set(gca,'XTickLabel', [5 6 9 11 12 13 14 15]);
set(gca,'YTickLabel', [5 6 9 11 12 13 14 15]);
title('HR and FA (last 2 sessions on protocol 2.5, avg across 4 animals)');

%%
fullMat = nan(size(hitRatesTexture));
for it1 = 1:length(fullMat)
    for it2 = 1:length(fullMat)
        if(it1 == it2)
            continue;
        end
        [dpri,ccrit] = dprime(hitRatesTexture(it1, it2), faRatesTexture(it1));
        fullMat(it1, it2) = dpri;
    end
end
figure;
imagesc((fullMat>1.2))
%caxis([0 1])
xlabel('after change');
ylabel('before change');
colorbar;
set(gca,'XTick', 1:8);
set(gca,'YTick', 1:8);
set(gca,'XTickLabel', [5 6 9 11 12 13 14 15]);
set(gca,'YTickLabel', [5 6 9 11 12 13 14 15]);
title('D prime (last 2 sessions on protocol 2.5, avg across 4 animals)');
%% Now for samples

figure;
imagesc((hitRatesTexturesSamples))
%caxis([0 1])
xlabel('after change');
ylabel('before change');
colorbar;
set(gca,'XTick', 1:8);
set(gca,'YTick', 1:8);
set(gca,'XTickLabel', [5 6 9 11 12 13 14 15]);
set(gca,'YTickLabel', [5 6 9 11 12 13 14 15]);
title('HR (last 2 sessions on protocol 3, avg across 4 animals)');


%% Now for samples
fullMat = nan(size(hitRatesTexturesSamples));
for it1 = 1:length(fullMat)
    for it2 = 1:length(fullMat)
        if(it1 == it2)
            continue;
        end
        [dpri,ccrit] = dprime(hitRatesTexturesSamples(it1, it2), faRatesTexturesSamples(it1));
        fullMat(it1, it2) = dpri;
    end
end
figure;
imagesc(fullMat)
%caxis([0 1])
xlabel('after change');
ylabel('before change');
colorbar;
set(gca,'XTick', 1:8);
set(gca,'YTick', 1:8);
set(gca,'XTickLabel', [5 6 9 11 12 13 14 15]);
set(gca,'YTickLabel', [5 6 9 11 12 13 14 15]);
title('D prime (last 2 sessions on protocol 2.5, avg across 4 animals)');

%%
figure;
imagesc(hitRatesTexture-hitRatesTexture')
%caxis([-1 1])
xlabel('after change texture');
ylabel('before change texture');
colorbar;
set(gca,'XTick', 1:8);
set(gca,'YTick', 1:8);
set(gca,'XTickLabel', [5 6 9 11 12 13 14 15]);
set(gca,'YTickLabel', [5 6 9 11 12 13 14 15]);
title('Hit rates (last 2 sessions on protocol 2.5, avg across 4 animals)');
%%
%A = readtable('C:\Users\orlandi\Downloads\table.csv');
r = readtable('C:\Users\orlandi\Downloads\tablerewards.csv');
l = readtable('C:\Users\orlandi\Downloads\tablelicks.csv');
trials = readtable(['C:\Users\orlandi\Downloads\tabletrials.csv']);
%%
B = zeros(size(A.is_change));
%sf = zeros(size(A.is_change));
sf = A.start_time;
B(cellfun(@(x)x(1),A.is_change)=='T') = 1;
B(cellfun(@(x)x(1),A.is_change)=='F') = 0;
C(cellfun(@(x)x(1),A.is_sham_change)=='T') = 1;
C(cellfun(@(x)x(1),A.is_sham_change)=='F') = 0;
%%

figure;
hold on;
plot(sf,B,'.')
plot(sf,C*1.5,'.')
plot(r.timestamps,2*ones(size(r.timestamps)),'.')
plot(l.timestamps,2.5*ones(size(l.timestamps)),'.');
xlim([550 650])
%xlim([1000 1100]);
ylim([0.5 3]);
legend('GO','CATCH','rewards','licks')
%%
figure;
plot(A.flashes_since_change,'.')
xlim([550 650])
ylabel('flashes since change');
%%
figure;
plot(sf+6, A.trials_id,'.');
hold on;
xlim([550 650]-0)
ylabel('trial id');
yl = ylim;
h3 = plot([r.timestamps r.timestamps]', [ones(size(r.timestamps))*yl(1) ones(size(r.timestamps))*yl(2)]','-k','LineWidth',1);
h4 = plot([l.timestamps l.timestamps]', [ones(size(l.timestamps))*((yl(2)-yl(1))*0.85+yl(1)) ones(size(l.timestamps))*yl(2)]','-g');
GO = find(B);
h1 = plot([sf(GO) sf(GO)]', [ones(size(GO))*yl(1) ones(size(GO))*yl(2)]','r');
CATCH = find(C)';
h2 = plot([sf(CATCH) sf(CATCH)]', [ones(size(CATCH))*yl(1) ones(size(CATCH))*yl(2)]','b');
%legend([h1 h2 h3 h4],{'GO','CATCH','rewards','licks'});
%
%%
figure;
plot(sf, A.flashes_since_change,'.')
xlim([550 650]-0)
ylabel('flashes since change');
hold on;
yl = ylim;
h3 = plot([r.timestamps r.timestamps]', [ones(size(r.timestamps))*yl(1) ones(size(r.timestamps))*yl(2)]','-k','LineWidth',1);
h4 = plot([l.timestamps l.timestamps]', [ones(size(l.timestamps))*((yl(2)-yl(1))*0.85+yl(1)) ones(size(l.timestamps))*yl(2)]','-g');
GO = find(B);
h1 = plot([sf(GO) sf(GO)]', [ones(size(GO))*yl(1) ones(size(GO))*yl(2)]','r');
CATCH = find(C)';
h2 = plot([sf(CATCH) sf(CATCH)]', [ones(size(CATCH))*yl(1) ones(size(CATCH))*yl(2)]','b');
%legend([h1 h2 h3 h4],{'GO','CATCH','rewards','licks'});

%%
curFolder = 'textures240910/';
animals = dir(fullfile(pwd,curFolder));
animals=animals(~ismember({animals.name},{'.','..'}));
animals=animals(arrayfun(@(x)x.isdir==1,animals));


%% Getting the stats for the slack plots

%before shift: 1382489290
%shift1 1: 1385516210
%shift2 1: 1385725364
%shift2 2: 1386438327

%targetSess = '1385058813';sessTitle = 'before shift (2 days)'; % This is 52
%targetSess = '1382489290';sessTitle = 'before shift (1 day)';
%targetSess = '1385516210';sessTitle = 'shift 1 (first day)';
%targetSess = '1385725364';sessTitle = 'shift 2 (first day)';
%targetSess = '1386438327';sessTitle = 'shift 2 (second day)';
%targetSess = '1386599970';sessTitle = 'shift 3 (first day)';
targetSess = '1386759127';sessTitle = 'shift 3 (second day)';
%targetSess = '1387018448';sessTitle = 'shift 3 (third day)';
%targetSess = '1387984805';sessTitle = 'shift 3 (4th day)';
%targetSess = '1388223195';sessTitle = 'samples (1st day)';
%targetSess = '1388459115';sessTitle = 'samples (2nd day)';
%targetSess = '1388690459';sessTitle = 'samples (3rd day)';
%726772
%1385281520
%targetSess = '1383707790';sessTitle = 'before shift';
%targetSess = '1385515639';sessTitle = 'shift 1 (first day)';
%targetSess = '1385725362';sessTitle = 'shift 2 (first day)';
%targetSess = '1386432525';sessTitle = 'shift 2 (second day)';
%targetSess = '1386599966';sessTitle = 'shift 3 (first day)';
%targetSess = '1388933932';sessTitle = 'shift 3 (second day)';

confMatHR = cell(length(animals), 1);
sessType = cell(length(animals), 1);
texture = true;
%for it1 = 1:length(animals)
for it1 = 1
  curAnimal = animals(it1).name;
  sessList = dir(fullfile(pwd, curFolder, curAnimal));
  sessList = sessList(~ismember({sessList.name},{'.','..'}));
  sessList = sessList(arrayfun(@(x)x.isdir==1,sessList));
  confMatHR{it1} = cell(length(sessList), 1);
  confMatFA{it1} = cell(length(sessList), 1);
  sessType{it1} = nan(length(sessList), 1);
  %norminv(hit_rate) - norminv(fa_rate)
  for it2 = 1:length(sessList)
    currSess = sessList(it2).name;
    if(~strcmp(currSess, targetSess))
      continue;
    end
    
    licks = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'licks.csv'));
    stim = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'stim.csv'));
    rewards = readtable(fullfile(pwd, curFolder, curAnimal, currSess, 'rewards.csv'));
    Nstim = length(stim.image_name);
    family = zeros(size(stim.image_name));
    sample = zeros(size(stim.image_name));
    if(iscell(stim.image_name(1)))
      texture = true;
    else
      texture = false;
    end
    if(texture)
      for it3 = 1:Nstim
        A = sscanf(stim.image_name{it3},'%*[^0123456789]%d');
        family(it3) = A(1);
        sample(it3) = A(2);
      end
    else
       family = stim.orientation;
    end
    if(~texture)
      family(family == 0) = 1;
      family(family == 90) = 2;
      family(family == 180) = 3;
      family(family == 270) = 4;
    else
      family(family == 5) = 1;
      family(family == 6) = 2;
      family(family == 9) = 3;
      family(family == 11) = 4;
      family(family == 12) = 5;
      family(family == 13) = 6;
      family(family == 14) = 7;
      family(family == 15) = 8;
    end

    totalFrames = stim.end_frame(end);
    fullData = nan(totalFrames,1);
    
    
    for it3 = 1:size(stim,1)
      fullData(stim.frame(it3):stim.end_frame(it3)) = family(it3);
    end
    
    lastImg = nan;
    for it3 = 1:length(fullData)
      if(isnan(fullData(it3)))
        fullData(it3) = lastImg+0.02;
      else
        lastImg = fullData(it3);
      end
    end


    fullDataLicks = fullData;
    fullDataLicks(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = 0;
    onlyLicks = nan(size(fullData));
    onlyLicks(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = fullData(licks.frame(licks.frame <= length(fullData) & licks.frame > 0));
    onlyLicksHit = nan(size(fullData));
    %onlyLicksHit(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = fullData(licks.frame(licks.frame <= length(fullData) & licks.frame > 0));
    onlyLicksGrace = nan(size(fullData));
    rewData = nan(size(fullData));
    rewData(rewards.frame(rewards.frame <= length(fullData) & rewards.frame > 0)) = fullData(rewards.frame(rewards.frame <= length(fullData) & rewards.frame > 0));
    %onlyLicksGrace(licks.frame(licks.frame <= length(fullData) & licks.frame > 0)) = fullData(licks.frame(licks.frame <= length(fullData) & licks.frame > 0));
    % Now look for all image changes
    invalid = isnan(fullData);
    frame = 1:length(fullData);
    

    familyList = unique(round(fullData(~isnan(fullData))));
    imgChange = find(abs(diff(fullData))>0.1)+1;
    confMat = zeros(length(familyList));
    confMatHits = zeros(length(familyList));
    confMatFApart = zeros(length(familyList), 1);
    confMatFApartHits = zeros(length(familyList), 1);
    familyLicksAfterChange = cell(length(familyList), 1);
    familyFullLicksAfterChange = cell(length(familyList), 1);
    familyFullLicksAfterChangeSurr = cell(length(familyList), 1);
    familyHits = zeros(length(familyList), 1);
    familyMiss = zeros(length(familyList), 1);
    for it3 = 1:length(familyList)
      familyFullLicksAfterChangeSurr{it3} = [];
    end
    for it3 = 1:length(familyList)
      trialStart = imgChange(find(round(fullData(imgChange)) == familyList(it3)));
      trialEnd = zeros(size(trialStart));
      prevTrialStart = zeros(size(trialStart));
      prevTrialIdxList = zeros(size(trialStart));
      familyLicksAfterChange{it3} = [];
      familyFullLicksAfterChange{it3} = [];
      for it4 = 1:length(trialStart)
          if(isempty(find(round(fullData(trialStart(it4):end)) ~= familyList(it3), 1, 'first')))
              trialEnd(it4) = length(fullData);
          else
            trialEnd(it4) = trialStart(it4)+find(round(fullData(trialStart(it4):end)) ~= familyList(it3), 1, 'first')-2;
          end
        prevTrialIdx = round(fullData(trialStart(it4)-1));
        if(isempty(find(round(fullData(1:(trialStart(it4)-1))) ~= prevTrialIdx, 1, 'last')))
            prevTrialStart(it4) = fullData(1);
        else
            prevTrialStart(it4) = find(round(fullData(1:(trialStart(it4)-1))) ~= prevTrialIdx, 1, 'last');
        end
        prevTrialIdxList(it4) = prevTrialIdx;
        confMat(prevTrialIdx, familyList(it3)) = confMat(prevTrialIdx, familyList(it3)) + 1;
        % 9 and 45
        trialLicks = licks.frame(licks.frame >= trialStart(it4)+9 & licks.frame <= trialStart(it4)+45);
        if(length(trialLicks) > 1)
          addGrace = trialLicks(2:end);
          trialLicks = trialLicks(1);
        else
          addGrace = [];
        end
        trialRewards = rewards.frame(rewards.frame >= trialStart(it4)+9 & rewards.frame <= trialStart(it4)+45);
        if(~isempty(trialRewards))
          familyHits(it3) = familyHits(it3) + 1;
          familyLicksAfterChange{it3} = [familyLicksAfterChange{it3}; trialRewards-trialStart(it4)];
          fullLicks = licks.frame(licks.frame >= trialStart(it4)+9 & licks.frame <= trialStart(it4)+245);
          familyFullLicksAfterChange{it3} = [familyFullLicksAfterChange{it3}; fullLicks-trialStart(it4)];
        else
          familyMiss(it3) = familyMiss(it3) + 1;
        end

        % Now the surrogate
        trialIdx = find(stim.frame == trialStart(it4));
        prevTrial = trialIdx - 6;
        if(prevTrial > 1)
          prevTrialFrame = stim.frame(prevTrial);
          prevTrialIdx = family(prevTrial);
          fullLicks = licks.frame(licks.frame >= prevTrialFrame+9 & licks.frame <= prevTrialFrame+245);
          familyFullLicksAfterChangeSurr{prevTrialIdx} = [familyFullLicksAfterChangeSurr{prevTrialIdx}; fullLicks-prevTrialFrame];
          if(family(prevTrial) ~= family(trialIdx))
              FAlicks = licks.frame(licks.frame >= prevTrialFrame+9 & licks.frame <= prevTrialFrame+45);
              if(~isempty(FAlicks))
                confMatFApart(family(prevTrial)) = confMatFApart(family(prevTrial)) + 1;
                confMatFApartHits(family(prevTrial)) = confMatFApartHits(family(prevTrial)) + 1;
              else
                confMatFApart(family(prevTrial)) = confMatFApart(family(prevTrial)) + 1;
              end
          end
        end

        % End of surrogate
        onlyLicksHit(trialLicks) = fullData(trialLicks);
        if(any(trialLicks))
            trialGraceLicks = licks.frame(licks.frame >= trialStart(it4)+45 & licks.frame <= trialStart(it4)+270);
            trialGraceLicks(trialGraceLicks > length(fullData)) = [];
            if(~isempty(addGrace))
              trialGraceLicks = [addGrace; trialGraceLicks];
            end
            onlyLicksGrace(trialGraceLicks) = fullData(trialGraceLicks);
        end
        if(~isempty(trialLicks))
            confMatHits(prevTrialIdx, familyList(it3)) = confMatHits(prevTrialIdx, familyList(it3)) + 1;
        end
      end
    end
    fullData(invalid) = [];
    fullDataLicks(invalid) = [];
    onlyLicks(invalid) = [];
    frame(invalid) = [];
    onlyLicksHit(invalid) = [];
    onlyLicksGrace(invalid) = [];
    rewData(invalid) = [];
    confMatHR{it1}{it2} = confMatHits./confMat;
    confMatFA{it1}{it2} = confMatFApartHits./confMatFApart;
    if(~texture)
        sessType{it1}(it2) = 0;
    else
        if(length(unique(sample)) == 1)
            sessType{it1}(it2) = 1;
        else
            sessType{it1}(it2) = 2;
        end
    end

    % figure;
    % frame = frame/60;
    % %a = plot(frame, ~~fullData);
    % a1 = plot(frame(1:end-1), abs(diff(fullData))>0.5);
    % hold on;
    % %b = plot(frame, onlyLicks,'r.');
    % % b = plot(frame, onlyLicks,'r.');
    % % b = plot(frame, onlyLicksHit,'mo','MarkerFaceColor','m');
    % % b = plot(frame, onlyLicksGrace,'k.');
    % % b = plot(frame, rewData,'bo','MarkerFaceColor','b');
    % b = plot(frame, ~isnan(onlyLicks),'r.');
    % b = plot(frame, ~isnan(onlyLicksHit),'mo','MarkerFaceColor','m');
    % b = plot(frame, ~isnan(onlyLicksGrace),'k.');
    % b = plot(frame, ~isnan(rewData),'bo','MarkerFaceColor','b');
    % [sum(~isnan(onlyLicksHit)) sum(~isnan(rewData))]
    % ylim([0 10]);
    % ylabel('Family label');
    % xlabel('frame');
    % legend('stim','FA', 'Hits?', 'grace');
    % title(sprintf('Ani: %s - Sess: %s (%s) - Samp: %d', curAnimal, currSess, sessTitle, length(unique(sample))));

    figure;
    a2 = plot(frame, fullData);
    %a = plot(frame(1:end-1), abs(diff(fullData))>0.5);
    hold on;
    newFamily = find(abs(diff(fullData))>0.5);
    %b = plot(frame(newFamily+1), fullData(newFamily+1),'go');
    b = plot(frame, onlyLicks,'r.');
    b = plot(frame, onlyLicksHit,'mo','MarkerFaceColor','k');
    %b = plot(frame, onlyLicksGrace,'k.');
    %b = plot(frame, rewData,'bo','MarkerFaceColor','b');
    % b = plot(frame, ~isnan(onlyLicks),'r.');
    % b = plot(frame, ~isnan(onlyLicksHit),'mo','MarkerFaceColor','m');
    % b = plot(frame, ~isnan(onlyLicksGrace),'k.');
    % b = plot(frame, ~isnan(rewData),'bo','MarkerFaceColor','b');
    [sum(~isnan(onlyLicksHit)) sum(~isnan(rewData))]
    ylim([0 10]);
    ylabel('Family label');
    xlabel('frame');
    %legend('stim','FA', 'Hits', 'grace');
    legend('stim','FA', 'Hits');
    title(sprintf('Ani: %s - Sess: %s (%s) - Samp: %d', curAnimal, currSess, sessTitle, length(unique(sample))));

    binWidth = 0.25;
    newFamily = find(abs(diff(fullData))>0.5);
    lickFrames = find(~isnan(onlyLicks));
    nextLick = nan(size(newFamily));
    prevLick = nan(size(newFamily));
    for it1 = 1:length(newFamily)
      if(~isempty(find(lickFrames>newFamily(it1),1,'first')))
        nextLick(it1) = lickFrames(find(lickFrames>newFamily(it1),1,'first'))-newFamily(it1);
      end
      if(~isempty(find(lickFrames<newFamily(it1),1,'last')))
        prevLick(it1) = newFamily(it1)-lickFrames(find(lickFrames<newFamily(it1),1,'last'));
      end
    end
    
    
    figure;
    subplot(2, 1, 1);
    histogram(nextLick/60,'BinWidth',binWidth);
    hold on;
    histogram(-prevLick/60,'BinWidth',binWidth);
    xlim([-10 10]);
    xlabel('time from lick (s)');
    title('time from first/last lick before family change');
    yl = ylim;
    %
    
    surrImgs = find(abs(diff(fullData))<0.5 & abs(diff(fullData))>0.01);
    surrImgs = sort(surrImgs(randperm(length(surrImgs), length(newFamily))));
    %surrImgs = newFamily+60*20;
    
    lickFrames = find(~isnan(onlyLicks));
    nextLick = nan(size(surrImgs));
    prevLick = nan(size(surrImgs));
    for it1 = 1:length(surrImgs)
      if(~isempty(find(lickFrames>surrImgs(it1),1,'first')))
        nextLick(it1) = lickFrames(find(lickFrames>surrImgs(it1),1,'first'))-surrImgs(it1);
      end
      if(~isempty(find(lickFrames<surrImgs(it1),1,'last')))
        prevLick(it1) = surrImgs(it1)-lickFrames(find(lickFrames<surrImgs(it1),1,'last'));
      end
    end
    
    subplot(2, 1, 2);
    histogram(nextLick/60,'BinWidth',binWidth);
    hold on;
    histogram(-prevLick/60,'BinWidth',binWidth);
    xlim([-10 10]);
    xlabel('time from lick (s)');
    ylim(yl);
    title('time from first/last lick before same-family surrogate');

    sgtitle(sprintf('Ani: %s - Sess: %s (%s)', curAnimal, currSess, sessTitle));
  
    break;
  end 
 % break;
end
unique(sample)
%xlim([10000 40000])

%%
 lickFrames = find(~isnan(onlyLicks));
 hitFrames = find(~isnan(onlyLicksHit));
    hitGrace = find(~isnan(onlyLicksGrace));
faFrames = setxor(lickFrames,hitGrace);
%faFrames = faFrames(1:350);
figure;
%hist(diff(faFrames)/60,0:0.1:10);
hist(diff(faFrames)/60,0:0.1:100);
xlabel('time between consecutive FA and aborts (s)');
ylabel('hits');
title(sprintf('Ani: %s - Sess: %s (%s)', curAnimal, currSess, sessTitle));
xlim([0 60]);