turtles-own
  [Malade? ;; Est-ce que la turtle est malade
  Incubateur? ;; Est-ce que la turtle est en train d'incuber le virus, elle n'est pas encore malade
  En_quarantaine? ;; Est-ce que la turtle a été placée en quarantaine (clinique ou à la maison)
  Guerit? ;; Est-ce que la turtle a été malade et a guérit
  Vivant?  ;; Est-ce que la turtle est vivante. Ne pas tuer les turtles permet de calculer le taux de décès par maladie
  TempsIncubation ;; Combien de temps la turtle incube le virus, à la fin de ce temps, elle peut tomber malade
  TempsMaladie ;; Combien de temps la turtle est malade, à la fin de ce temps, elle peut guérir ou mourir
]

globals
[ ;;Population
  %Susceptibles ;; S(t) : la turtle peut attraper et incuber le virus (not Malade, not Incubateur, not En_quarantaine, not Guerit, Vivant)
  %StayAtHome ;; H(t) : la turtle reste à sa maison (not Malade, not Incubateur, En_quarantaine, not Guerit, Vivant)
  %Incubating ;; E(t) : la turtle incube le virus, elle n'est pas encore malade (not Malade, Incubateur, En_quarantaine and not En_quarantaine, not Guerit, Vivant)
  %InfectiouslyInfected ;; I(t) : la turtle est tombée malade (Malade, not Incubateur, not En_quarantaine, not Guerit, Vivant)
  %IsolatedClinical ;; Q(t) : la turtle est incube le virus ou est malade. Elle est isolée cliniquement (Malade (or not Malade), not Incubateur (or Incubateur), En_quarantaine, not Guerit, Vivant)
  %Recovery ;; R(t) : la turtle a guérit de la maladie (not Malade, not Incubateur, not En_quarantaine, Guerit, Vivant)
  %DiseaseDeath ;; D(t) : la turtle a succombée à la maladie (not Malade, not Incubateur, not En_quarantaine, not Guerit, not Vivant)

  ;;Autres
  ended-simulation? ;; est-ce que la simulation est finie, c'est-à-dire, que plus aucune tortue n'incube la maladie, n'est malade et n'est isolée cliniquement (voir plus loin)
  duree_incubation
  duree_maladie

  ;; Calcul R0
  Phi ;; Sigma + Eta + Mu (voir description dans l'interface)
  Xi ;; Alpha + Gamma + Mu (voir description dans l'interface)
  Psi ;; Mu + Teta + Teta0 (voir description dans l'interface)
  R0 ;; (Beta * Sigma ( Mu + Teta0)) / Phi * Xi * Psi
]

to setup
  ca ;; clear all
  crt Population ;; Créer la population selon le nombre choisi
  setup_constantes ;; Initialiser les constantes ended-simulation, duree_incubation, duree_maladie
  ask turtles
  [ position_aleatoire ;; placer les turtles aléatoirement
    set color green ;; Initialement, toutes les turtles sont susceptibles d'être malades, donc vertes
    set shape "person"
    set Malade? false ;; Intialement, une turtle n'est pas malade
    set Incubateur? false ;; Initialement, une turtle n'incube pas
    set En_quarantaine? false ;; Initialement, une turtle n'est pas en quarantaine
    set Guerit? false ;; Initialement, une turtle n'a jamais été malade et donc n'a pas guérit de la maladie
    set Vivant? true ;; Une turtle est vivante
    ]
  ask n-of (0.1 * Population) turtles ;; On demande à 10% de la population des turtles d'êtres malades (les premiers cas)
    [ set Malade? true
      set color red ]
end

to setup_constantes ;; Initialiser les constantes ended-simulation, duree_incubation, duree_maladie
  set ended-simulation? false
  set duree_incubation (1 / Sigma ) ;; Voir le modèle : durée moyenne de l'incubation
  set duree_maladie (1 / Gamma) ;; Voir le modèle : durée moyenne de la maladie
end

to MAJ_globals ;; Pour acutaliser le pourcentage de chaque population (susceptibles, à la maison, incubant, malade, isolée cliniquement, guérit, mort dûe maladie)
   if count turtles > 0
    [ set %Susceptibles (count turtles with [not Malade? and not Incubateur? and not Guerit? and not En_quarantaine? and Vivant? and not Guerit?] / count turtles ) * 100
      set %StayAtHome (count turtles with [En_quarantaine? and (not Malade? or not Incubateur?) and Vivant? and not Guerit?] / count turtles ) * 100
      set %Incubating (count turtles with [not En_quarantaine? and Incubateur? and Vivant? and not Guerit?]  / count turtles ) * 100
      set %InfectiouslyInfected (count turtles with [Malade? and Vivant? and not Guerit?]  / count turtles ) * 100
      set %IsolatedClinical (count turtles with [En_quarantaine? and (Malade? or Incubateur?) and Vivant? and not Guerit?]  / count turtles ) * 100
      set %Recovery (count turtles with [Guerit? and Vivant?]  / count turtles ) * 100
      set %DiseaseDeath (count turtles with [not Vivant? and Malade?]  / count turtles ) * 100

      ;;vérifier s'il y a encore des personnes malades, isolées cliniquement ou incubant, pour arrêter la simulation s'il n'y en a plus
      set ended-simulation? %Incubating + %InfectiouslyInfected + %IsolatedClinical = 0 ]
end

to MAJ_variables
  ask turtles
    [ if En_quarantaine? and (not Malade? or not Incubateur?) and Vivant? and not Guerit? [set color violet] ;; "StayAtHome"
      if not En_quarantaine? and Incubateur? and Vivant? and not Guerit? [set color yellow] ;; "Incubating"
      if En_quarantaine? and (Malade? or Incubateur?) and Vivant? and not Guerit? [set color orange] ;; "IsolatedClinical"
      if not Vivant? [set color black] ;; "DiseaseDeath" et les personnes décédées "naturellement"
      if Guerit? and Vivant? [set color blue] ;; "Recovery"
      if Malade? and not En_quarantaine? and Vivant? and not Guerit? [set color red] ;; "InfectiouslyInfected"
  ]
end

to go
  if not ended-simulation? ;; On vérifie qu'il y a toujours des malades, incubant ou isolés cliniquement
  [ MAJ_globals ;; On actualise les pourcentages de population
    MAJ_variables ;; On actualise la couleur des tortues, en fonction de leur catégorie de population
    ask turtles [
      vieillir ;; (voir procédure vieillir) On regarde si la turtle décéde de mort "naturelle"
      ;; Si la turtle est malade ou incube, on diminue son temps temps de maladie ou d'incubation
      avance ;; on fait avancer la turtle d'un pas
      calcul_R0

      if not En_quarantaine? and (not Malade? or not Incubateur? or not Guerit?) and Vivant? and not Guerit? [MiseEnQuarantaine] ;; Si la turtle est susceptible, elle peut rester à la maison
      if not En_quarantaine? and (not Malade? or not Incubateur? or not Guerit?) and Vivant? and not Guerit? [Infection] ;; Si la turtle est susceptible, elle peut attraper le virus
      if En_quarantaine? and (not Malade? or not Incubateur?) and Vivant? and not Guerit? [SortirQuarantaine] ;; Si la turtle est à la maison, elle peut sortir de son confinement
      if not En_quarantaine? and Incubateur? and Vivant? and not Guerit? [MaladeSansQuarantaine] ;; Si la turtle incube le virus, elle peut tomber malade
      if not En_quarantaine? and Incubateur? and Vivant? and not Guerit? [IncubateurEnQuarantaine] ;; Si la turtle incube le virus, elle peut être confinée cliniquement
      if Malade? and not En_quarantaine? and Vivant? and not Guerit? [MaladeEnQuarantaine] ;; Si la turtle est malade, elle peut être confinée cliniquement
      if ((Malade? and not En_quarantaine?) or ((Malade? or Incubateur?) and En_quarantaine?)) and Vivant? and not Guerit? [GuerirOuMourir] ;; Si la turtle est malade ou incube, elle peut guérir ou décédée de la maladie


      ;; Modélisation du graphique
      set-current-plot "Evolution de la population"
      set-current-plot-pen "susceptibles"
      plot %Susceptibles
      set-current-plot-pen "satyathome"
      plot %StayAtHome
      set-current-plot-pen "incubating"
      plot %Incubating
      set-current-plot-pen "infectiouslyinfected"
      plot %InfectiouslyInfected
      set-current-plot-pen "isolatedclinical"
      plot %IsolatedClinical
      set-current-plot-pen "recovery"
      plot %Recovery
      set-current-plot-pen "diseasedeath"
      plot %DiseaseDeath

    ]

  ]
end

;; Calcul R0
to calcul_R0
  set Phi Sigma + Eta + Mu
  set Xi Alpha + Mu + Gamma
  set Psi Mu + Teta + Teta0

  set R0 (Beta * Sigma * ( Mu + Teta0 )) / (Phi * Xi * Psi)
end

;; CHANGEMENTS D'ETATS
to vieillir ;; On regarde si la turtle décéde de mort "naturelle"
    if random-float 1  < Mu [set Vivant? false]
    if Incubateur? [set TempsIncubation TempsIncubation - 1] ;; Si la turtle incube, on fait diminuer son temps d'incubation
    if Malade? [set TempsMaladie TempsMaladie - 1] ;; Si la turtle est malade, on fait diminuer son temps de maladie
end

to EntrerQuarantaine ;; On place la turtle en quarantaine
  set En_quarantaine? true
end

to SortirQarantaine ;; On sort la turtle ded quarantaine
  set En_quarantaine? false
end

to Incuber ;; La turtle se met à incuber le virus pour la prochaine période TempsIncubation
  set Incubateur? true
  set TempsIncubation random duree_incubation
end

to DevenirMalade ;; La turtle n'incube plus mais est désormais malade, pour la prochaine période TempsMaladie
  set Incubateur? false
  set Malade? true
  set TempsMaladie random duree_maladie
end

to Guerir ;; La turtle est guérie, elle n'est plus malade, elle n'a plus besoin d'être en quarantaine et n'incube pas non plus
  set Malade? false
  set Guerit? true
  set En_quarantaine? false
  set Incubateur? false
end

to Mourir ;; La turtle décéde, elle n'est plus, et donc plus en quarantaine. On met la turtle malade afin de différencier les morts du virus, et compter le porcentage, des morts naturelles
  set Malade? true
  set Vivant? false
  set Incubateur? false
  set En_quarantaine? false
end


;; CHANGEMENTS DE POPULATION
;; Susceptibles à StayAtHome
to MiseEnQuarantaine ;; Si la turtle est susceptible, elle a Teta chances d'être mise en quarantaine
  if not En_quarantaine? and (not Malade? or not Incubateur? or not Guerit?) and Vivant? and not Guerit?
   [ if random-float 1 < Teta
      [EntrerQuarantaine]]
end

;; StayAtHome à Susceptibles
to SortirQuarantaine ;; Si la turtle est en quarantaine, elle a Teta0 chances de sortir de quarantaine
  if En_quarantaine? and (not Malade? or not Incubateur?) and Vivant? and not Guerit?
   [ if random-float 1 < Teta0
      [SortirQarantaine]]
end

;; Susceptibles à Incubating
to Infection ;; Si la turtle est susceptible, elle a Beta chances d'attraper le virus et de se mettre à incuber le virus
  if not En_quarantaine? and (not Malade? or not Incubateur? or not Guerit?) and Vivant? and not Guerit?
   [ if random-float 1 < Beta
      [Incuber]]
end

;; Incubating à InfectiousloyInfected
to MaladeSansQuarantaine ;; Si la turtle incube le virus, elle a Sigma chances de tomber malade
  if not En_quarantaine? and Incubateur? and Vivant? and not Guerit? and (TempsIncubation < 1 )
  [ if random-float 1 < Sigma
    [DevenirMalade]]
end

;;Incubating à IsolatedClinical
to IncubateurEnQuarantaine ;; Si la turtle incube le virus, elle a Eta chances d'être mise en quarantaine clinique
  if not En_quarantaine? and Incubateur? and Vivant? and not Guerit? and (TempsIncubation < 1)
      [if random-float 1 < Eta
        [EntrerQuarantaine]]
end

;; InfectiousloyInfected à IsolatedClinical
to MaladeEnQuarantaine ;; Si la turtle est malade, elle a Alpha chances d'être mise en quarantaine clinique
  if Malade? and not En_quarantaine? and Vivant? and not Guerit? and (TempsMaladie < 1)
    [if random-float 1 < Alpha
      [EntrerQuarantaine]]
end

;; InfectiousloyInfected ou IsolatedClinical à Recovery ou DiseaseDeath
to GuerirOuMourir ;; Si la turtle est malade (ou incube), elle a K1*Gamma (K2*Gamma) chances de guérir et (1-K1)*Gamma ((1-K2)*Gamma) de mourir
  if Malade? and not En_quarantaine? and Vivant? and not Guerit? and (TempsMaladie < 1)
    [ifelse random-float 1 < K1 * Gamma
      [Guerir] [if random-float 1 < ( 1 - K1 ) * Gamma  [Mourir]]]

  if ((Malade? and (TempsMaladie < 1)) or (Incubateur? and (TempsIncubation < 1))) and En_quarantaine? and Vivant? and not Guerit?
    [ifelse random-float 1 < K2 * Gamma
      [Guerir] [if random-float 1 < ( 1 - K2 ) * Gamma  [Mourir]]]
end


;; POSITION de la turtle
to position_aleatoire ;;positionne de manière aléatoire la tortue
  set xcor random-float world-width
  set ycor random-float world-height
end

to avance ; fait avancer la tortue d'un pas de manière aléatoire, si elle est vivante
  if Vivant?
  [rt random-float 50
  lt random-float 50
    fd 1]
end
@#$#@#$#@
GRAPHICS-WINDOW
345
10
711
377
-1
-1
10.85
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
41
34
104
67
Start
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
108
33
171
66
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
28
84
186
117
Population
Population
0
1000
1000.0
1
1
NIL
HORIZONTAL

SLIDER
25
158
183
191
Beta
Beta
0
1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
25
350
185
383
Sigma
Sigma
0
1
0.19
0.01
1
NIL
HORIZONTAL

SLIDER
28
474
185
507
Alpha
Alpha
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
31
701
188
734
Mu
Mu
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
30
645
184
678
K2
K2
0
0.99
0.9
0.01
1
NIL
HORIZONTAL

SLIDER
29
585
182
618
K1
K1
0
0.99
0.9
0.01
1
NIL
HORIZONTAL

PLOT
343
389
935
752
Evolution de la population
Temps
% Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"susceptibles" 1.0 0 -14439633 true "" ""
"satyathome" 1.0 0 -10141563 true "" ""
"incubating" 1.0 0 -1184463 true "" ""
"infectiouslyinfected" 1.0 0 -5298144 true "" ""
"isolatedclinical" 1.0 0 -3844592 true "" ""
"recovery" 1.0 0 -13345367 true "" ""
"diseasedeath" 1.0 0 -16777216 true "" ""

SLIDER
24
289
183
322
Teta0
Teta0
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
29
531
184
564
Gamma
Gamma
0
1
0.07
0.01
1
NIL
HORIZONTAL

MONITOR
242
35
299
92
NIL
R0
2
1
14

TEXTBOX
28
123
313
164
Taux de contact des personnes susceptibles avec des contagieux
14
0.0
1

TEXTBOX
27
199
268
233
Taux de personne en quarantaine
14
0.0
1

TEXTBOX
28
257
290
293
Taux de personnes sortant de quarantaine à cause de l'inefficacité de la quarantaine
14
0.0
1

TEXTBOX
28
330
320
348
Probabilité qu'un infecté devienne malade
14
0.0
1

TEXTBOX
28
393
316
427
Taux d'isolement des personnes susceptibles
14
0.0
1

TEXTBOX
29
456
249
474
Taux d'isolement des malades
14
0.0
1

TEXTBOX
33
682
183
700
Taux de mortalité
14
0.0
1

TEXTBOX
31
568
313
586
Probabilité de guérir d'une personne malade
14
0.0
1

TEXTBOX
32
627
385
645
Probabilité de guérir d'une personne malade isolée
14
0.0
1

TEXTBOX
34
514
411
532
Taux de passage de malade à guérit ou décédé
14
0.0
1

SLIDER
26
416
186
449
Eta
Eta
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
27
224
185
257
Teta
Teta
0
1
0.0
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
