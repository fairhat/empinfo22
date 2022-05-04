ANSI_RESET  <- "\u001B[0m"
ANSI_RED    <- "\u001B[31m"
ANSI_GREEN  <- "\u001B[32m"
ANSI_YELLOW <- "\u001B[33m"
ANSI_CYAN   <- "\u001B[36m"

yellow <- function(str) paste(ANSI_RED, str, ANSI_RESET)
cyan <- function(str) paste(ANSI_CYAN, str, ANSI_RESET)
green <- function(str) paste(ANSI_GREEN, str, ANSI_RESET)
red <- function(str) paste(ANSI_RED, str, ANSI_RESET)