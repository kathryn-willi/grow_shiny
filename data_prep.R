library(tidyverse)
library(sf)
library(nhdplusTools)
library(mapview)

# pull in what's on github
grow_git <- read_csv('data/prep/GROWdb_with_vars_20220725.csv') %>%
  mutate(MetaT=ifelse(has_MetaT=="Y","MetaT",""),
         MetaG=ifelse(grepl("3",MetaG_JGI_accession),"MetaG",""),
         FTICR=ifelse(has_FTICR=="Y","FTICR","")) %>%
  mutate(AvailableMeta = trimws(paste0(MetaG," ",MetaT," ",FTICR))) %>%
  mutate(JGIlink=ifelse(MetaG=="MetaG", 
         paste0("https://img.jgi.doe.gov/cgi-bin/mer/main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=",MetaG_JGI_accession),
         paste0("")))
    


metabolism <- read_csv('data/prep/norm_counts_rpk_edger_bins_median_adj.csv') %>%
  select(SampleName, Aerobe, Fermenter, Denitrifier, Phototroph)

# bind git and metabolism together, prep for putting into shiny app...
grow_update <- grow_git %>%
  left_join(.,metabolism,by="SampleName") %>%
  mutate(HUC2=str_replace(huc2,"HUC-",""),
         FlowConditions=ifelse(is.na(CFS), "No Flow Data",
                        ifelse(CFS <= percentile_20, "Low",
                        ifelse(CFS >= percentile_80, "High",
                        ifelse(CFS > percentile_20 & CFS < percentile_80, "Normal","Weird")))),
         PctForest2016Ws=PctDecid2016Ws+PctConif2016Ws+PctMxFst2016Ws) %>%
  select(SampleName,
         Sample, 
         ProjectPI=Project_PI,
         Date,
         Time,
         Country,
         Latitude,
         Longitude,
         AvailableMeta,
         Notes,
         Aerobe,
         Fermenter, 
         Denitrifier, 
         Phototroph,
         JGIData=JGIlink,
         HUC2,
         COMID=comid,
         GNISName=gnis_name,
         StreamOrder=streamorde,
         WatershedAreaSqKm=totdasqkm,
         SlopeSite=slope,
         DamDensWs,
         DamNrmStorWs,
         MineDensWs,
         WWTPAllDensWs,
         WWTPMajorDensWs,
         PctForest2016Ws,
         PctImp2016Ws,
         PctCrop2016Ws,
         TmeanSite,
         TmeanWs,
         PrecipSite,
         PrecipWs,
         AridityIndexSite=AriditySite,
         AridityIndexWs=AridityWs,
         OmernikISite,
         OmernikIISite,
         OmernikIIISite,
         GageID=gage_id,
         FlowData=flowlink,
         FlowRecord=flow_record,
         DischargeCFS=CFS,
         FlowConditions) %>%
  saveRDS('data/GROWDb.RDS')

contus <- grow_update %>%
  filter(!is.na(COMID)) %>%
  saveRDS('data/GROWdb_CONTUS.RDS')

