; Code overview:
; The Interface can show various land features and always has farm locations, the show buttons swap between them.
; go currently does nothing

globals [
  total-profit; arbitray money unit
  max-scale
  show-type
  max-cell-prof; arbitray money unit
  max-cell-dist; arbitray money unit
  max-dev-cost ; arbitray money unit
  temp ; celsius
  SLR-rate ; meters per year
]

; Farm Organisation variables, these are decision-making parameters (placeholders)
; risk-aversion: The threshold/probability of the organisation abandoning farms that have a low profit/loss value
; sim-dist: How many steps ahead the organisation looks when making choices
; profit-incentive: How much the organisation prioritises profit in investing/expanding
; climate-awareness: How much, if any, of the impact of climate is included in future prediction simulation
breed [farm-orgs farm-org]
farm-orgs-own [
  sim-dist ; how far they look ahead in units of quarter year
  sell-bonus ; multiplier on food sold
  dev-discount ; discount on development (works as multiplier less than 1)
  org-upkeep-cost ; arbitray money unit
  profit-threshold ;  average quarterly profit of farm required for it to be bought
  time-btw-buy ; quarter years between new farms being built
  total-agri ; arbitray unit of agriculture
  org-color
  money ; arbitrary unit of currency
]

; Farm variables, these are what features individual farms have
; scale: farm size, how much has been invested, increased by a set amount if decided to invest
; upkeep-cost: How much the farm costs each step, increases based on size, location and damages
breed [farms farm]
farms-own [
  scale ; size of icon
  profit ; arbitray unit of currency
  upkeep-cost ; arbitray unit of currency
  farm-bonus ; arbitray unit of currency
  in-use ; whether or not the farm has been abandoned
]

; Features of land patches
; altitude: hight above sea level
; dist-from-sea: ...
; quality: how good it is for growing crops, affects profit, affected by climate impact
; dev-cost: How much it costs to place a farm on it
patches-own [
  altitude ; distance above sea level in meters
  dist-from-sea ; distance from coastline in meters
  base-quality ; multiplier on farm output representing arbitrary variation in land
  dev-cost ; h
]


to setup
  ; general initialization
  clear-all
  reset-ticks

  set SLR-rate SLR-rate-0

  ; initialize agents
  setup-patches

  set temp starting-temp
  set max-cell-prof (max [pred-prof 0 0 1] of patches)
  set max-dev-cost (max [dev-cost] of patches)
  set show-type "profitability"


  set-default-shape farms "house"
  set max-scale 2
  set show-type "profitability"
  setup-farm-orgs





  set max-cell-dist (max [dist-from-sea] of patches)
  ;print(word "dist   " max-cell-dist)

  ;;;;;
end

to setup-patches

  ; Initialize altitude scale values and variables
  ask patches [
    let step max-altitude / 96

    set altitude pxcor * step + (0.5 * pycor * step) + (max-altitude / 10) * ((random 101) / 100)
    if (altitude > max-altitude) [set altitude max-altitude]
    set dist-from-sea pxcor * 1500
    set base-quality 25 + random 51 ;random 101 ; Random quality between (0-100) (could be influenced by dist-from-sea/alt or whatever)
    let base-cost min-base-cost + random (max-base-cost - min-base-cost) ; Random development cost between (0-10) (could be influenced by altitude)

    set dev-cost base-cost + base-cost * max-alt-cost-coeff * (altitude / max-altitude)

  ]

  ; Smoothing loop for altitude, averages height (rumber of repeats determines smoothness, currently 0)
  repeat 0 [
    ask patches [
      let avg-altitude mean [altitude] of neighbors
      set altitude (altitude * 0.7 + avg-altitude * 0.3)
    ]
  ]

  show-patches
end

to setup-farm-orgs

  if red-org [
    create-farm-orgs 1 [
      set sim-dist look-ahead-red
      set org-color red
      set time-btw-buy time-btw-buy-red
      set profit-threshold profit-threshold-red
      set sell-bonus sell-bonus-red
      set dev-discount dev-discount-red
      hide-turtle
    ]
  ]

  if blue-org [
    create-farm-orgs 1 [
      set sim-dist look-ahead-blue
      set org-color blue
      set time-btw-buy time-btw-buy-blue
      set profit-threshold profit-threshold-blue
      set sell-bonus sell-bonus-blue
      set dev-discount dev-discount-blue
      hide-turtle
    ]
  ]

  if green-org [
    create-farm-orgs 1 [
      set sim-dist look-ahead-green
      set org-color green
      set time-btw-buy time-btw-buy-green
      set profit-threshold profit-threshold-green
      set sell-bonus sell-bonus-green
      set dev-discount dev-discount-green
      hide-turtle
    ]
  ]

  ask farm-orgs [set total-agri 0]

