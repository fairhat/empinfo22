
is_crayon_available <- require("crayon")
if (!is_crayon_available) {
  cat("\nInstalling crayon because pretty printing is nicer :-)\n")
  install.packages("crayon")
}
library(crayon)


is_lattice_available <- require("lattice")
if (!is_lattice_available) {
  cat("\nInstalling Lattice\n")
  install.packages("lattice")
}
library(lattice)

#' myread.read_file
#' read csv/tsv file as data.frame
#'
#' @param file_path the path string to the file
#' @param header is the first line the column definition?
#' @param separator defaults to tab separator \t
#'
#' @return table as data.frame
myread.read_file <- function(file_path, header = T, separator = "\t") {
  return(read.table(file_path, header = header, sep = separator, as.is = T))
}

#' myread.map_values
#' map values to expected data format
#'
#' @param table_data data.frame returned from myread.read_file
#' @return table_data as transformed data.frame
myread.map_values <- function(table_data) {
  table_data$description <- NULL
  table_data$developerf <- as.factor(table_data$developer)
  table_data$filef <- as.factor(table_data$file)
  table_data$version <- as.factor(table_data$version)
  # timestamp as posix date
  table_data$tstamp2 <- as.POSIXct(table_data$tstamp, tz = "UTC")
  table_data$tstamp3 <- as.numeric(table_data$tstamp2) # timestamp as numeric
  table_data$wday <- factor(sapply(table_data$tstamp2, function(d) {
    (weekdays(d))
  }),
  levels = c(
    "Montag", "Dienstag", "Mittwoch",
    "Donnerstag", "Freitag", "Samstag",
    "Sonntag"
  ),
  labels = c(
    "mon",
    "tue", "wed", "thu", "fri", "sat", "sun"
  )
  ) # timestamp as weekday
  table_data$hour <- factor(
    sapply(as.POSIXlt(table_data$tstamp), function(d) {
      as.numeric(format(strptime(d, "%Y-%m-%d %H:%M:%S"), "%H"))
    }),
    levels = c(0:23)
  )

  return(table_data)
}

#' csvdata
#' Takes a file_path string to a csv/tsv file and returns a data frame
#'
#' @param file_path the path string to the file
#' @param header is the first line the column definition?
#' @param separator defaults to tab separator \t
#'
#' @return data.frame
myread.csvdata <- function(file_path, header = T, separator = "\t") {
  return(myread.map_values(myread.read_file(file_path, header, separator)))
}

#' myread.test (2-1 d)
#' private function to test functionality of myread
#'
myread.test <- function(zile = "src/data/zile.tsv",
                        jikes = "src/data/jikes.tsv",
                        junit = "src/data/junit.tsv",
                        junit20 = "src/data/junit20.tsv",
                        smry = T) {
  data <- myread.csvdata(junit20)
  # return(raw.hours(data))
  return(data)
}

#' get_table
#' private function to get tabular data
get_table <- function(column, fn) {
  tbl <- (tapply(column, column, fn))
  tbl[is.na(tbl)] <- 0

  return(tbl)
}

#' raw.hours
#' get raw hours printed as tabular data
raw.hours <- function(table_data) {
  vals <- get_table(table_data$hour, length)
  cat(red("\n::: Raw Hours \n"))
  cat(red("hour     : "))
  cat(cyan(format(names(vals), width = 4, digits = 4, justify = "right")), "\n")
  cat(red("commits  : "))
  cat(format(unname(vals), width = 4, digits = 4, justify = "left"), "\n")
  # return(vals)
}

#' raw.weekdays
#' get raw weekdays printed as tabular data
raw.weekdays <- function(table_data) {
  vals <- get_table(table_data$wday, length)
  cat(red("\n::: Raw Weekdays \n"))
  cat(red("day      : "))
  cat(cyan(format(names(vals), width = 4, digits = 4, justify = "right")), "\n")
  cat(red("commits  : "))
  cat(format(unname(vals), width = 4, digits = 4, justify = "left"), "\n")
}

#' max.hours
#' get all columns with the highest value in the hourly table
max.hours <- function(table_data) {
  vals <- get_table(table_data$hour, length)
  max_index <- which.max(vals)

  return(vals[vals == vals[max_index]])
}

#'  max.weekdays
#'  get all columns with highest value in the weekday table
max.weekdays <- function(table_data) {
  vals <- get_table(table_data$wday, length)
  max_index <- which.max(vals)

  return(vals[vals == vals[max_index]])
}

#'  min.hours
#' get all columns with the minimum value in the hourly table
min.hours <- function(table_data) {
  vals <- get_table(table_data$hour, length)
  min_index <- which.min(vals)

  return(vals[vals == vals[min_index]])
}

#'  min.weekdays
#' get all columns with minimum value in the weekday table
min.weekdays <- function(table_data) {
  vals <- get_table(table_data$wday, length)
  min_index <- which.min(vals)

  return(vals[vals == vals[min_index]])
}

