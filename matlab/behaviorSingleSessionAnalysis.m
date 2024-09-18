%% Single session statistics

% Data folder structure: curFolder / animalName / sessionName / (licks.csv, stim.csv, rewards.csv)

curFolder = 'textures240910/';
animals = dir(fullfile(pwd,curFolder));
animals=animals(~ismember({animals.name},{'.','..'}));
animals=animals(arrayfun(@(x)x.isdir==1,animals));


%% Getting the stats for the slack plots

targetAnimal = '726769';


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
for it1 = 1:length(animals)
  if(~strcmp(animals(it1).name, targetAnimal))
    continue;
  end
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
    % If not texture, the families are the gratings ,label them 1 to 4
    % If texture, label them sequentially from the original list
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