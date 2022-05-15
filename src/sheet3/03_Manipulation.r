
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
  # table_data$lines_del <- as.factor(table_data$lines_del)
  # table_data$lines_add <- as.factor(table_data$lines_add)

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


#' myplot.lines_del.devs.boxplot
#' Plots lines deleted per dev as boxplot
myplot.lines_del.devs.boxplot <- function(tdata, title = "-", ...) {
  return(bwplot(
    tdata$developer ~ log(
      tdata$lines_del + 1, 2
    ),
    aspect = "iso",
    ylab = "Developer",
    xlab = "Lines deleted (log base 2)",
    main = "Developer to lines deleted ratio",
    sub = title,
    ...
  ))
}

#' myplot.lines_add.devs.densityplot
#' plots lines added per dev (log base 2) as densityplot
myplot.lines_add.devs.densityplot <- function(
    tdata,
    title = "-",
    width = 1,
    adjust = 0,
    ...) {
  return(densityplot(
    ~ log(tdata$lines_add + 1, 2) | tdata$developer,
    width,
    # scales = list(draw = FALSE),
    main = "Density Graph of lines added per developer",
    xlab = "Lines added (log base 2)",
    sub = title,
    adjust,
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
  participation_commits <- c(nil = 0,
    sapply(lcom, FUN = function(x) x / total_cmts))

  devcount <- (0:length((ladd)))

  df <- data.frame(
    lines_added = participation_ladd,
    lines_deleted = participation_ldel,
    commits = participation_commits,
    x = devcount
  )

  return(xyplot(
    lines_added + lines_deleted + commits ~ x,
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
#' Interpretation is on sheet pdf
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

myplot.box.test <- function (
  zile = myread.csvdata("src/data/zile.tsv"),
  jikes = myread.csvdata("src/data/jikes.tsv"),
  junit = myread.csvdata("src/data/junit.tsv"),
  junit20 = myread.csvdata("src/data/junit20.tsv")
) {
  zilePlot1 <- myplot.lines_add.devs.boxplot(zile, title = "Zile")
  zilePlot2 <- myplot.lines_del.devs.boxplot(zile, title = "Zile")

  jikesPlot1 <- myplot.lines_add.devs.boxplot(jikes, title = "Jikes")
  jikesPlot2 <- myplot.lines_del.devs.boxplot(jikes, title = "Jikes")
  
  junitPlot1 <- myplot.lines_add.devs.boxplot(junit, title = "JUnit")
  junitPlot2 <- myplot.lines_del.devs.boxplot(junit, title = "JUnit")

  junit20Plot1 <- myplot.lines_add.devs.boxplot(junit20, title = "JUnit20")
  junit20Plot2 <- myplot.lines_del.devs.boxplot(junit20, title = "JUnit20")

  X11(width = 12, pointsize = 6, title = "Boxplots (Zile)")
  print(zilePlot1, split = c(1, 1, 1, 2), more = T)
  print(zilePlot2, split = c(1, 2, 1, 2), more = F)

  X11(width = 12, pointsize = 6, title = "Boxplots (Jikes)")
  print(jikesPlot1, split = c(1, 1, 1, 2), more = T)
  print(jikesPlot2, split = c(1, 2, 1, 2), more = F)

  X11(width = 12, pointsize = 6, title = "Boxplots (JUnit)")
  print(junitPlot1, split = c(1, 1, 1, 2), more = T)
  print(junitPlot2, split = c(1, 2, 1, 2), more = F)

  X11(width = 12, pointsize = 6, title = "Boxplots (JUnit20)")
  print(junit20Plot1, split = c(1, 1, 1, 2), more = T)
  print(junit20Plot2, split = c(1, 2, 1, 2), more = F)
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