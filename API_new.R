install.packages("jsonlite")
library(jsonlite)
install.packages("httpuv")
library(httpuv)
install.packages("httr")
library(httr)
install.packages("plotly")
library(plotly)
require(devtools)

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

# Interrogate the Github API to extract data from my own github account
myData = fromJSON("https://api.github.com/users/allenc5")
myData$followers # Displays number of followers
myData$following # Displays number of people I am following

following = fromJSON("https://api.github.com/users/allenc5/following")
following$login # Gives the names of all the people I am following

myData$public_repos # Displays the number of public repositories I have

repos = fromJSON("https://api.github.com/users/allenc5/repos")
repos$name # My public repositories
repos$created_at # Gives details of the dates the repositories were created 
repos$full_name # Gives names of repositories

myData$bio # Displays my bio

LCARepos <- fromJSON("https://api.github.com/repos/allenc5/Software-Engineering/commits")
LCARepos$commit$message # Each commits description for the LCA assignment repository 

# Interrogate the Github API to extract data from another account by switching the username
fabpotData = fromJSON("https://api.github.com/users/fabpot")
fabpotData$followers # Lists the number of followers fabpot has

followers = fromJSON("https://api.github.com/users/fabpot/followers")
followers$login # Gives the user names of all fabpots followers

fabpotData$following # Lists the number of people fabpot follows
fabpotData$public_repos # Lists number of repositories fabpot has
fabpotData$bio # Displays fabpots bio

#Part 2 - Visualizations

# I am new to github and my account is relatively unpolluted.
# I have decided to choose another user in order to produce more populated graphs.
# The user I have chosen is Nelson (nelsonic) from London, found through a google search.

newData = GET("https://api.github.com/users/nelsonic/followers?per_page=100;", gtoken)
stop_for_status(newData)
extract = content(newData)
# Converts followers into a dataframe
githubDB = jsonlite::fromJSON(jsonlite::toJSON(extract))
githubDB$login

# Retrieve a list of usernames
id = githubDB$login
user_ids = c(id)

# Create an empty vector and data.frame
users = c()
usersDB = data.frame(
  username = integer(),
  following = integer(),
  followers = integer(),
  repos = integer(),
  dateCreated = integer()
)

# Loops through users and adds users to a list
for(i in 1:length(user_ids))
{
  
  followingURL = paste("https://api.github.com/users/", user_ids[i], "/following", sep = "")
  followingRequest = GET(followingURL, gtoken)
  followingContent = content(followingRequest)
  
  # Users with no followers aren't added
  if(length(followingContent) == 0)
  {
    next
  }
  
  followingDF = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
  followingLogin = followingDF$login
  
  # Loop through 'following' users
  for (j in 1:length(followingLogin))
  {
    # Check that the user is not already in the list
    if (is.element(followingLogin[j], users) == FALSE)
    {
      # Add user to list
      users[length(users) + 1] = followingLogin[j]
      
      # Retrieve each users data
      followingUrl2 = paste("https://api.github.com/users/", followingLogin[j], sep = "")
      following2 = GET(followingUrl2, gtoken)
      followingContent2 = content(following2)
      followingDF2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))
      
      # Retrieve who each users is following
      followingNumber = followingDF2$following
      
      # Retrieve who each users followers are
      followersNumber = followingDF2$followers
      
      # Retrieve the number of repositories each user has
      reposNumber = followingDF2$public_repos
      
      # Retrieve the year which each user joined Github
      yearCreated = substr(followingDF2$created_at, start = 1, stop = 4)
      
      # Add users data to a new row in dataframe
      usersDB[nrow(usersDB) + 1, ] = c(followingLogin[j], followingNumber, followersNumber, reposNumber, yearCreated)
      
    }
    next
  }
  # Stop when there are more than 200 users
  if(length(users) > 200)
  {
    break
  }
  next
}

# Use plotly to graph
Sys.setenv("plotly_username"="allenc5")
Sys.setenv("plotly_api_key"="")

# Plot followers v repositories coloured by year
plot1 = plot_ly(data = usersDB, x = ~repos, y = ~followers, 
                text = ~paste("Followers: ", followers, "<br>Repositories: ", 
                              repos, "<br>Date Created:", dateCreated), color = ~dateCreated)
plot1

# Send to plotly
api_create(plot1, filename = "Followers vs Repositories")

# Plot followers v following coloured by year
plot2 = plot_ly(data = usersDB, x = ~following, y = ~followers, text = ~paste("Followers: ", followers, "<br>Following: ", following), color = ~dateCreated)
plot2

# Send to plotly
api_create(plot2, filename = "Followers vs Following")





