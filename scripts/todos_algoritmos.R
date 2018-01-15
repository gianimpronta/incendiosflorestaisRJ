# Criando versão menor do dataset desbalanceado
idx <- sample(nrow(dt_final), 1000)
treino <- dt_final[idx,]

control <- trainControl(method="cv",
                        number = 10,
                        savePredictions="final", 
                        verboseIter = T,
                        allowParallel = T)
form <- as.formula("incendio ~ Data+TempBulboSeco+TempBulboUmido+
                   UmidadeRelativa+VelocidadeVento+
                   Nebulosidade+Latitude+Longitude+mes")

m <- unique(modelLookup()[modelLookup()$forClas,c(1)])
m

# slow classification models ("rbf" crashes; "dwdLinear", "ownn", "snn" have issues)
# all others may have just failed and are not listed here
#
removeModels <- c("AdaBag", "AdaBoost.M1", "FH.GBML", "pda2", "PenalizedLDA",
                  "GFS.GCCL", "rbf", "RFlda", "nodeHarvest", "ORFsvm", "dwdLinear", "dwdPoly", "gam",
                  "gaussprLinear", "ownn", "sddaLDA", "sddaQDA", "SLAVE", "smda", "snn", "rmda", 
                  "rFerns", "wsrf","ordinalNet","awnb", "awtan","manb","nbDiscrete","nbSearch","tan",
                  "tanSearch","bartMachine","randomGLM", "Rborist", "adaboost")

#remove all slow and failed models from model list
m <- m[!m %in% removeModels]

# pre-load all packages (does not really work due to other dependencies)
suppressPackageStartupMessages(ll <-lapply(m, require, character.only = TRUE))


# register parallel front-end
cluster <- makePSOCKcluster(detectCores() - 1)
registerDoParallel(cluster)

# this is required otherwise the first method is benchmarked wrong
warmup <-train(form, treino, "rf", trControl = control)

# this setup actually calls the caret::train function, in order to provide
# minimal error handling this type of construct is needed.
trainCall <- function(i) 
{
  cat("----------------------------------------------------","\n");
  set.seed(123); cat(i," <- loaded\n");
  return(tryCatch(
    t2 <- train(form, treino, (i), trControl = control, metric = ),
    error=function(e) NULL))
}

# use lapply/loop to run everything, required for try/catch error function to work
t2 <- lapply(m, trainCall)

#remove NULL values, we only allow succesful methods, provenance is deleted.
t2 <- t2[!sapply(t2, is.null)]
save(t2, file= "t2.Rds")

# this setup extracts the results with minimal error handling 
# TrainKappa can be sometimes zero, but Accuracy SD can be still available
# see Kappa value http://epiville.ccnmtl.columbia.edu/popup/how_to_calculate_kappa.html
printCall <- function(i) 
{
  return(tryCatch(
    {
      cat(sprintf("%-22s",(m[i])))
      cat(round(getTrainPerf(t2[[i]])$TrainAccuracy,4),"\t")
      cat(round(getTrainPerf(t2[[i]])$TrainKappa,4),"\t")
      cat(t2[[i]]$times$everything[3],"\n")},
    error=function(e) NULL))
}

r2 <- lapply(1:length(t2), printCall)

# stop cluster and register sequntial front end
stopCluster(cluster); registerDoSEQ();

# preallocate data types
i = 1; MAX = length(t2);
x1 <- character() # Name
x2 <- numeric()   # R2
x3 <- numeric()   # RMSE
x4 <- numeric()   # time [s]
x5 <- character() # long model name

# fill data and check indexes and NA with loop/lapply 
for (i in 1:length(t2)) {
  x1[i] <- t2[[i]]$method
  x2[i] <- as.numeric(round(getTrainPerf(t2[[i]])$TrainAccuracy,4))
  x3[i] <- as.numeric(round(getTrainPerf(t2[[i]])$TrainKappa,4))
  x4[i] <- as.numeric(t2[[i]]$times$everything[3])
  x5[i] <- t2[[i]]$modelInfo$label
}

# coerce to data frame
df1 <- data.frame(x1,x2,x3,x4,x5, stringsAsFactors=FALSE)

# print all results to R-GUI
df1
save(df1, file ="df1.Rds")

# plot models, just as example
ggplot(t2[[1]])
# ggplot(t2[[1]])

# call web output with correct column names
datatable(df1,  options = list(
  columnDefs = list(list(className = 'dt-left', targets = c(0,1,2,3,4,5))),
  pageLength = MAX,
  order = list(list(2, 'desc'))),
  colnames = c('Num', 'Name', 'Accuracy', 'Kappa', 'time [s]', 'Model name'),
  caption = paste('Classification results from caret models',Sys.time()),
  class = 'cell-border stripe')  %>% 	       
  formatRound('x2', 3) %>%  
  formatRound('x3', 3) %>%
  formatRound('x4', 3) %>%
  formatStyle(2,
              background = styleColorBar(x2, 'steelblue'),
              backgroundSize = '100% 90%',
              backgroundRepeat = 'no-repeat',
              backgroundPosition = 'center'
  )

ggplot(df1, aes(x = x2, y = x4)) + 
  geom_point()

ggplot(df1[df1$x2 > 0.725,], aes(x = x2, y = x4)) + 
  geom_point()

ggplot(df1[df1$x4 < 1000 & df1$x2 > 0.725,], aes(x = x2, y = x4)) + 
  geom_point()

ggplot(df1[df1$x4 < 1000 & df1$x2 > 0.75,], aes(x = x2, y = x4)) + 
  geom_point()

ggplot(df1[df1$x4 < 250 & df1$x2 > 0.75,], aes(x = x2, y = x4)) + 
  geom_point()

ggplot(df1[df1$x4 < 70 & df1$x2 > 0.75,], aes(x = x2, y = x4)) + 
  geom_point()


### END

