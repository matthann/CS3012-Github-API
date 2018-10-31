#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)

oauth_endpoints("github")

myapp <- oauth_app(appname = "CS3012-Github-API",
                   key = "bf688d9a4736906dfdbf",
                   secret = "4773cbdb3197a988a5eda99e128a87d8b4163c6a")

# oauth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/jtleek/repos", gtoken)

# take action on http error
shop_for_status(req)

# extract content from a request
json1 = content(req)

# convert to a data.frame 
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# subset data.frame
gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"]

# The code above was sourced from Michael Galarnyk's blog, found at:
# https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08

# -----------------------------------------------------------------------------------

# Step1: Interrogating the GitHub API.  

# The below will return the number of followers and public repositories in my personal GitHub.
myData = fromJSON("https://api.github.com/users/matthann")
myData$followers       # lots 
myData$public_repos

# The below returns specific details about my followers.
myFollowers <- fromJSON("https://api.github.com/users/matthann/followers")
myFollowers$login   # the usernames of all users who follow me 
length <- length(myFollowers$login) # the amount of people who follow me

# The below returns specific details about my repositories.
repositories <- fromJSON("https://api.github.com/users/matthann/repos")
repositories$name # names of my public repositories
repositories$created_at # creation dates of my repositories
assignment <- fromJSON("https://api.github.com/repos/matthann/Python/commits")
assignment$commit$message # the message I included in each commit to my Python repository
