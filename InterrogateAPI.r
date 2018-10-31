install.packages("jsonlite")
library(jsonlite)
install.packages("httpuv")
library(httpuv)
install.packages("httr")
library(httr)

oauth_endpoints("github")

myapp <- oauth_app(appname = "CS3012-Github-API",
                   key = "bf688d9a4736906dfdbf",
                   secret = "4773cbdb3197a988a5eda99e128a87d8b4163c6a")

github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)
gtoken <- config(token = github_token)