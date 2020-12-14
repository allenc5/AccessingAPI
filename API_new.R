install.packages("jsonlite")
library(jsonlite)
install.packages("httpuv")
library(httpuv)
install.packages("httr")
library(httr)

# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what you 
myapp <- oauth_app(appname = "Charlie_Allen_Github_API",
                   key = "e1a8367d25b7a82dcb3b",
                   secret = "d2dbe613c59db1b6a5c4f6fce6619ae28202ec51")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/allenc5/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "allenc5/datasharing", "created_at"] 

# The above code was sourced from https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08  