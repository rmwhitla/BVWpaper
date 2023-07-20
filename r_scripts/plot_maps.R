library(readr)
library(dplyr)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggspatial)
library(patchwork)
library(jpeg)
library(ggrepel)


#read in info file
info <- read_delim("/storageToo/PROJECTS/Saad/repos/BVWpaper/infofile.tsv", delim="\t", col_types = cols())
#get map data
world <- ne_countries(scale = "medium", returnclass = "sf")

#set default plotting theme
theme_set(theme_bw())
options(ggrepel.max.overlaps = Inf)
#TODO
#fix random jittering of points? Better way to plot?

#plot the map
detail<- ggplot(data=world) +
  geom_sf(colour="black",fill="white" )+
  geom_point( data=info %>% filter(Original_region == "GB"), size=3, aes(x=longitude, y=latitude), shape=19, alpha=0.75) + 
  geom_point( data=info %>% filter(Original_region == "Europe"), size=3, aes(x=longitude, y=latitude), shape=17, alpha=0.75) + 
  geom_label_repel(data=info %>% filter(Original_region != "Japan"), box.padding = 0.5, aes(x=longitude, y=latitude, label = sample_name), size = 2.5)+
  coord_sf(xlim = c(-6, 9), ylim = c(45, 53), expand = FALSE) + xlab("") + ylab("") + 
  annotation_scale(location = "bl", width_hint = 0.4) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_blank(),panel.background = element_rect(fill = "aliceblue"),
        plot.margin=grid::unit(c(0,0,0,0), "mm") )
#print the map
detail

#inset
global<- ggplot(data=world) +
  geom_sf(colour="black",fill="white" )+
  coord_sf(xlim = c(-11, 17), ylim = c(37, 63), expand = T) + 
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_blank(),panel.background = element_rect(fill = "aliceblue"), 
        panel.border = element_rect(color = "black",fill = NA, size = 1),
        plot.margin=grid::unit(c(0,0,0,0), "mm"))
global

#get butterfly image
white <- readJPEG("/storageToo/PROJECTS/Saad/repos/BVWpaper/white.jpg", native=T)
#white_filt <- removeBackground(white)

#Plot map 
detail + inset_element(global, left = .7, bottom = .66, top = 1, right = 1.1) + inset_element(white, left = .87, bottom = 0.01, top = .13, right = .99)


#Same for common blue
lat = c(58.18553, 57.87810, 57.87810, 51.78256, 44.15734, 44.15734, 44.15734)
long=c(-7.025334,  -4.016982, -4.016982,  -1.125439, 1.982669, 1.982669, 1.982669)
labels=c("TULf73", "DGCf87", "DGCm100", "BMDf276", "FRNm003", "FRNm006", "FRNm007")
Original_region=c("GB", "GB", "GB", "GB", "Europe","Europe", "Europe" )
blue = data.frame(labels=labels, lat=lat, long=long, Original_region=Original_region)

bluedetail <- ggplot(data=world) +
  geom_sf(colour="black",fill="white")+
  geom_point( data=blue %>% filter(Original_region == "GB"),  size=3, aes(x=long, y=lat), shape=19, alpha=0.75) + 
  geom_point( data=blue %>% filter(Original_region == "Europe"), size=3, aes(x=long, y=lat), shape=17, alpha=0.75) + 
  geom_label_repel(data=blue, aes(x=long, y=lat, label = labels), size = 2.5,box.padding = 0.5)+
  coord_sf(xlim = c(-8, 9), ylim = c(43, 60), expand = FALSE) + xlab("") + ylab("") + 
  annotation_scale(location = "bl", width_hint = 0.4) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major = element_blank(),panel.background = element_rect(fill = "aliceblue"),
        plot.margin=grid::unit(c(0,0,0,0), "mm"))
#print the map
bluedetail

#get butterfly image
blue <- readJPEG("/storageToo/PROJECTS/Saad/repos/BVWpaper/blue.jpg", native=T)

#Plot map 
bluedetail + inset_element(global, left = .66, bottom = .66, top = 1.03, right = 1) + inset_element(blue, left = .87, bottom = 0.01, top = .08, right = .99)

  