#' myplot.hours.bars
#' plots hour data as barcharts
#' NOTE: Uses lattice instead of regular plot() since it allows
#' for much more customization (and displaying them in a grid, see myplot.test())
myplot.hours.bars <- function(tdata, title = "-", ...) {
  return(barchart(
    tdata$hour,
    horizontal = F,
    origin = 0,
    reference = T,
    xlab = "Hour of day",
    ylab = "Commits",
    main = "Dev commits across daily hours",
    sub = title,
    ...
  ))
}

#' myplot.wdays.bars
#' plots weekday data as barcharts
#' NOTE: Uses lattice instead of regular plot() since it allows
#' for much more customization (and displaying them in a grid, see myplot.test())
myplot.wdays.bars <- function(tdata, title = "-", ...) {
  return(barchart(
    tdata$wday,
    horizontal = F,
    origin = 0,
    reference = T,
    xlab = "Weekday",
    ylab = "Commits",
    main = "Dev commits per weekday",
    sub = title,
    ...
  ))
}

#' myplot.lines_add.devs.boxplot
#' Plots lines added per dev (log base 2) as boxplot
myplot.lines_add.devs.boxplot <- function(tdata, title = "-", ...) {
  return(bwplot(
    tdata$developer ~ log(
      tdata$lines_add + 1, 2
    ),
    # scales = list(draw = FALSE),
    aspect = "iso",
    ylab = "Developer",
    xlab = "Lines added (log base 2)",
    main = "Developer to lines added ratio",
    sub = title,
    ...
  ))
}


#' myplot.lines_add.devs.boxplot
#' Plots lines added per dev (log base 10) as boxplot
myplot.lines_add.devs.boxplot_alt <- function(tdata, title = "-", ...) {
  return(bwplot(
    tdata$developer | (
      tdata$lines_add
    ),
    # scales = list(draw = FALSE),
    aspect = "iso",
    ylab = "Developer",
    xlab = "Lines added (log base 10)",
    main = "Developer to lines added ratio",
    sub = title,
    ...
  ))
}

#' myplot.lines_add.devs.densityplot
#' plots lines added per dev (log base 2) as densityplot
myplot.lines_add.devs.densityplot <- function(tdata, title = "-", ...) {
  return(densityplot(
    ~ log(tdata$lines_add + 1, 2) | tdata$developer,
    width = 1,
    # scales = list(draw = FALSE),
    main = "Density Graph of lines added per developer",
    xlab = "Lines added (log base 2)",
    sub = title,
    ...
  ))
}

myplot.participation <- function(tdata, title = "-", ...) {
  ladd <- cumsum(
    sort(
      tapply(tdata$lines_add, tdata$developerf, sum),
    decreasing = T)
  )

  ldel <- cumsum(
    sort(
      tapply(tdata$lines_del, tdata$developerf, sum),
    decreasing = T)
  )

  lcom <- cumsum(
    sort(
      tapply(tdata$developerf, tdata$developerf, length),
      decreasing = T
    )
  )

  total_ladd <- tail(ladd, n = 1)
  total_ldel <- tail(ldel, n = 1)
  total_cmts <- tail(lcom, n = 1)

  participation_ladd <- c(nil = 0,
    sapply(ladd, FUN = function(x) x / total_ladd))
  participation_ldel <- c(nil = 0,
    sapply(ldel, FUN = function(x) x / total_ldel))
  participation_delta <- c(nil = 0,
    sapply(lcom, FUN = function(x) x / total_cmts))

  devcount <- (0:length((ladd)))

  df <- data.frame(
    lines_added = participation_ladd,
    lines_deleted = participation_ldel,
    delta = participation_delta,
    x = devcount
  )

  return(xyplot(
    lines_added + lines_deleted + delta ~ x,
    data = df,
    type = c("p", "l"),
    auto.key = T,
    main = title,
    lty = 1:3,
    xlab = "Individuals",
    ylab = "Participation",
    ...
  ))
}

