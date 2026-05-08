# force HTTP/1.1 in the current session before upload
httr::set_config(httr::config(http_version = 1L))


# R-2 ----
# Find the Rmd (including under output/), render it, then attempt RPubs upload.
getwd()                             # check current working directory; open project if wrong

# locate the Rmd
rmd_matches <- list.files(".", pattern = "^Dist_SS\\.Rmd$", recursive = TRUE, full.names = TRUE)
if (length(rmd_matches) == 0) stop("Dist_SS.Rmd not found in project. Place it in the project root or 'output/' and retry.")
rmd <- normalizePath(rmd_matches[1])

# determine html output path (same directory as the Rmd)
out_dir <- dirname(rmd)
html_file <- "Dist_SS.nb.html"

if (!requireNamespace("rmarkdown", quietly = TRUE)) install.packages("rmarkdown")
if (!requireNamespace("rsconnect", quietly = TRUE)) install.packages("rsconnect")
if (!requireNamespace("httr", quietly = TRUE)) install.packages("httr")

# render into the same directory as the Rmd
out_html <- rmarkdown::render(input = rmd, output_file = html_file, output_dir = out_dir, quiet = TRUE)
out_html <- normalizePath(out_html)

# prefer HTTP/1.1 to avoid HTTP/2 framing issues
httr::set_config(httr::config(http_version = 1L))

# set your numeric RPubs id here
record_id <- "1341684"

# attempt upload (returns metadata on success or an error object)
res <- tryCatch(
  rsconnect::rpubsUpload(title = "Dist_SS", contentFile = out_html, id = record_id),
  error = function(e) e
)

if (inherits(res, "error")) {
  message("Upload failed: ", conditionMessage(res))
  utils::browseURL("https://rpubs.com/")   # fallback: open RPubs for manual upload
  invisible(res)
} else {
  # save numeric id for future updates (if returned)
  if (!is.null(res$url)) {
    id <- sub(".*/([0-9]+)$", "\\1", res$url)
    if (grepl("^[0-9]+$", id)) writeLines(id, ".rpubs_record")
  }
  res   # return upload metadata
}


save_file <- ".rpubs_record"


# prefer HTTP/1.1 to avoid HTTP/2 framing errors
httr::set_config(httr::config(http_version = 1L))

try_upload <- function(html_path, id, attempts = 3) {
  attempt <- 1
  while (attempt <= attempts) {
    res <- tryCatch(
      rsconnect::rpubsUpload(title = basename(html_path), contentFile = html_path, id = id),
      error = function(e) e
    )
    if (!inherits(res, "error")) return(res)
    Sys.sleep(3)
    attempt <- attempt + 1
  }
  # return last error object
  res
}

res <- try_upload(html, record_id, attempts = 3)

if (inherits(res, "error")) {
  message("Automated upload failed: ", conditionMessage(res))
  message("Fallback: open https://rpubs.com/ to upload manually. After publishing, save the numeric id:")
  utils::browseURL("https://rpubs.com/")
} else {
  # save numeric id from returned URL (if present) for future updates
  if (!is.null(res$url)) {
    id <- sub(".*/([0-9]+)$", "\\1", res$url)
    if (grepl("^[0-9]+$", id)) writeLines(id, save_file)
  }
  res
}

# Helper to save id after a manual browser upload:
save_rpubs_id <- function(post_url, file = ".rpubs_record") {
  id <- sub(".*/([0-9]+)$", "\\1", post_url)
  if (!grepl("^[0-9]+$", id)) stop("No numeric id found in URL: ", post_url)
  writeLines(id, file)
  invisible(id)
}










# R-1 ----
# r
# After restarting R run this once
if (!requireNamespace("rsconnect", quietly = TRUE)) install.packages("rsconnect")
if (!requireNamespace("httr", quietly = TRUE)) install.packages("httr")

# prefer HTTP/1.1 to avoid HTTP/2 framing errors
httr::set_config(httr::config(http_version = 1L))

