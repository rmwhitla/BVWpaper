#A script to choose best K from NGSadmix runs with ma range of K with replicates

#------------------------------
#SETUP
#Enter number of replicates below
reps=10
#enter range of K values below
kmin=1
kmax=5
#-----------------------------

#read in the data
data<-list.files("/storageToo/PROJECTS/Saad/repos/BVWpaper/angsd_out/", 
                pattern = "K[0-9]_[0-9].*.log", full.names = T) #change pattern based on your naming convention

#look at data to make sure it only has the log files
data

#use lapply to read in all our log files at once
bigData<-lapply(kmin:(kmax*reps), FUN = function(i) readLines(data[i]))
bigData

# find the line that starts with "best like=" or just "b"
library(stringr)
#this will pull out the line that starts with "b" from each file and return it as a list
foundset<-sapply(kmin:(kmax*reps), FUN= function(x) bigData[[x]][which(str_sub(bigData[[x]], 1, 1) == 'b')])
foundset

#now we need to pull out the first number in the string, we'll do this with the function sub
as.numeric( sub("\\D*(\\d+.\\d+).*", "\\1", foundset) )

#now lets store it in a dataframe
#make a dataframe with an index K, this corresponds to our K values
logs<-data.frame(K = rep(kmin:kmax, each=reps))

#add to it our likelihood values
logs$like<-as.vector(as.numeric( sub("\\D*(\\d+.\\d+).*", "\\1", foundset) ))

#and now we can calculate our delta K and probability
tapply(logs$like, logs$K, FUN= function(x) mean(abs(x))/sd(abs(x)))

#Choose K with the highest value