end


to go

  if ticks mod 4 = 0 [
    impact-climate ; Simulate climate increase/damage
  ]


  ask farm-orgs[invest-abandon] ; Decides to abandom/invest in farms


  show-patches

  ask farm-orgs[ finances ]

  ask farm-orgs[ plan-new-farms ]


  if ticks = SLR-change-boundary [
    set SLR-rate SLR-rate-1
  ]

  if ticks = run-time [stop]

  tick
end

to impact-climate
  print("climate step")
  ask patches [
    set altitude altitude - SLR-rate
    ;if (altitude < 0)[set altitude 0]
  ]
end

to finances
  let c org-color
  set money money + sum [farm-prof] of farms with [in-use = true and color = c]
  set total-agri total-agri + sum [farm-agri-output] of farms with [in-use = true and color = c]
end

to invest-abandon
  let look-ahead sim-dist

  let abandon-threshold 0;median [farm-prof] of farms with [in-use = true] ; could be median profit of farms
  let u org-upkeep-cost
  let s sell-bonus

  ask farms with [in-use] [
    let total [eval-over-period look-ahead u s] of patch-here

    if total < abandon-threshold[
      set color (5 * (floor (color / 5))) + 3
      set in-use false
    ]
  ]
end


to plan-new-farms

  if ticks mod (time-btw-buy) = 0[

  ;; does not currently account for upkeep cost

    let look-ahead sim-dist

    let possible-plots sort n-of 10 patches with [not any? turtles-here]

    let best-total -999999999999999
    let best-plot 0
    let best-prof -99999999

    foreach possible-plots [[p] ->

      let u org-upkeep-cost
      let s sell-bonus

      let prof ([eval-over-period look-ahead u s] of p) / look-ahead
      let cur-pred ([eval-over-period look-ahead u s] of p) - ([dev-cost] of p) * (1 - dev-discount)

      if cur-pred > best-total[
        set best-total cur-pred
        set best-plot p
        set best-prof prof
      ]
    ]

  ;print(word "best prof " best-total)
  ;print(word "dev cost " [dev-cost] of best-plot)

    let c org-color
    let u org-upkeep-cost
    let b sell-bonus

    if best-prof > profit-threshold[
      ask best-plot [sprout-farms 1 [
        set scale 1
        set size 2
        set upkeep-cost u
        set farm-bonus b
        set color c
        set in-use true]
    ]

      set money money - ([dev-cost] of best-plot) * (1 - dev-discount)
    ]
  ]
end

to-report farm-prof
  let u upkeep-cost
  let b farm-bonus
  report [pred-prof 0 u b] of patch-here
end

to-report farm-agri-output
  let pred-alt [altitude] of patch-here
  report [crop-yield pred-alt] of patch-here
end

;;----------------Cell functions----------------

;; predicted profitability for cell t timesteps in future
to-report pred-prof [t u bonus]
  let crop-co 10
  let pred-alt altitude - (t * SLR-rate)


  let income (crop-yield pred-alt) * crop-co * bonus

  report income - u
end


to-report crop-yield [pred-alt]
  let base-yield 1


  let salinity-threshold 7.7 ;dS m^-1 6.6 value for wheat
  let decrease-coeff 5.2 ; percent decrease per increase in salinity



  let relitive-yield ((100 - decrease-coeff * ((salinity pred-alt) - salinity-threshold)) / 100) * base-yield * base-quality

  report relitive-yield
end

to-report salinity [pred-alt]
  let const 0.922
  let temp-coeff  0.162
  let rain-coeff -0.002
  let river-sal-coeff 0.682
  let elevation-coeff -0.476


  ;let temp 26; average in C (could make change over time) https://climateknowledgeportal.worldbank.org/country/bangladesh/climate-data-historical
  let rainfall 202; monthly average in mm https://live8.bmd.gov.bd/p/Normal-Monthly-Rainfall

  report const + pred-alt * elevation-coeff + (riv-sal pred-alt) * river-sal-coeff + rainfall * rain-coeff + temp * temp-coeff
end