html_path <- "output/Dist_SS.nb.html"   # adjust path if needed
record_id <- "1341684"                  # your numeric RPubs id

if (!file.exists(html_path)) stop("Rendered HTML not found: ", html_path)

res <- tryCatch(
  rsconnect::rpubsUpload(title = "Dist_SS", contentFile = html_path, id = record_id),
  error = function(e) e
)

if (inherits(res, "error")) {
  message("Upload failed: ", conditionMessage(res))
  # fallback: open RPubs page so you can upload manually
  utils::browseURL("https://rpubs.com/amarulo/1341684")
} else {
  # save the returned url/metadata for future updates
  if (!is.null(res$url)) writeLines(sub(".*/([0-9]+)$", "\\1", res$url), ".rpubs_record")
  res
}




# R0 ----
# R
# 1) update client packages first
install.packages(c("curl", "httr", "rsconnect"))

# 2) restart R session now (manually). After restart, run:
httr::set_config(httr::config(http_version = 1L))

# 3) then try upload (replace html_path and record_id)
html_path <- "output/Dist_SS.nb.html"
record_id <- "1341684"   # numeric id or NA

res <- tryCatch(
  rsconnect::rpubsUpload(title = "Dist_SS", contentFile = html_path, id = record_id),
  error = function(e) e
)

if (inherits(res, "error")) {
  message("Upload failed: ", conditionMessage(res))
} else {
  res
}


# R1 ----
# Fui capaz de conectar con el servidor de RPubs, y se generó el archivo de manifiesto en:
# output/.posit/publish/

# Notes:
# rpubsUpdate requires the numeric record number (the integer at the end of some RPubs URLs).
# If you don't have that numeric id, rpubsUpload will create a new RPubs post.
# The IDE Publish UI can also handle uploads/updates and will prompt for authentication (Es lo
# que está en el manifiesto).

# show the manifest contents
path <- "output/.posit/publish/output-N6VU.toml"
if (file.exists(path)) readLines(path) else "file not found"


# R1.5 - update an existing RPubs post (use numeric id)
# 1) prerequisites
if (!requireNamespace("rsconnect", quietly = TRUE)) install.packages("rsconnect")
if (!requireNamespace("rmarkdown", quietly = TRUE)) install.packages("rmarkdown")

# 2) path to rendered HTML (or render anew)
# If you already have the file, set html_path to that full/relative path
html_path <- "output/Dist_SS.nb.html"
if (!file.exists(html_path)) {
  # render if needed (optional)
  html_path <- rmarkdown::render("Dist_SS.Rmd", output_file = html_path)
} else {
  html_path <- normalizePath(html_path)
}

# 3) your numeric RPubs id (NOT the slug). e.g. from https://rpubs.com/amarulo/1341684 -> "1341684"
record_id <- "1341684"

# 4) update (use rpubsUpdate if present, otherwise rpubsUpload with id)
if (!grepl("^[0-9]+$", record_id)) stop("record_id must be numeric (the integer at the end of the RPubs URL).")

if ("rpubsUpdate" %in% getNamespaceExports("rsconnect")) {
  res <- rsconnect::rpubsUpdate(recordNumber = record_id, htmlFile = html_path)
} else {
  # rpubsUpload(title, contentFile, id = NULL, ...) - pass id to replace existing
  res <- rsconnect::rpubsUpload(title = "Dist_SS", contentFile = html_path, id = record_id)
}

res  # contains the resulting URL/metadata; save res$url for next update


# R1.75 - check connectivity and environment before attempting update
# Shows R curl/libcurl/ssl versions
curl::curl_version()

# Check environment proxy variables (if any)
Sys.getenv(c("http_proxy", "https_proxy", "HTTP_PROXY", "HTTPS_PROXY"))

# DNS lookup for the host
curl::nslookup("api.rpubs.com")

