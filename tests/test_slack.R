slack <- source("Library/utilities/slack_messenger.R")$value

slack$message("test message")
slack$alert("test alert")
slack$error("test error")