to-report riv-sal [pred-alt]
  ;report -27 * (1 / (1 + exp (-(0.07 * (pred-alt - 55))))) + 27
  report -27 * (1 / (1 + exp (-(0.07 * ((dist-from-sea / 1000) - 55))))) + 27

end

to-report eval-over-period [span u s]

  if not is-patch? self [ error "eval-over-period must be called by a patch" ]
  let i 1
  let total 0
  repeat span [
    set total total + pred-prof i u s
    set i i + 1
  ]

  report total
end

to-report farm-coordinates
  report [list xcor ycor] of farms
end

to-report current-step
  report ticks
end

;-------------------------- Show functions --------------------------

to show-patches
  if (show-type = "altitude") [show-alt]
  if (show-type = "sea-dist") [show-sea-dist]
  if (show-type = "quality") [show-quality]
  if (show-type = "dev-cost") [show-dev-cost]
  if (show-type = "profitability") [show-profitability]
end

to show-alt
  set show-type "altitude"
  ask patches
  [set pcolor scale-color green altitude -10 max-altitude
    if (altitude < 0) [set pcolor blue]
  ]

end

to show-sea-dist
  set show-type "sea-dist"
  ask patches
  [set pcolor scale-color orange dist-from-sea -100 100000]
end

to show-quality
  set show-type "quality"
  ask patches
  [set pcolor scale-color red base-quality 0 100]
end

to show-dev-cost
  set show-type "dev-cost"
  ask patches
  [set pcolor scale-color blue dev-cost max-dev-cost 0]
end

to show-profitability
  set show-type "profitability"
  ask patches
  [
   let val pred-prof 0 0 1
   set pcolor scale-color cyan val 0 max-cell-prof]
end
;--------------------------------------------------------------------
@#$#@#$#@
GRAPHICS-WINDOW
210
10
820
621
-1
-1
9.262
1
10
1
1
1
0
0
0
1
0
64
0
64
0
0
1
ticks
30.0

BUTTON
12
16
75
49
setup
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
86
16
149
49
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
13
88
88
121
show alt
show-alt
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
13
137
116
170
show sea dist
show-sea-dist
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
13
186
110
219
show quality
show-quality
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
13
235
119
268
show dev cost
show-dev-cost
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
825
12
1075
246
Balance over time
Time (ticks)
Balance
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"red-org" 1.0 0 -2674135 true "" "plot sum [money] of farm-orgs with [org-color = red]"
"blue-rog" 1.0 0 -14070903 true "" "plot sum [money] of farm-orgs with [org-color = blue]"
"pen-2" 1.0 0 -14439633 true "" "plot sum [money] of farm-orgs with [org-color = green]"

SLIDER
25
355
197
388
SLR-rate-0
SLR-rate-0
0
0.2
0.014
0.001
1
NIL
HORIZONTAL

BUTTON
13
289
99
322
Cell Profit
show-profitability
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
22
427
195
487
max-altitude
5.0
1
0
Number

PLOT
1090
15
1377
245
Agricultural output over time
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot sum [farm-agri-output] of farms with [color = red]"
"pen-1" 1.0 0 -13345367 true "" "plot sum [farm-agri-output] of farms with [color = blue]"
"pen-2" 1.0 0 -14439633 true "" "plot sum [farm-agri-output] of farms with [color = green]"

INPUTBOX
22
496
196
556
run-time
800.0
1
0
Number

INPUTBOX
22
563
195
623
min-base-cost
4000.0
1
0
Number

INPUTBOX
25
636
195
696
max-base-cost
8000.0
1
0
Number

INPUTBOX
23
709
178
769
max-alt-cost-coeff
2.0
1
0
Number

INPUTBOX
213
639
368
699
starting-temp
26.0
1
0
Number

TEXTBOX
830
270
980
290
Red Org:
16
15.0
1

SWITCH
899
267
1002
300
red-org
red-org
0
1
-1000

INPUTBOX
930
310
1005
370
sell-bonus-red
1.0
1
0
Number

INPUTBOX
825
375
903
435
look-ahead-red
5.0
1
0
Number

INPUTBOX
915
375
1005
435
time-btw-buy-red
15.0
1
0
Number

INPUTBOX
825
310
923
370
profit-threshold-red
0.0
1
0
Number

SLIDER
825
440
1005
473
dev-discount-red
dev-discount-red
0
1
0.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
1020
270
1090
300
Blue Org:
16
95.0
1