# Try a verbose HTTP request (may reveal HTTP/2 negotiation, TLS, proxy issues)
h <- curl::new_handle()
curl::handle_setopt(h, verbose = TRUE, http_version = 1L) # request HTTP/1.1 to avoid HTTP/2
try(curl::curl_fetch_memory("https://api.rpubs.com", handle = h), silent = FALSE)

# Alternatively use httr for a verbose GET (shows headers / connection)
httr::GET("https://api.rpubs.com", httr::verbose())


# R1.8 - try upload; if needed rsconnect will open a browser login
html_path <- "output/Dist_SS.nb.html"
record_id <- "1341684"   # or NA to create new

if (!file.exists(html_path)) stop("HTML not found: ", html_path)

res <- tryCatch(
  rsconnect::rpubsUpload(title = "Dist_SS", contentFile = html_path, id = record_id),
  error = function(e) e
)

if (inherits(res, "error")) {
  message("Upload failed: ", conditionMessage(res))
  # fallback: open RPubs in browser to upload manually
  utils::browseURL("https://rpubs.com/")
} else {
  res  # contains the post URL/metadata
}

# R2 ----
# Render Rmd and update RPubs post (replace record_id)
if (!requireNamespace("rsconnect", quietly = TRUE)) install.packages("rsconnect")
if (!requireNamespace("rmarkdown", quietly = TRUE)) install.packages("rmarkdown")

# path to your Rmd and desired output
rmd <- "output/Dist_SS.Rmd"
out_html <- rmarkdown::render(rmd, output_file = "Dist_SS.nb.html", quiet = TRUE)

# set your numeric RPubs id here (e.g. "1341684"); leave NA to upload new
record_id <- "1341684"

if (!is.na(record_id) && nzchar(record_id) && grepl("^[0-9]+$", record_id)) {
  res <- rsconnect::rpubsUpdate(recordNumber = record_id, htmlFile = out_html)
} else {
  res <- rsconnect::rpubsUpload(title = "Dist_SS", htmlFile = out_html)
}

res  # returns metadata including res$url


# R3 ----
# Render to HTML, then update existing RPubs document
out_html <- rmarkdown::render("Dist_SS.Rmd", output_file = "Dist_SS.nb.html")

# If first time publish
# res <- rsconnect::rpubsUpload(title = "My analysis", htmlFile = out_html)

# To republish/update an existing document (use the number from your RPubs URL)
res <- rsconnect::rpubsUpdate(recordNumber = "1341684", htmlFile = out_html)

res   # returns upload metadata (including the URL)


# No — use the numeric record ID. Your URL (https://rpubs.com/amarulo/SS_Hacienda) uses a slug,
# not the numeric recordNumber rpubsUpdate expects. Either grab the numeric id returned by
# rpubsUpload when you first published, or re-upload.

# Brief explanation and example: render the Rmd, try to extract a numeric id from a saved URL (or
# the upload result), and call rpubsUpdate only if you have that numeric id; otherwise call
# rpubsUpload to create a new RPubs entry.


# R4 ----
# 1) Render Rmd to HTML
out_html <- rmarkdown::render("Dist_SS.Rmd", output_file = "Dist_SS.nb.html")

# 2) If you still have the original upload result, use its URL to get the numeric id:
#    (rpubsUpload returns a result with a URL; parse trailing digits if present)
# Example when you have the upload result object:
# res <- rsconnect::rpubsUpload(title = "SS_Hacienda", htmlFile = out_html)
# res$url

# parse numeric id from a URL (if present)
url <- "https://rpubs.com/amarulo/SS_Hacienda"  # replace with your actual saved URL or res$url
record <- sub(".*/([0-9]+)$", "\\1", url)

if (grepl("^[0-9]+$", record)) {
  # update existing RPubs document (record is numeric)
  res_update <- rsconnect::rpubsUpdate(recordNumber = record, htmlFile = out_html)
  res_update
} else {
  # no numeric id found → upload as a new document
  res_new <- rsconnect::rpubsUpload(title = "SS_Hacienda", htmlFile = out_html)
  res_new
}


