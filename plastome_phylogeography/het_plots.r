library(ggplot2)

hets <- read.table("~/Documents/Work/Populus/plastome_phylogeography_results/recombination/final_hets.txt")

ggplot(hets) + scale_y_log10() +geom_point(color="black",fill="red",aes(x=1:25,y=diff)) + geom_point(shape=2, aes(x=1:25,y=bals,color=species)) + geom_point(shape=0, aes(x=1:25,y=tric,color=species)) + annotation_logticks(sides="lr") + scale_x_discrete(labels=row.names(hets)) + theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggplot(data) +geom_point(color="black",fill="red",aes(x=1:5,y=P_balsamifera)) + geom_point(shape=2, aes(x=1:5,y=P_trichocarpa)) +  scale_x_discrete(labels=row.names(data)) + theme(axis.text.x = element_text(angle = 90, hjust = 1))
