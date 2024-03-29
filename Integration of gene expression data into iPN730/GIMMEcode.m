%Integration of Gene Expression Data into Lachancea kluyveri model

%initCobraToolbox()

cd /Users/amit/Desktop/Mac/ScientificReports/SecondRevisionFiles/Codes

%model=readCbModel('iPN730_etac')

modelamm=model;

modelura=changeRxnBounds(model,'EX_cpd00092_e0',-1000,'l')
modelura=changeRxnBounds(modelura,'EX_cpd19013_e0',0,'l')

cd /Users/amit/Desktop/Mac/ScientificReports/SecondRevisionFiles/Codes
expr=readtable('GeneExpressionNitrogenSources.csv')

names=table2array(expr(:,2))
names=extractBetween(names,2,15)

expressionData_Ura.gene=names
expressionData_Amm.gene=names

geneExpr_Ura=str2double(table2array(expr(:,4:7)))
geneExpr_Amm=str2double(table2array(expr(:,16:19)))

expressionData_Ura.value=mean(geneExpr_Ura,2)
expressionData_Amm.value=mean(geneExpr_Amm,2)

[expressionRxns_Ura, parsedGPR_Ura] = mapExpressionToReactions(modelura, expressionData_Ura)
[expressionRxns_Amm, parsedGPR_Amm] = mapExpressionToReactions(modelamm, expressionData_Amm)

p = 0:0.05:1;
y1 = quantile(expressionRxns_Ura,p);
z_i = [p;y1]

p = 0:0.05:1;
y1 = quantile(expressionRxns_Amm,p);
z_i = [p;y1]

subplot(1,2,1)
hist(expressionRxns_Ura,50)
subplot(1,2,2)
boxplot(expressionRxns_Ura)

subplot(1,2,1)
hist(expressionRxns_Amm,50)
subplot(1,2,2)
boxplot(expressionRxns_Amm)

modelura=changeRxnBounds(modelura,'EX_cpd00007_e0',-2,'l')
modelamm=changeRxnBounds(modelamm,'EX_cpd00007_e0',-2,'l')

CSM_Ura = GIMME(modelura, expressionRxns_Ura, -0.4458)
CSM_Amm = GIMME(modelamm, expressionRxns_Amm, -0.4417)

[minamm, maxamm]=fluxVariability(CSM_Amm,95,'max',CSM_Amm.rxns,0,false)
[minura, maxura]=fluxVariability(CSM_Ura,95,'max',CSM_Ura.rxns,0,false)


FluxUI=table(CSM_Amm.rxns,minamm,maxamm,'VariableNames',{'Reactions','minamm','maxamm'})
FluxI=table(CSM_Ura.rxns,minura,maxura,'VariableNames',{'Reactions','minura','maxura'})

merged_fluxes=innerjoin(FluxUI,FluxI)

minFlux=table2array(merged_fluxes(:,[2,4]))
maxFlux=table2array(merged_fluxes(:,[3,5]))

J=fvaJaccardIndex(minFlux,maxFlux)

merged_fluxes.Jaccard=J

enriched_rxns=merged_fluxes(merged_fluxes.Jaccard==0,:)

% writetable(enriched_rxns,'EnrichedReactionsFluxRange.csv')

enrxn_id=CSM_Ura.rxns(ismember(CSM_Ura.rxns,enriched_rxns.Reactions))
enrxn_name=CSM_Ura.rxnNames(ismember(CSM_Ura.rxns,enriched_rxns.Reactions))

writetable(table(enrxn_id,enrxn_name),'Enriched_LooplessFVA.csv')