#' myplot.participation.test
#' 3-2 (d)
#' INTERPRETATION:
#' we can see on zile that
#' ~80% of contributions (lines added, deleted and commit count)
#' was done by just one developer which we can classify as lead developer(?)
#'
#' For Jikes, which has the highest individual count (8), we see that
#' the lead developer amounts for ~70% of lines added and deleted
#' but only 45% of commits. So we can conclude that many of the
#' remaining contributors have worked on small issues and
#' minor changes while the first 3 devs are working on over 80% of the codebase
#' and 90% of the lines added and deleted
#'
#' JUnit has the highest diversity in participation:
#' The lead developer has the highest commit count (over 60%),
#' but only amounts for less than 50%
#' of lines added and just above 50% of lines deleted.
#' But even in this case the two most active devs have
#' over 80%  total contribution and slightly over 70% of lines added and deleted
#' So ~30% of devs amount for over 70% of the work
#'
#' Junit20 is a very small sample size compared
#' to the other projects and it basically
#' looks like it's a single developer doing over 80% of the work
#'
#' Interpretation of all results:
#' From the given open source projects we can conclude that
#' the most active 1-3 developers in a project
#' amount for at least 70% of the work being done.
#' This is true for commit count, total lines added and total lines deleted
#' However given the small sample size (4 projects) and also the small amount
#' of developers (4.5 on avg, minimum of 2 and maximum of 8) we don't know if
#' this would be true for bigger oss projects (in terms of dev count)
myplot.participation.test <- function (
      zile = myread.csvdata("src/data/zile.tsv"),
      jikes = myread.csvdata("src/data/jikes.tsv"),
      junit = myread.csvdata("src/data/junit.tsv"),
      junit20 = myread.csvdata("src/data/junit20.tsv")) {
  X11(width = 12, pointsize = 6, title = "Participation plots")
  zilePlot <- myplot.participation(zile, title = "Zile Participation")
  jikesPlot <- myplot.participation(jikes, title = "Jikes Participation")
  junitPlot <- myplot.participation(junit, title = "JUnit Participation")
  junit20Plot <- myplot.participation(junit20, title = "JUnit20 Participation")

  print(zilePlot, split = c(1, 1, 2, 2), more = T)
  print(jikesPlot, split = c(2, 1, 2, 2), more = T)
  print(junitPlot, split = c(1, 2, 2, 2), more = T)
  print(junit20Plot, split = c(2, 2, 2, 2), more = F)
}

#' myplot.test
#' Internal test function which reads all files and spawns
#' a window for each with all 4 plots
#' NOTE: Spawns 4 windows(!)
myplot.test <- function(zile = myread.csvdata("src/data/zile.tsv"),
                        jikes = myread.csvdata("src/data/jikes.tsv"),
                        junit = myread.csvdata("src/data/junit.tsv"),
                        junit20 = myread.csvdata("src/data/junit20.tsv")) {
  ## ZILE
  zilePlot1 <- myplot.hours.bars(zile, title = "Zile")
  zilePlot2 <- myplot.wdays.bars(zile, title = "Zile")
  zilePlot3 <- myplot.lines_add.devs.boxplot(zile, title = "Zile")
  zilePlot4 <- myplot.lines_add.devs.densityplot(zile, title = "Zile")

  X11(width = 12, pointsize = 6, title = "Zile Plots")
  print(zilePlot1, split = c(1, 1, 2, 2), more = T)
  print(zilePlot2, split = c(2, 1, 2, 2), more = T)
  print(zilePlot3, split = c(1, 2, 2, 2), more = T)
  print(zilePlot4, split = c(2, 2, 2, 2), more = F)

  ## JIKES
  jikesPlot1 <- myplot.hours.bars(jikes, title = "Jikes")
  jikesPlot2 <- myplot.wdays.bars(jikes, title = "Jikes")
  jikesPlot3 <- myplot.lines_add.devs.boxplot(jikes, title = "Jikes")
  jikesPlot4 <- myplot.lines_add.devs.densityplot(jikes, title = "Jikes")

  X11(width = 12, pointsize = 6, title = "Jikes Plots")
  print(jikesPlot1, split = c(1, 1, 2, 2), more = T)
  print(jikesPlot2, split = c(2, 1, 2, 2), more = T)
  print(jikesPlot3, split = c(1, 2, 2, 2), more = T)
  print(jikesPlot4, split = c(2, 2, 2, 2), more = F)

  ## JUNIT
  junitPlot1 <- myplot.hours.bars(junit, title = "JUnit")
  junitPlot2 <- myplot.wdays.bars(junit, title = "JUnit")
  junitPlot3 <- myplot.lines_add.devs.boxplot(junit, title = "JUnit")
  junitPlot4 <- myplot.lines_add.devs.densityplot(junit, title = "JUnit")

  X11(width = 12, pointsize = 6, title = "JUnit Plots")
  print(junitPlot1, split = c(1, 1, 2, 2), more = T)
  print(junitPlot2, split = c(2, 1, 2, 2), more = T)
  print(junitPlot3, split = c(1, 2, 2, 2), more = T)
  print(junitPlot4, split = c(2, 2, 2, 2), more = F)

  ## JUNIT20
  junit20Plot1 <- myplot.hours.bars(junit20, title = "JUnit20")
  junit20Plot2 <- myplot.wdays.bars(junit20, title = "JUnit20")
  junit20Plot3 <- myplot.lines_add.devs.boxplot(junit20, title = "JUnit20")
  junit20Plot4 <- myplot.lines_add.devs.densityplot(junit20, title = "JUnit20")

  X11(width = 12, pointsize = 6, title = "JUnit20 Plots")
  print(junit20Plot1, split = c(1, 1, 2, 2), more = T)
  print(junit20Plot2, split = c(2, 1, 2, 2), more = T)
  print(junit20Plot3, split = c(1, 2, 2, 2), more = T)
  print(junit20Plot4, split = c(2, 2, 2, 2), more = F)
}