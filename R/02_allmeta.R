library(EML)
library(emld)
library(tidyverse)

# character columns need definition (in attributes)
# numeric needs unit and numbertype (see EML::get_unitList()$units) (in attributes)
# factors need to be defined (in attribute list)

# same attributes for each file ---------------------------------------------------------------

attributes <-
  tibble::tribble(
    ~attributeName, ~attributeDefinition,              ~formatString,  ~definition,                      ~unit, ~numberType,
    "ATTRIBUTE",    "NWI wetland attribute",           NA,            "NWI wetland attribute",           NA,              NA,
    "ACRES",        "Wetland acres",                   NA,            "Wetland acres",                   "acre",          'real',
    "WETLAND_TYPE", "NWI wetland type",                NA,            "NWI wetland type",                NA,              NA,
    "LON",          "Longitude of wetland centroid",   NA,            "Longitude WGS84",                 "dimensionless", "real",
    "LAT",          "Latitude of wetland centroid",    NA,            "Latitude WGS84",                  "dimensionless", "real",
    "neardist",     "Distance to nearest NHD feature", NA,            "Distance to nearest NHD feature", "meter",         "real",
    "state",        "State abbreviation",              NA,            "State abbreviation",              NA,              "real"
  )

attributeList <- set_attributes(attributes, col_classes = c("character", "numeric", "character", "numeric", "numeric", "numeric", "character"))

fls <- list.files('data')

for(fl in fls){

  physical <- set_physical(fl)

  st <- gsub('^wet|\\.zip', '', fl)

  datTable <- list(
    entityName = fl,
    entityDescription = paste(st, "wetland data"),
    physical = physical,
    attributeList = attributeList)

  assign(paste0(st, 'datTable'), datTable)

}

# universal metadata for all files ----------------------------------------

geographicDescription <- "Conterminous United States, plus Alaska and Hawaii"

coverage <- set_coverage(
  begin = '2023-06-05',
  end = '2023-07-21',
  geographicDescription = geographicDescription,
  west = -168.20,
  east = -66.77,
  north = 71.39,
  south = 18.86
)

R_person <- person(given = "Marcus", family = "Beck", email = "mbeck@tbep.org", comment = c(ORCID = "0000-0002-4996-0059"))
mbeck <- as_emld(R_person)
HF_address <- list(
  deliveryPoint = "263 13th Ave South",
  city = "St. Petersburg",
  administrativeArea = "FL",
  postalCode = "33701",
  country = "USA")
publisher <- list(
  organizationName = "Tampa Bay Estuary Program",
  address = HF_address)
contact <- list(
  individualName = mbeck$individualName,
  electronicMailAddress = mbeck$electronicMailAddress,
  address = HF_address,
  organizationName = "Tampa Bay Estuary Program",
  phone = "(727) 893-2765"
)

keywordSet <- list(
  list(
    keywordThesaurus = "Wetlands vocabulary",
    keyword = list("wetlands",
                   "WOTUS",
                   "SCOTUS",
                   "NWI",
                   "NHD"
                   )
  ))

title <- "Distance to nearest hydrologic feature for all wetlands in the National Wetland Inventory"

abstract <- 'Under the 2023 Supreme Court decision for Sackett vs USEPA, wetlands are jurisdictional to Waters of the United States (WOTUS) if 1) a continuous surface connection is present with an existing WOTUS, and 2) the wetland is practically indistinguishable from an ocean, river, stream, or lake where the continuous surface water connection is identified. A national-scale assessment for the United States was conducted to identify potential geographically isolated wetlands. The National Wetland Inventory (NWI, https://www.fws.gov/program/national-wetlands-inventory) maintained by the US Fish and Wildlife Service and the National Hydrograpy Dataset (NHD, https://www.usgs.gov/national-hydrography/national-hydrography-dataset) maintained by the US Geological Survey were used for the assessment. A custom workflow (https://github.com/tbep-tech/wetlands-eval) was developed to iteratively download the NWI and NHD spatial layers for each state to identify isolated wetlands based on the Euclidean distance of each wetland centroid to NHD features.  These data files represent all NWI wetlands in the United States and the distance (meters) to the closest NHD feature. The rows in each file represent individual wetlands, with columns for the wetland attribute, acreage of the wetland, latitude and longitude (WGS 1984) of the wetland centroid, distance of the wetland in meters to the nearest NHD feature, the state abbreviation, and wetland type.'

intellectualRights <- 'This dataset is released to the public and may be freely downloaded. Please keep the designated contact person informed of any plans to use the dataset. Consultation or collaboration with the original investigators is strongly encouraged. Publications and data products that make use of the dataset must include proper acknowledgement.'

# combine the metadata
dataset <- list(
  title = title,
  creator = mbeck,
  intellectualRights = intellectualRights,
  abstract = abstract,
  keywordSet = keywordSet,
  coverage = coverage,
  contact = contact,
  dataTable = list(AKdatTable, ALdatTable, ARdatTable, AZdatTable, CAdatTable, COdatTable, CTdatTable, DEdatTable, FLdatTable,
                   GAdatTable, HIdatTable, IAdatTable, IDdatTable, ILdatTable, INdatTable, KSdatTable, KYdatTable, LAdatTable, MAdatTable,
                   MDdatTable, MEdatTable, MIdatTable, MNdatTable, MOdatTable, MSdatTable, MTdatTable, NCdatTable, NDdatTable, NEdatTable,
                   NHdatTable, NJdatTable, NMdatTable, NVdatTable, NYdatTable, OHdatTable, OKdatTable, ORdatTable, PAdatTable, RIdatTable,
                   SCdatTable, SDdatTable, TNdatTable, TXdatTable, UTdatTable, VAdatTable, VTdatTable, WAdatTable, WIdatTable, WVdatTable,
                   WYdatTable) # must pass list explicitly
)



eml <- list(
  packageId = uuid::UUIDgenerate(),
  system = "uuid", # type of identifier
  dataset = dataset)

# write and validate the file
write_eml(eml, "wetlanddat.xml")
eml_validate("wetlanddat.xml")