# R5 DESCRIPTION ----
# Notes:

# Keep the file in the project root (the same directory as your .Rproj or where getwd() points),
# so publishing tools (and package/build tools) find it.
# DESCRIPTION uses package-style fields; it is plain text, not .txt.
# Below: a short explanation and two ways to create it:
#  1) with usethis (recommended), 
#  2) manually with writeLines. 
# Update fields (Package, Title, Authors@R, Description, License, URL, BugReports) to suit
# your project.
# R
# 1) Recommended: create a DESCRIPTION using usethis (will write to project root)
if (!requireNamespace("usethis", quietly = TRUE)) install.packages("usethis")
usethis::use_description(fields = list(
  Package = "DistSS",
  Title = "Summary statistics for Hacienda",
  Version = "0.1.0",
  `Authors@R` = 'person(given="A",
                        family="Marulo",
                        email="amarulo@example.com",
                        role=c("aut","cre")
                       )',
  Description = "Analysis and reports for Dist_SS project; contains rendered R Markdown reports.",
  License = "MIT",
  Encoding = "UTF-8",
  LazyData = "true",
  URL = "https://github.com/amarulo/Dist_SS",
  BugReports = "https://github.com/amarulo/Dist_SS/issues"
))

# 2) Manual: write a minimal DESCRIPTION file (plain text) to project root
desc_text <- c(
  "Package: DistSS",
  "Title: Summary statistics for Hacienda",
  "Version: 0.1.0",
  "Authors@R: person(
                      given = \"A\", 
                      family = \"Marulo\", 
                      email = \"amarulo@gmail.com\", 
                      role = c(\"aut\", \"cre\")
                    )",
  "Description: Analysis and reports for Dist_SS project; contains rendered R Markdown reports.",
  "License: MIT",
  "Encoding: UTF-8",
  "LazyData: true"
)
writeLines(desc_text, con = file.path(getwd(), "DESCRIPTION"))

# Verify
file.exists("DESCRIPTION")
readLines("DESCRIPTION")


# R6 ----
# Check rsconnect exports and version, then call update if available,
# otherwise fall back to rpubsUpload (new upload).
getNamespaceExports("rsconnect")
#  [1] "showProperties"       "lint"                 "restartApp"           "deployments"         
#  [5] "showLogs"             "configureApp"         "rpubsUpload"          "deployAPI"           
#  [9] "removeServer"         "removeAuthorizedUser" "connectCloudUser"     "authorizedUsers"     
# [13] "deployDoc"            "serverInfo"           "terminateApp"         "getLogs"             
# [17] "accountInfo"          "discoverServers"      "removeAccount"        "setProperty"         
# [21] "deployTFModel"        "purgeApp"             "accountUsage"         "syncAppMetadata"     
# [25] "servers"              "forgetDeployment"     "resendInvitation"     "addServer"           
# [29] "setAccountInfo"       "showInvited"          "deploySite"           "addAuthorizedUser"   
# [33] "tasks"                "addServerCertificate" "connectSPCSUser"      "taskLog"             
# [37] "showMetrics"          "showUsers"            "deployApp"            "connectUser"         
# [41] "listBundleFiles"      "accounts"             "unsetProperty"        "showUsage"           
# [45] "addConnectServer"     "listAccountEnvVars"   "appDependencies"      "listDeploymentFiles" 
# [49] "writeManifest"        "addLinter"            "generateAppName"      "connectApiUser"      
# [53] "linter"               "updateAccountEnvVars" "applications"  
packageVersion("rsconnect") 
#[1] ‘1.7.0’

if ("rpubsUpdate" %in% getNamespaceExports("rsconnect")) {
  res <- rsconnect::rpubsUpdate(recordNumber = record_id, htmlFile = out_html)
} else {
  res <- rsconnect::rpubsUpload(title = "Dist_SS", contentFile = out_html)
}
res
