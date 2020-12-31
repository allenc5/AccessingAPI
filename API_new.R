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

#Interrogate the Github API to extract data from my own github account
myData = fromJSON("https://api.github.com/users/allenc5")
myData$followers #displays number of followers
myData$following #displays number of people I am following

following = fromJSON("https://api.github.com/users/allenc5/following")
following$login #gives the names of all the people I am following

myData$public_repos #displays the number of public repositories I have

repos = fromJSON("https://api.github.com/users/allenc5/repos")
repos$name #My public repositories
repos$created_at #Gives details of the dates the repositories were created 
repos$full_name #Gives names of repositories

myData$bio #Displays my bio

LCARepos <- fromJSON("https://api.github.com/repos/allenc5/Software-Engineering/commits")
LCARepos$commit$message #Each commits description for the LCA assignment repository 

#Interrogate the Github API to extract data from another account by switching the username
fabpotData = fromJSON("https://api.github.com/users/fabpot")
fabpotData$followers #lists num followers fabpot has

followers = fromJSON("https://api.github.com/users/fabpot/followers")
followers$login #gives user names of all Fabio's followers

fabpotData$following #lists number of people fabpot follows
fabpotData$public_repos #lists number of repositories fabpot 
fabpotData$bio 







