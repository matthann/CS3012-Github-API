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
req <- GET("https://api.github.com/users/matthann/repos", gtoken)

# take action on http error
stop_for_status(req)

# extract content from a request
json1 = content(req)

# convert to a data.frame 
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# subset data.frame
gitDF[gitDF$full_name == "matthann/datasharing", "created_at"]

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

# The below returns details about other people's githubs.
healys10 <- fromJSON("https://api.github.com/users/healys10/following")
healys10$login

# Instead of viewing this information in a dataframe, I can convert it back to a JSON

myDataJSon <- toJSON(myData, pretty = TRUE)
myDataJSon


#  ----- Assignment 5: Visualisation with Github Interrogation 

# Gather data required for visualisations

#install.packages("plotly")
require(devtools)
library(plotly)


# usernames that user 'andrew' is following
andrewFollowing = GET("https://api.github.com/users/jtleek/following", gtoken)
andrewFollowingContent = content(andrewFollowing)

# each of those users' data
andrewFollowing.DF = jsonlite::fromJSON(jsonlite::toJSON(andrewFollowingContent))

# usernames saved in a vector
id = andrewFollowing.DF$login
usernames = c(id)

# creation of empty vectors in a data frame
allusers = c()
allusers.DF = data.frame(
  Username = integer(),
  Following = integer(),
  Followers = integer(),
  Repositories = integer(),
  DateCreated = integer()
)

# loop through all usernames to add 
for (i in 1:length(usernames))
{
  # retrieve an individual users following list
  following_url = paste("https://api.github.com/users/", usernames[i], "/following", sep = "")
  following = GET(following_url, gtoken)
  followingContent = content(following)
  
  # skips user if they do not follow anybody
  if (length(followingContent) == 0)
  {
    next
  }
  
  # add followings to a dataframe and retrieve usernames
  following.DF = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
  followingLogin = following.DF$login
  
  # loop through 'following' users
  for (j in 1:length(followingLogin))
  {
    # check that the user is not already in the list of users
    if (is.element(followingLogin[j], allusers) == FALSE)
    {
      # add user to list of users
      allusers[length(allusers) + 1] = followingLogin[j]
      
      # retrieve data on each user
      following_url2 = paste("https://api.github.com/users/", followingLogin[j], sep = "")
      following2 = GET(following_url2, gtoken)
      followingContent2 = content(following2)
      following.DF2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))
      
      # retrieve usernames of each account user is following
      following_number = following.DF2$following
      
      # retrieve each user's followers
      followers_number = following.DF2$followers
      
      # retrieve each user's number of repositories
      repos_number = following.DF2$public_repos
      
      # retrieve year that each user joined Github
      year_created = substr(following.DF2$created_at, start = 1, stop = 4)
      
      # add user's data to a new row in dataframe
      allusers.DF[nrow(allusers.DF) + 1, ] = c(followingLogin[j], following_number, followers_number, repos_number, year_created)
      
    }
    next
  }
  # stop when there are more than 250 users
  if(length(allusers) > 250)
  {
    break
  }
  next
}


# Begin visualisations

# Link Github interrogation visual plots with plot.ly account
Sys.setenv("plotly_username" = "matthann")
Sys.setenv("plotly_api_key" = "2RxIwHTVyLoeHMfu0Kx2")


# Visual 1: Scatter plot of Followers vs. Repositories for each user, colour coded by year they joined GitHub
plot1 = plot_ly(data = allusers.DF, x = ~Repositories, y = ~Followers, 
                  text = ~paste("Followers: ", Followers, "<br>Repositories: ", 
                                Repositories, "<br>Date Created:", DateCreated), color = ~DateCreated)
plot1

api_create(plot1, filename = "Followers vs. Repositories")
# Link: https://plot.ly/~matthann/1/#/


# Visual 2: Scatter plot of Followers vs. Following for each user
plot2 = plot_ly(data = allusers.DF, x = ~Following, y = ~Followers, text = ~paste("Following: ", Following, 
                                                                                  "<br>Followers: ", Followers))
plot2

api_create(plot2, filename = "Followers vs. Following")
# https://plot.ly/~matthann/3/



# information not needed yet 
# colSums(Filter(is.numeric, allusers.DF))


# Visual 3: Bar chart of most popular languages used by each user 

# empty vector 
languages = c()

for (i in 1:length(allusers))
{
  repos_url = paste("https://api.github.com/users/", allusers[i], "/repos", sep = "")
  repos = GET(repos_url, gtoken)
  reposContent = content(repos)
  repos.DF = jsonlite::fromJSON(jsonlite::toJSON(reposContent))
  
  # names of repositories for each individual user
  repos_names = repos.DF$name
  
  # loop through each repository belonging to specific user
  for (j in 1: length(repos_names))
  {
    repos_url2 = paste("https://api.github.com/repos/", allusers[i], "/", repos_names[j], sep = "")
    repos2 = GET(repos_url2, gtoken)
    repos2Content = content(repos2)
    repos2.DF = jsonlite::fromJSON(jsonlite::toJSON(repos2Content))
    
    # language of repository
    language = repos2.DF$language
    
    # skip repository if it has no language
    if (length(language) != 0 && language != "<NA>")
    {
      # add language to list
      languages[length(languages)+1] = language
    }
    next
  }
  next
}

# top 20 languages saved in a table
language_table = sort(table(languages), increasing=TRUE)
language_table_top20 = language_table[(length(language_table)-19):length(language_table)]

# table converted to dataframe
language.DF = as.data.frame(language_table_top20)

# plotting dataframe of languages 
plot3 = plot_ly(data = language.DF, x = language.DF$languages, y = language.DF$Freq, type = "bar")
plot3

api_create(plot3, filename = "20 Most Popular Languages")
# https://plot.ly/~matthann/5/