SWITCH
1095
265
1205
298
blue-org
blue-org
0
1
-1000

INPUTBOX
1015
310
1115
370
profit-threshold-blue
0.0
1
0
Number

INPUTBOX
1125
310
1205
370
sell-bonus-blue
1.0
1
0
Number

INPUTBOX
1015
375
1090
435
look-ahead-blue
80.0
1
0
Number

INPUTBOX
1115
375
1205
435
time-btw-buy-blue
15.0
1
0
Number

SLIDER
1015
440
1205
473
dev-discount-blue
dev-discount-blue
0
1
0.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
1220
270
1300
290
Green Org:
16
65.0
1

SWITCH
1300
265
1400
298
green-org
green-org
1
1
-1000

INPUTBOX
1325
310
1400
370
sell-bonus-green
1.0
1
0
Number

INPUTBOX
1215
310
1320
370
profit-threshold-green
0.0
1
0
Number

INPUTBOX
1215
375
1295
435
look-ahead-green
20.0
1
0
Number

INPUTBOX
1310
375
1400
435
time-btw-buy-green
15.0
1
0
Number

SLIDER
1215
440
1400
473
dev-discount-green
dev-discount-green
0
1
0.0
0.01
1
NIL
HORIZONTAL

INPUTBOX
405
640
557
700
SLR-change-boundary
400.0
1
0
Number

SLIDER
25
390
197
423
SLR-rate-1
SLR-rate-1
0
0.2
0.042
0.001
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
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="RCP-experiment-1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>sum [money] of farm-orgs with [org-color = red]</metric>
    <metric>sum [money] of farm-orgs with [org-color = blue]</metric>
    <metric>sum [money] of farm-orgs with [org-color = green]</metric>
    <metric>sum [farm-agri-output] of farms with [color = red]</metric>
    <metric>sum [farm-agri-output] of farms with [color = blue]</metric>
    <metric>sum [farm-agri-output] of farms with [color = green]</metric>
    <enumeratedValueSet variable="max-alt-cost-coeff">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SLRrate">
      <value value="0"/>
      <value value="0.0033"/>
      <value value="0.0062"/>
      <value value="0.0088"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-org">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-temp">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-ahead-blue">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dev-discount-red">
      <value value="0.48"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-btw-buy-blue">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-org">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="run-time">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="profit-threshold-red">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sell-bonus-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dev-discount-blue">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-btw-buy-red">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dev-discount-green">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-base-cost">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-btw-buy-green">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-ahead-green">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="profit-threshold-blue">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="profit-threshold-green">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-ahead-red">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-altitude">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sell-bonus-blue">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sell-bonus-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-org">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-base-cost">
      <value value="5000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="RCP-experiment-single-org" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>sum [money] of farm-orgs with [org-color = red]</metric>
    <metric>sum [farm-agri-output] of farms with [color = red]</metric>
    <metric>farm-coordinates</metric>
    <metric>current-step</metric>
    <enumeratedValueSet variable="max-alt-cost-coeff">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SLRrate">
      <value value="0.0088"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-org">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-temp">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-ahead-blue">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dev-discount-red">
      <value value="0.48"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-btw-buy-blue">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-org">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="run-time">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="profit-threshold-red">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sell-bonus-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dev-discount-blue">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-btw-buy-red">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dev-discount-green">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-base-cost">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-btw-buy-green">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-ahead-green">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="profit-threshold-blue">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="profit-threshold-green">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-ahead-red">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-altitude">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sell-bonus-blue">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sell-bonus-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-org">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-base-cost">
      <value value="5000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="RCP-100-times" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>sum [money] of farm-orgs with [org-color = red]</metric>
    <metric>sum [farm-agri-output] of farms with [color = red]</metric>
    <metric>farm-coordinates</metric>
    <enumeratedValueSet variable="max-alt-cost-coeff">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SLRrate">
      <value value="0.0088"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-org">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-temp">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-ahead-blue">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dev-discount-red">
      <value value="0.48"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-btw-buy-blue">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-org">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="run-time">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="profit-threshold-red">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sell-bonus-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dev-discount-blue">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-btw-buy-red">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dev-discount-green">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-base-cost">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-btw-buy-green">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-ahead-green">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="profit-threshold-blue">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="profit-threshold-green">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="look-ahead-red">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-altitude">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sell-bonus-blue">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sell-bonus-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-org">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-base-cost">
      <value value="5000"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
1
@#$#@#$#@
