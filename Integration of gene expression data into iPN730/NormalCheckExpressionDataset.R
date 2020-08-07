library(plyr)
library(tidyselect)

setwd('/Users/amit/Desktop/Mac/ScientificReports/SecondRevisionFiles/Codes')

expression_array=read.csv('GSE48135.txt',sep='\t')
idmap=read.csv('UniversalIDmap.csv')

colnames(expression_array)[1]='ID'

expr=join(idmap,expression_array,type='left')

boxplot(expr[,5:20])

summary(expr[,5:20])

df = subset(expr, select = -c(X,YeastID))

write.csv(df,'GeneExpressionNitrogenSources.csv')
