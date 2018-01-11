library(data.table)
library(ggplot2)
library(rattle)
library(caret)
library(caretEnsemble)
library(parallel)
library(doParallel)

##sampling
modNames <- unique(modelLookup()[modelLookup()$forClass,c(1)])

# Ensemble method
cluster <- makePSOCKcluster(detectCores() - 1)
registerDoParallel(cluster)
algorithmList <- c("vglmAdjCat", "lda", "mda", 'qda', "J48", "PART", "treebag",
                   "rda", "nnet", "fda", "svmRadialCost", "gbm", "C5.0", "C5.0Cost", 
                   "knn", "naive_bayes", "rpart", "parRF")
algorithmList2 <- c("vglmAdjCat", "lda", "mda", 'qda', "J48", "PART", "treebag",
                    "rda", "nnet", "fda", "gbm", 
                    "knn", "naive_bayes", "rpart")
algorithmList3 <- c("treebag", "fda", "gbm", "naive_bayes")
idx <- createDataPartition(dt_balanceado$incendio, p = .75, list = FALSE)
treino <- dt_balanceado[idx,]
teste <- dt_balanceado[-idx,]
control <- trainControl(method="cv",
                        number = 10,
                        savePredictions="final", verboseIter = T)
form <- as.formula("incendio ~ Data+TempBulboSeco+TempBulboUmido+
                         UmidadeRelativa+VelocidadeVento+
                         Nebulosidade+Latitude+Longitude+mes")
set.seed(1869)
metric <- "Accuracy"
models <- caretList(form, data = treino,
                    trControl = control, 
                    methodList = algorithmList, 
                    metric = metric, 
                    continue_on_fail = F)
results <- resamples(models)
summary(results)
stopCluster(cluster)
registerDoSEQ()
gc()

# Tempo de execução
results$timings

# Selecionando os que estão abaixo de 10s
results$timings[results$timings$Everything < 20,]
primeira_selecao <- rownames(results$timings[results$timings$Everything < 10,])
primeira_selecao

results2 <- as.data.frame(predict(models, teste))
segunda_selecao <- c()
for (i in primeira_selecao){
  mat <- confusionMatrix(reference = teste$incendio, 
                         data = results2[,i],
                         positive = "sim")
  if (mat$overall['Accuracy'] > 0.7){
    if(mat$byClass['Sensitivity'] > 0.3){
      accu_seg <- mat$overall['Accuracy']/(results$timings[which(rownames(results$timings) ==  i),1])
      if (accu_seg > 0.1){
        print(paste0(i," -> accu/seg: ", accu_seg))
        segunda_selecao <- append(segunda_selecao, i)
      }
    }
  }
}

# Segunda seleção
segunda_selecao
models <- caretList(form, data = treino,
                    trControl = control, 
                    methodList = segunda_selecao, 
                    metric = metric, 
                    continue_on_fail = F)
results3 <- resamples(models)
summary(results)

results3$timings

results4 <- as.data.frame(predict(models, teste))
terceira_selecao <- c()
for (i in segunda_selecao){
  mat <- confusionMatrix(reference = teste$incendio, 
                         data = results4[,i],
                         positive = "sim")
  if (mat$overall['Accuracy'] > 0.7){
    if(mat$byClass['Sensitivity'] > 0.3){
      accu_seg <- mat$overall['Accuracy']/(results3$timings[which(rownames(results3$timings) ==  i),1])
      if (accu_seg > 0.1){
        print(paste0(i," -> accu/seg: ", accu_seg))
        terceira_selecao <- append(terceira_selecao, i)
      }
    }
  }
}
