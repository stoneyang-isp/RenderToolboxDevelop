function MakeBlobbyObject()
    
    [scriptDir,~,~] = fileparts(which(mfilename));
    cd(scriptDir);
    cd .. 
    rootDir = pwd;
    tmpDir  = sprintf('%s/tmpstuff',rootDir);
    if (~isdir(tmpDir))
       mkdir(tmpDir) 
    end
    resourceDir = ''; % sprintf('%s/RT3scripts/Resources', rootDir);
    mappingsFile = sprintf('%s/Mappings/AreaLights_DirectLights.txt', scriptDir);
    
    % Choose batch renderer options.
    hints.whichConditions = [];
    hints.imageWidth  = 1920; % 1024*2; %320;   % 1024; % 320*2; %1000;
    hints.imageHeight = 1920; % 876*2; % 240;  % 768;% 240*2; %750;
    hints.recipeName = '';
    hints.renderer = 'Mitsuba';
    hints.resources  = resourceDir;
    hints.workingFolder = rootDir;
    ChangeToWorkingFolder(hints);
    
    % Display renderer output (warnings, progress, etc.), live in Command Window
    hints.isCaptureCommandResults = false;

    % Tone mapping settings for tiff image
    toneMapFactor = 5.0;
    isScale = true;
    
    % Collada files to examine.
    blobbieSceneNames = {...
        'Blobbie_LargeAreaLamps' ...
        };
    
    % Scene illuminants to examine. Specified in pairs: {1} = AreaLightIlluminant {2}: PointLightIluminant
    examinedSceneIlluminants = {...
                           %    {'NeutralDay-Gray_0_0', 'NeutralDay'}, ...  % point lights
                                {'NeutralDay', 'NeutralDay-Gray_0_0'} ...   % area lights
                               };
    
    % Blobbie reflectance functions to examine.                       
    examinedObjReflectances  = {...
                                 {'NeutralDay-AcquaGreenMix_0.80', 'NeutralDay-AcquaGreenMix_0.80_scaleFactor_0.40'},...
                               %  {'NeutralDay-Acqua_1.0', 'NeutralDay-Acqua_0.4'} ...            %
                                };
        
    % Blobbie alphas to examine.
    examinedMaterialAlphas   = [0.01]; % [0.01 0.03 0.1 0.3]; 
    
    
    % Generate conditionKeys and Values
    conditionKeys = {'imageName', ...
                    'sceneAreaLightIlluminantSPD', ...
                    'scenePointLightIlluminantSPD', ...
                    'objDiffuseReflectanceSPD',  ...
                    'objSpecularReflectanceSPD', ...
                    'objMaterialAlpha'};
                
    conditionValues = {};
    
    conditionsNum = 0;
    for sceneIndex = 1:numel(blobbieSceneNames)  
        for sceneIlluminantIndex = 1:numel(examinedSceneIlluminants)
            for objReflectanceIndex = 1:numel(examinedObjReflectances)
                for materialAlphaIndex = 1:length(examinedMaterialAlphas)

                    conditionsNum = conditionsNum + 1;
                
                    % Select scene file
                    sceneNames{conditionsNum} = blobbieSceneNames{sceneIndex};
                
                    newCondition = { ...
                            sprintf('%s__sceneNo_%d', blobbieSceneNames{conditionsNum}, conditionsNum),  ...    
                            sprintf('%s.spd', examinedSceneIlluminants{sceneIlluminantIndex}{1}), ...            
                            sprintf('%s.spd', examinedSceneIlluminants{sceneIlluminantIndex}{2}), ...
                            sprintf('%s.spd', examinedObjReflectances{objReflectanceIndex}{1}), ...             
                            sprintf('%s.spd', examinedObjReflectances{objReflectanceIndex}{2}), ...              
                            sprintf('%f', examinedMaterialAlphas(materialAlphaIndex)) ...                        
                        };
                    conditionValues = [ conditionValues; newCondition];
                end % materialAlphaIndex
            end % objReflectanceIndex
        end % sceneIlluminantIndex
    end % sceneIndex


   for condIndex = 1:conditionsNum  
  
        % Get collada file
        sceneName = sceneNames{condIndex};
        colladaFile = sprintf('%s/ColladaExports/%s.dae', rootDir, sceneName);
            
        % Get  condition values
        theConditionValues = conditionValues(condIndex,:);
        fprintf('- - - - - - - - - Now rendering condition: %d/%d (''%s'')  - - - - - - - - -\n', condIndex, conditionsNum, char(theConditionValues{1}));
        theConditionValues
        fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n');
            
        % Write conditions file
        conditionsFile    = WriteConditionsFile('conditions_tmp.txt', conditionKeys, theConditionValues);
            
        nativeSceneFiles  = MakeSceneFiles(colladaFile, conditionsFile, mappingsFile, hints);
        radianceDataFiles = BatchRender(nativeSceneFiles, hints);
   
        montageFile = [theConditionValues{1} '.tiff'];
        
        [SRGBMontage, XYZMontage] = MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
        
        message = sprintf('\nFinished with condition %d.', condIndex);
        fprintf('%s\n', message);
        Speak(message);
        
    end % condIndex
        
    
    message = sprintf('\nFinished with all conditions.');
    fprintf('%s\n', message);
    Speak(message);
        
    % Remove unnecessary stuff
    cd(rootDir);
    system('rm -r -f *.log');
    system('rm conditions_tmp.txt');
    system('rm -r -f renderings');
    system('rm -r -f scenes');
    system('rm -r -f temp');
    system('rm -r -f textures');
end
