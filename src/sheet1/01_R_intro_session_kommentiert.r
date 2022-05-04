## Kommentare: Ferhat Topcu

### Beispiel für Ausdruckskraft: Häufigkeit von k Richtigen beim Lotto

lotto = replicate(3, sample(1:49, 6))	# 3 maliges Stickprobeziehen:

lotto                   # Ausgabe

lotto = replicate(100000, sample(1:49, 6))  # 100000 mal ziehen bzw. 100000 Tipps
ziehung = sample(1:49, 6)                   # und z.B. die Mittwochsziehung

freq = table(apply(lotto, 2, function(x) sum(x %in% ziehung)))  # auswerten

freq                            # mal schauen wer gewonnen hat
barplot(freq)                   # als plot
?sample

### elementare Ausdrücke:
3+4 ## addition
3*4 ## multiplikation
3**4 ## potenzierung
3/4 ## division
10%%3 ## modulo
sqrt(2) ## quadratwurzel

### Variablen:
x = 3; y = 4 ## definition + initialisierung
x+y ## addition von variablen
y <- 10 ## neue wertzuweisung nach initialiserung
y ## ausgabe / return


### Modes: numeric character logical
## Mode scheint den Datentyp oder Objekttyp der Eingabe wiederzugeben als string
## Vergleichbar mit funktionen wie "typeof" in Javascript oder "type()" in python
mode(3+4) 
mode("3+4")
mode(3+4 == 5)
3+4 == 5
T
F

### Vektoren und Vektorarithmetik
x = c(1,2,3,8,9,10) ## definition und initialisierung eines vektors
x ## ausgabe
y = c(2,2,3,2,3,4)  ## definition und initialisierung eines vektors
y ## ausgabe
x+y ## vektoraddition
x-y ## -- subtraktion 
x*y ##  Multiplikation: vektor1[i] * vektor2[i] = vektor3[i]
x/y ## Division: vektor1[i] / vektor2[i] = vektor3[i]
x*c(1,2) ## siehe Multiplikation
c() ## Nullvektor (NULL)
rep(c(5,7), 3) ## Repeat Vektor [5,7] 3 mal -> [5,7]:[5,7]:[5,7] -> [5,7,5,7,5,7]
5:10 ## erstelle Vektor von 5 bis 10 aufsteigend (inklusiv)
10:5 ## erstelle Vektor von 10 bis 5 absteigend (inklusiv)
seq(from=5, along=y) ## erstelle Vektor von (from=) Anfangswert mit Länge (along=) eines anderen Vektors
seq(from=5, along=c()) ## siehe zeile darüber, aber da Länge 0 (NULLVektor) ist, ist das Ergebnis 0
length(x) ## Gibt Länge (anzahl Elemente) eines Vektors wieder

### Vektorindizierung
x
y
x[6]
y[6] ## bekannte indizierung, element = liste[i]
x[y] ## Versteh ich nicht, wann soll das, was da rauskommt nützlich sein?
## Vermutlich bedeutet x[y] dass nur die Werte aus X genommen werden, die als indizes in Y (wobei index = wert in Y) vorkommen
## also y = c(1,4,5); x = c(1,2,3,4,5,6,7,8) würde bei x[y] = x[1]:x[4]:x[5] bedeuten?
y >= 3 ## Map liste nach booleschen Werten (vgl. map xs (x -> x >= 3))
y[y>=3] ## Filtert liste nach der angebenen Kondition (filter xs (x -> x >= 3))
x[-2] ## entfernt element an position i (x[-i])
x[-y] ## versteh ich genauso wenig wie x[y], aber vermutlich alle Werte aus Y werden als Indizes aus X entfernt

#Uebung:Hole jedes zweite Element eines langen Vektors
x[2*(1:(length(x)/2))] ## x[(2,4,6)]; konstruiert einen vektor in der halben länge von x und fügt nur gerade zahlen hinzu -> Jedes zweite Element wird aus X entnommen
x[c(F,T)] ## eigentlich hätte ich erwartet, dass nur das zweite Element aus X genommen wird, aber anscheinend wird c(F,T) so lange wiederholt, bis jedes Element aus X geprüft wurde

