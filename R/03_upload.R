library(dataone)
library(datapack)
library(uuid)
library(here)

# dataone vignettes here https://cran.r-project.org/web/packages/dataone/index.html

# authenticate
token <- Sys.getenv('dataone_token')
options(dataone_token = token)

# prod node for KNB
cn <- CNode('PROD')
mn <- getMNode(cn, 'urn:node:KNB')

# # staging/test node for KNB
#
# # authenticate
# token <- Sys.getenv('dataone_test_token')
# options(dataone_test_token = token)
#
# cn <- CNode('STAGING')
# mn <- getMNode(cn, 'urn:node:mnTestKNB')

# verify credentials authenticated
echoCredentials(cn)

##
# new package

# initiate data package
dp <- new('DataPackage')

# xml metadata file
emlFile <- here('wetlanddat.xml')
doi <- generateIdentifier(mn, 'DOI')
metadataObj <- new('DataObject', id = doi, format = 'eml://ecoinformatics.org/eml-2.1.1', filename = emlFile)
dp <- addMember(dp, metadataObj)

# zip data files, add to data package
fls <- list.files(here('data'), full.names = T)
for(fl in fls){
  cat(basename(fl), '\t')
  sourceObj <- new('DataObject', format='zip', filename = fl)
  dp <- addMember(dp, sourceObj, metadataObj)
}

# set my access rules
myAccessRules <- data.frame(subject = 'https://orcid.org/0000-0002-4996-0059', permission = 'changePermission')

# id member node, upload
cli <- D1Client(cn, mn)
packageId <- uploadDataPackage(cli, dp, public = TRUE, accessRules = myAccessRules, quiet = FALSE)
message(sprintf('Uploaded package with identifier: %s', packageId))

##
# update data objects and metadata file

# download package
cli <- D1Client(cn, mn)
doi <- 'resource_map_doi:10.5063/F1M043V0'
pkg <- getDataPackage(cli, identifier = doi, lazyLoad = TRUE, quiet = FALSE)

# update zip files
fls <- list.files(here('data'), full.names = T)

for(fl in fls){

  cat(fl, '\n')

  objId <- selectMember(pkg, name = "sysmeta@fileName", value = basename(fl))
  zipfile <- fl
  pkg <- replaceMember(pkg, objId, replacement = zipfile, formatId="zip")

}

# update metadata
objId <- selectMember(pkg, name = "sysmeta@fileName", value = 'wetlanddat.xml')
newmeta <- here('wetlanddat.xml')
pkg <- replaceMember(pkg, objId, replacement=newmeta, formatId="eml://ecoinformatics.org/eml-2.1.1")

# upload the updated pkg
uploadDataPackage(cli, pkg, public=TRUE, quiet=FALSE)

# # archive a dataset
# archive(mn, 'resource_map_doi:10.5063/F10V8B8T')