### Matrizen
x = c(4,5,6) ## Vektor
y = c(7,8,9) ## Vektor
cbind(x,y) ## Kombiniere Vektoren als Spalten in einer Matrix
matr = rbind(x,y) ## Kombiniere Vek als Zeilen in einer Matrix
matr
nrow(matr)  ## Anzahl Zeilen in der Matrix
ncol(matr) ## Anzahl Spalten
dim(matr) ## Dimension (Zeilen, Spalten) der Matrix
attr(matr,"dim") ## Zugriff auf Dimension über das Attribut anstatt der direkten funktion dim()
attributes(matr) ## Ausgabe aller Attribute eines Matrix Objekts
matr[2,1] ## Matrixindizierung [Reihe, Spalte]
matr[,2] ## Matrixindizierung ganze Spalte [, Spalte]
matr[,-2] ## Matrix ohne die Spalte i [], -i]
matr[,c(1,3)] ## Matrix mit den Spalten aus Vektor (1,3) -> [,(1, 3)]
matr["x",] ## Ausgabe des Vektors X (in diesem Fall Zeile X)
matr[2] ## Matrixindizierung mit gleicher Spalte und Zeile (Shorthand für [i,i] )
as.vector(matr)

### Listen:
xy=list(eins=x,zwei=y) ## Initialisierung einer 2dimensionalen Liste aus Vektoren (Elemente können über index und namensattribut abgerufen werden)
xy
mode(xy) ## siehe mode oben
names(xy) ## namensindizes der einzelnen Elemente
xy[2] ## indizierung der liste über zahlenindex
xy[[2]] ## Keine Ahnung, aber vermutlich genau das selbe wie in der Zeile davor
xy[["zwei"]] ## Indizierung über Namensattribut
xy$zwei ## Indizierung über Namensattribut alternative Schreibweise
mode(xy$zwei) ## "Numeric", in diesem Fall ein Vektor da xy$zwei == y -> mode(y) == mode(xy$zwei)
?"[" ## Ach verstehe [[]] kann mehrere Elemente extrahieren
list(eins=5:9, zwei="ein String", raetsel=matr) ## Eine Liste mit drei Elementen (ein Vektor, ein String und eine Matrix)
as.data.frame(xy) ## konvertiert die liste in ein Data Frame
as.list(as.data.frame(xy)) ## Konvertiert es in ein Data Frame und wieder zurück in eine liste
attributes(as.data.frame(xy)) ## Gibt die Attribute eines Data Frame objekts wieder

### Objektorientierung (angedeutet):
methods("print") ## Gibt alle Methoden eines Objekts (in diesem Fall print) wieder

### besondere Werte: Inf NaN NA NULL
3/0 
Inf-Inf
NA
nana = x; nana[8] = 66; nana ## "life is life"; nana = c(); nana[7] = ".";nana;
c()

### Schleifen sind nur selten nötig:
xy
lapply(xy, sum) ##  mappt werte in xy mit der funktion sum (sum wird auf alle werte angewandt)
sapply(xy, sum) ## das gleiche wie lapply nur ancsheinend in simpler
xy=rbind(xy$eins, xy$zwei) ## siehe cbind
xy
apply(xy, 1, sum) ## summe der jeweiligen zeilen in xy
apply(xy, 2, sum) ## summe der jeweiligen spalten in xy

### Funktionen:
jitter(xy) ## ändert werte in xy mit zufälligen kleinen abweichungen (streuung)
jitter
legal.level = function(dat, levels=5) dat>=1 && dat<=levels && dat==trunc(dat) ## definiert eine funktion legal.level, die zulässige werte prüft
## levels ist optionaler parameter mit default wert 5
## Wert muss größer gleich 1, kleiner = levels (bzw 5 bei fehlender angabe) und wert muss ganzzahlig sein (keine Nachkommastellen)
legal.level(4) ## legal.level(4,5) => TRUE
legal.level(6) ## legal.level(6,5) => FALSE, da 6 > 5
legal.level(4.1) ## legal.level(4.1, 5) -> FALSE, da dat == trunc(dat) => 4.1 == trunc(4.1) <=> 4.1 == 4.0 !=> FALSE
x
legal.level(x) ## Inkompatible Datentypen werden logisch verglichen (Vektor mit Zahl)
c(T,F) && T ## ...??? 
c(T,F) & T ## ...??? konnte den Unterschied nicht finden, aber verstehe, dass man mit & datentypen implizit casten kann um sie zu vergleichen?
legal.level = function(dat, levels=5) dat>=1 & dat<=levels & dat==trunc(dat)
legal.level(x)
xy=rbind(x,y)
apply(xy, 1, function(x, lev) all(legal.level(x,lev)), lev=7)

### Dokumentation:
?sample
help("sample")
args(sample)
help.search("sample")
help.start()

### Ende:
q() ## Bye!
