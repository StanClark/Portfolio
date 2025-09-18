; ************************************ VN-LUDAS Model Copyright Notice **********************************
; This model was solely/orginally created by Quang Bao Le at ZEF Bonn, as his doctoral
; research project titled: "Multi-Agent System for Simulating Land-use and Land-cover
; Change: A Theoretical  Framework and Its First Implementation for an Upland Watershed in
; the Central Coast of  Vietnam".
; Copyright 2005 by Quang Bao Le. All rights reserved.
; E-mail: blequan@uni-bonn.de
; Internet: http//www.zef.de/
; *********************************** End of VN-LUDAS Model Copyright Notice ***************************

globals
[elapsed-years
 temp-stop
 directory-out
 scenario-name
 run-replicate
 ]
patches-own  ;;; THIS PREMITIVE SETS THE PATCH'S VARIABLES
[
;; Variables representing the biophysical status of the land are below:
Easting-UTM      ; Easting (X) coordinate (UTM Zone 48, Datum WGS84) of the patch
Northing-UTM     ; Northing (Y) coordinate (UTM Zone 48, Datum WGS84) of the patch
P_elevation      ; Elevation of the patch (m a.s.l)
P_slope          ; Slope angle of the patch (degree)
P_upslope-area   ; Upslope contributing area of the patch (positive real number)
P_wetness        ; Topographic wetness index of the patch (positive real number)
P_distance-river ; Distance to the nearest river/stream (m)
P_distance-road  ; Distance to the nearest road (m)
P_cover-type     ; Land-cover type of the patch (multi-categorical code)
P_yield-paddy    ; Yield of the paddy rice field (kg rice/ha/year)  (default = 0)
P_yield-upcrop   ; Yield of the upland crop field (kg rice/ha/year) (default = 0)
P_yield-af       ; Yield of the fruit-based agroforestry field (kg rice/ha/year) (default = 0)
P_yield-forest   ; Stand basal area of the forested patch (m2/ha/year)

; Variables representing the land-use status are below:
P_active         ; cultivating status of the patch (1 if the patch is cultivated, 0 if otherwise) (default = 0)
P_t              ; Life span of the existing cover type of the patch (years) (default = 1)
Pt               ; Years after an logging events (default = 0)
P_logged         ; Dummy variable indicates the patch is logged or not (default = 0)

; Variables for holding parcels, stored in the central patch of the parcel
P_owner-point    ; Owner of the central patch of the holding parcel (= household id code) (default = 0)
P_parcel-area    ; Area of the holding parcel (stored in the central patch of the parcels) (m2) (default = 0)

; Variables represent the institutional status of the land are below:
P_owner          ; The household who owns the patch (= household id code)  (default = 0)
P_village        ; The village territory the patch to which the patch belongs (= village id code) (default = 0)
P_protect        ; The protection status of the patch (1 if the patch is within a protection area, 0 if otherwise) (default = 0)
P_zone-score     ; Score index for protection zoning, calculated following Forest Inventory and Planning Institute of Vietnam (FIPI)
P_g              ; patch belonging to household of group H_g

; Patch variables that are household-specific:
P_h-vision       ; whether the patch is within a vision of an household ("household" id if the patch is within the vision, 0 if otherwise) (default = 0)
P_break          ; whether the constraint is broken (1 if the constraint is broken, 0 if otherwise) (default = 1)
P_hij-paddy      ; Choice probability for paddy rice, anticipated by the household h (default = 0)
P_hij-upcrop     ; Choice probability for upland crop, anticipated by by the household h (default =0)
P_hij-af         ; Choice probability for agroforestry, anticipated by the household h (default = 0)
P_hij-pforest    ; Choice probability for private forest plantation, anticipated by the household h (default = 0)

; This patches variables are used for computation only
P_nat-forest     ; a dummy variable indicates if the patch is covered by natural forest (1) or not (0) (default = 0)
P_homegarden-fixed ; a dummy variable indicates the fixed home-garden areas (i.e. the homegarden mixed with residential areas)
P_paddyzone-fixed  ; a dummy variable indicates the fixed paddy rice areas irrigated by Contom and Kate dams
P_new
I-labor
I-chem
]

turtles-own      ; THIS PREMITIVE SETS THE HOUSEHOLD'S VARIABLES
[
; Variables represent the social identity of the household
H_id             ; Identification code of the household (mutlti-categorical code)
H_name           ; Name of the household (string)
H_age            ; Age of the household head (year)
H_village        ; Village that the household belongs to (multi-categorical code)
H_g              ; Code of the livelihood group that the household belongs to (multi-categorical code)
H_ethnic         ; Ethnicity of the household (multi-categorical code)
H_leader         ; Leadership of the household (dummy code)

; Variables represent human resources of the household
H_size           ; Number of people of the household (positive interger)
H_labor          ; Number of workers of the household (positive number)
H_depend         ; Dependency ratio of the household = no. of dependents / h_size
H_edu            ; Educational status of the household (dummy code)

; Variables represent land resources of the household
H_holding        ; Total landholding of the household (m2)
H_holding-pers   ; Landholding per capita of the household (m2/person)
H_nplots         ; Number of holding plots of the household (positive interger)
H_cropping-area  ; Existing cropping area owned by the household (m2)
H_%upcrop        ; Percentage upland crop area of the H_holding (%)
H_%paddy         ; Percentage paddy rice area of the H_holding (%)
H_%af            ; Percentage agroforestry area of the H_holding (%)
H_%plantation    ; Percentage private forest plantation area of the H_holding (%)
H_%fallow        ; Percentage fallowed area of the H_holding (%)


; Varibles represent income of the household
H_income         ; Total annual income of the household (1000 VND/year)
H_income-pers    ; Annual income per capita of the household (1000 VND/person/year)
H_%in-upcrop     ; Percentage income from upland crop field (%)
  h_in-upcrop
H_%in-paddy      ; Percentage income from paddy rice field (%)
  h_in-paddy
H_%in-af         ; Percentage income from agroforestry field (%)
  h_in-af
H_%in-crop       ; Percentage income from crop production = H_%in-upcrop + H_%in-paddy + H_%in-af
H_%in-livestock  ; Percentage income from livestock (%)
  h_in-livestock ; Income from livestock. This is random-bounded around the initial value during the simulation period
H_%in-forestry   ; Percentage income from forest products (%) = h_%in-logging + h_%in-NTFPs
  h_in-forestry
H_%in-others     ; Percentage income from other production activities (%) = h_%in-social + h_%in-sold-labor + h_%in-trading
  h_in-others

; The variables below are the more detail in income componnents
h_%in-logging    ; Percentage income from the logging activity = linked to Forest-Choice routine
  h_in-logging
h_%in-NTFPs      ; Percentage income from the NTFPs collection = function of L-NTFPs
  h_in-NTFPs
h_%in-social     ; Percentage income from the social subsidy or govermental salary
  h_in-social    ; Income from social subsidy / govermental salary. This is fixed during the simulation period
h_%in-sold-labor ; Percentage income from selling labor (for company/project)
  h_in-sold-labor
h_%in-trading    ; Percentage income from trading activities
  h_in-trading   ; Income from trading activities. This is random-bounded around the initial value during the simulation period
; Note: H_%in-forestry = H_%in-logging + H_%in-NTFPs, H_%in-others = H_%in-social + H_%in-trade + H_%in-forestry-wage + H_%in-sold-labor

; Variables represent labor partition
%L-crop          ; Percentage labor allocated for crop production (incl. upland crop + paddy rice + agroforestry)
%L-livestock     ; Percentage labor allocated for livestock production
%L-logging       ; Percentage labor allocated for logging
%L-NTFPs         ; Percentage labor allocated for collecting NTFPs
%L-Others        ; Percentage labor sold
%L-leisure       ; Percentage of leisure time
L-crop           ; Labor budget allocated for crop production
L-livestock      ; Labor budget allocated for livestock production
L-logging        ; Labor budget allocated for logging activities
L-NTFPs          ; Labor budget allocated for collecting NTFPs
L-others         ; Sold labor
; Note: It assumes that trading activities not take much significant labor. Working for local govermental office is not counted in the labor composition.

; Variables represent household's accessibilities to considered policy
H_extension      ; Household's access to agriculture extension program (dummy code)
H_subsidy        ; Household's access to agrochemical subsidy program (dummy code)

; Variables represent geographic location of the household's house
X_house          ; Easting coordinate of the household's house (UTM Zone 48, datum WGS84)
Y_house          ; Northing coordinate of the household's house (UTM Zone 48, datum WGS84)

; Temporary variables, which temporarily store information in computation only)
parcel_cover
parcel_area

; land-use choice parameters
b-road-upcrop          ; preference coefficient (beta) to road when the household eveluates the option of upland crop.
b-house-upcrop         ; preference coefficient (beta) to house when the household eveluates the option of upland crop.
b-river-upcrop         ; preference coefficient (beta) to river when the household eveluates the option of upland crop.
b-slope-upcrop         ; preference coefficient (beta) to slope when the household eveluates the option of upland crop.
b-wetness-upcrop       ; preference coefficient (beta) to wetness when the household eveluates the option of upland crop.
b-age-upcrop           ; preference coefficient (beta) to age when the household eveluates the option of upland crop.
b-leader-upcrop        ; preference coefficient (beta) to leader when the household eveluates the option of upland crop.
b-edu-upcrop           ; preference coefficient (beta) to education level when the household eveluates the option of upland crop.
b-labor-upcrop         ; preference coefficient (beta) to labor when the household eveluates the option of upland crop.
b-depend-upcrop        ; preference coefficient (beta) to dependency ratio when the household eveluates the option of upland crop.
b-holding/pers-upcrop  ; preference coefficient (beta) to landholding when the household eveluates the option of upland crop.
b-income/pers-upcrop   ; preference coefficient (beta) to income when the household eveluates the option of upland crop.
b-extension-upcrop     ; preference coefficient (beta) to extension when the household eveluates the option of upland crop.
b-subsidy-upcrop       ; preference coefficient (beta) to agrochemical subsidy when the household eveluates the option of upland crop.
b-0-upcrop             ; residue in utility function of upcrop

b-road-paddy           ; preference coefficient (beta) to road when the household eveluates the option of paddy.
b-house-paddy          ; preference coefficient (beta) to house when the household eveluates the option of paddy.
b-river-paddy          ; preference coefficient (beta) to river when the household eveluates the option of paddy.
b-slope-paddy          ; preference coefficient (beta) to slope when the household eveluates the option of paddy.
b-wetness-paddy        ; preference coefficient (beta) to wetness when the household eveluates the option of paddy.
b-age-paddy            ; preference coefficient (beta) to age when the household eveluates the option of paddy.
b-leader-paddy         ; preference coefficient (beta) to leader when the household eveluates the option of paddy.
b-edu-paddy            ; preference coefficient (beta) to education level when the household eveluates the option of paddy.
b-labor-paddy          ; preference coefficient (beta) to labor when the household eveluates the option of paddy.
b-depend-paddy         ; preference coefficient (beta) to dependency ratio when the household eveluates the option of paddy.
b-holding/pers-paddy   ; preference coefficient (beta) to landholding when the household eveluates the option of paddy.
b-income/pers-paddy    ; preference coefficient (beta) to income when the household eveluates the option of paddy.
b-extension-paddy      ; preference coefficient (beta) to extension when the household eveluates the option of paddy.
b-subsidy-paddy        ; preference coefficient (beta) to agrochemical subsidy when the household eveluates the option of paddy.
b-0-paddy              ; residue in utility function of paddy

b-road-af              ; preference coefficient (beta) to road when the household eveluates the option of agroforestry.
b-house-af             ; preference coefficient (beta) to house when the household eveluates the option of agroforestry.
b-river-af             ; preference coefficient (beta) to river when the household eveluates the option of agroforestry.
b-slope-af             ; preference coefficient (beta) to slope when the household eveluates the option of agroforestry.
b-wetness-af           ; preference coefficient (beta) to wetness when the household eveluates the option of agroforestry.
b-age-af               ; preference coefficient (beta) to age when the household eveluates the option of agroforestry.
b-leader-af            ; preference coefficient (beta) to leader when the household eveluates the option of agroforestry.
b-edu-af               ; preference coefficient (beta) to education level when the household eveluates the option of agroforestry.
b-labor-af             ; preference coefficient (beta) to labor when the household eveluates the option of agroforestry.
b-depend-af            ; preference coefficient (beta) to dependency ratio when the household eveluates the option of agroforestry.
b-holding/pers-af      ; preference coefficient (beta) to landholding when the household eveluates the option of agroforestry.
b-income/pers-af       ; preference coefficient (beta) to income when the household eveluates the option of agroforestry.
b-extension-af         ; preference coefficient (beta) to extension when the household eveluates the option of agroforestry.
b-subsidy-af           ; preference coefficient (beta) to agrochemical subsidy when the household eveluates the option of agroforestry.
b-0-af                 ; residue in utility function of af
]

;==============================TO=================================================
to INITIALIZATION
set elapsed-years -1
Import-Sampled-Household-Data
Import-SpatialData
Generate-The-Remain-Population
Generate-Holding-Parcels-of-the-Remain-Households
Calculate-Score-For-Protection-Zoning
Define-Protection-Zone
Generate-Household-Coefficients
Labor-Independent-Income
Show-Landcover
end
;==============================END=================================================


;==============================TO=================================================
to SIMULATION
; Now, start the Annual Production Cycle
set elapsed-years elapsed-years + 1
  if stop-when = "any time" [stop]
  Status-message
SET-LABOR-BUDGET
  if stop-when = "any time" [stop]
  Status-message
FARMLAND-CHOICE
  if stop-when = "any time" [stop]
  Status-message
FOREST-CHOICE
  if stop-when = "any time" [stop]
  Status-message
GENERATE-OTHER-INCOME
  if stop-when = "any time" [stop]
  Status-message
UPDATE-HOUSEHOLDS-STATE
  if stop-when = "any time" [stop]
  Status-message
;AGENT-CATEGORIZER
;  if stop-when = "any time" [stop]
;  Status-message
Generate-Household-Coefficients
  if stop-when = "any time" [stop]
  Status-message
FOREST-YIELD-DYNAMICS
  if stop-when = "any time" [stop]
  Status-message
NATURAL-TRANSITION
  if stop-when = "any time" [stop]
CREATE-NEW-HOUSEHOLDS
  if stop-when = "any time" [stop]
DRAW-GRAPHS
  if stop-when = "any time" [stop]
  Status-message
;Export-Landscape-Data
;Export-Household-Data
if elapsed-years + 1 >= stop-when + 1 [stop]

end
;==============================END=================================================
;--------------------------------To--------------------------------------------------
;;; THIS PROCEDURE IMPORTS THE SAMPLED HOUSEHOLD DATASET (69 HOUSEHOLDS)
to Import-Sampled-Household-Data
   import-world "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\hongha.csv"
   ask turtles [set color 15]
   display
end
;-------------------------------End---------------------------------------------------

;-------------------------------To----------------------------------------------------
;;; THIS PROCEDURE IS TO IMPORT THE PATCH'S VARIABLES USING SPATIAL DATA AS TXT FILES
to Import-Spatialdata
    ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\\\VN-LUDAS\\Data\\p_xutm.txt"
         set easting-utm file-read
         file-close ]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_yutm.txt"
         set northing-utm file-read
         file-close ]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_elevation.txt"
         set p_elevation file-read
         file-close ]
   ask patches
        [ file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_slope.txt"
         set p_slope file-read
         file-close]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_upslope-area.txt"
         set p_upslope-area file-read
         file-close]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_wetness.txt"
         set p_wetness file-read
         file-close]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_distance-river.txt"
         set p_distance-river file-read
         file-close]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_distance-road.txt"
         set p_distance-road file-read
         file-close]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_cover-type.txt"
         set p_cover-type file-read
         file-close]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_village.txt"
         set p_village file-read
         file-close]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_owner_points_2002.txt"
         set p_owner-point file-read
         file-close]
   ask patches
        [file-open "C:\\Schoolwork\\4\\MOSS\\CW2\\VN-LUDAS\\Data\\p_parcel_area_2002.txt"
         set p_parcel-area file-read
         file-close]
   ; Generate stand-basal area for forested patches
   ask patches with [p_cover-type > -999]
    [set P_yield-forest 0
     let exit 0
     if p_cover-type = 6 [while [exit = 0]
                                [set P_yield-forest random-normal 32.94 13.03
                                 ifelse P_yield-forest < 25.61 or P_yield-forest > 44.63 [set exit 0] [set exit 1] ]
                         ]
     set exit 0
     if p_cover-type = 7 [while [exit = 0]
                                [set P_yield-forest random-normal 18.28 7.39
                                 ifelse P_yield-forest < 1.00 or P_yield-forest > 25.61 [set exit 0] [set exit 1] ]
                         ]
     set exit 0
     if p_cover-type = 5 [while [exit = 0]
                                [set P_yield-forest random-normal 8.37 6.26
                                 ifelse P_yield-forest < 1 or P_yield-forest > 19.73 [set exit 0] [set exit 1] ]
                         ]
    ]
; Correcting edge errors in land-cover types of some holding plots:
; These errors are mainly: i) a few plots of home garden located next to road is on the road area when the road shape file is converted to the raster file, and
; ii) a few plots of paddy rice located next to streams/rivers is on the river/stream area when the rivers/streams shape file is converted to the raster file.
; The correction is to set P_cover-type of these errored holding patches either 3 (if being on road), or 2 (if being on river).
ask patches
   [if (P_owner-point > 0 and P_cover-type = 12)   ; correct P_cover-type of the holding patches that are "on" stream/river area.
       [set P_cover-type 2]
    if (P_owner-point > 0 and P_cover-type = 10)   ; correct P_cover-type of the holding patches that are "on" road area.
       [set P_cover-type 3]
   ]

ask patches with [P_cover-type > -999]
[set P_t 1]

; marking the fixed paddy and home-garden areas
ask patches
[if P_cover-type = 2 [set P_paddyzone-fixed 1]
 if P_cover-type = 3 [set P_homegarden-fixed 1]]

; The procedure below corrects the "no-data" errors of the upslope contributing data, which often occur when it's calculated from the DEM. These errors are
; that some pixels within the study area have the value -999 (no-data).
ask patches with [P_elevation > -999]
   [if P_upslope-area = -999 [set P_upslope-area 1]]
end
;--------------------------------End------------------------------------------
to correct
ask patches with [P_elevation > -999]
   [if P_upslope-area = -999 [set P_upslope-area 1]]
end
;--------------------------------To-------------------------------------------
to Show-Elevation
  ask patches with [ p_elevation > -999]
     [ set pcolor scale-color orange p_elevation 1600 0  ]
end
;-------------------------------End-------------------------------------------

;-------------------------------To-------------------------------------------
to Show-Slope
  ask patches with [ p_slope > -999]
     [ set pcolor scale-color orange p_slope 53 0  ]
end
;------------------------------End--------------------------------------------

;------------------------------To---------------------------------------------
to Show-Upslope-Area
  ask patches with [ p_upslope-area > -999]
     [ set pcolor scale-color cyan LN (p_upslope-area) LN(46482772) 0  ]
end
;------------------------------End--------------------------------------------

;------------------------------To---------------------------------------------
to Show-Wetness
  ask patches with [ p_wetness > -999]
     [ set pcolor scale-color blue p_wetness 26 0  ]
end
;------------------------------End--------------------------------------------

;------------------------------To---------------------------------------------
to Show-Distance-to-River
  ask patches with [ p_distance-river > -999]
     [ set pcolor scale-color blue ln(p_distance-river + 1) 0 ln(1830)  ]
end
;------------------------------End--------------------------------------------

;------------------------------To---------------------------------------------
to Show-Distance-to-Road
  ask patches with [ p_distance-road > -999]
     [ ;set pcolor scale-color red ln(p_distance-road + 1) 0 ln(5623)
      if p_distance-road <= 1000 [set pcolor 17]
      if p_distance-road > 1000 and p_distance-road <= 2000 [set pcolor 18]
      if p_distance-road > 2000 and p_distance-road <= 3000 [set pcolor 19]
      if p_distance-road > 3000 and p_distance-road <= 4000 [set pcolor 58]
      if p_distance-road > 4000 and p_distance-road <= 5000 [set pcolor 56]
      if p_distance-road > 5000  [set pcolor 54]
      if P_cover-type = 10 [set Pcolor 12]]
end
;------------------------------End--------------------------------------------

;------------------------------To---------------------------------------------
to Show-Landcover
  ask patches
   [if P_cover-type = -999 [set Pcolor 7]  ; outside the boundry of the catchment
    if P_cover-type = 0 [set Pcolor 0]     ; Nodata (cloud, cloud's shade)
    if P_cover-type = 1 [set Pcolor 45]    ; Upland crop
    if P_cover-type = 2 [set Pcolor 105]   ; Paddy rice
    if P_cover-type = 3 [set Pcolor 25]    ; Agroforestry
    if P_cover-type = 4 [set Pcolor 58]    ; Young plantation
    if P_cover-type = 5 [set Pcolor 56]    ; Forest plantation
    if P_cover-type = 6 [set Pcolor 62]    ; Dense natural forest
    if P_cover-type = 7 [set Pcolor 65]    ; Open natural forest
    if P_cover-type = 8 [set Pcolor 85]    ; Scrub land
    if P_cover-type = 9 [set Pcolor 128]   ; Grassland
    if P_cover-type = 10 [set Pcolor 12]   ; Road
    if P_cover-type = 11 [set Pcolor 5]    ; Bareland (rocky/gravel surface)
    if P_cover-type = 12 [set Pcolor 102] ]; River/stream]
end
;--------------------------------End--------------------------------------------

;--------------------------------To---------------------------------------------
To Generate-Show-Stand-Basal-Area
    ask patches with [p_cover-type > -999]
    [set P_yield-forest 0
     let exit 0
     if p_cover-type = 6 [while [exit = 0]
                                [set P_yield-forest random-normal 32.94 13.03
                                 ifelse P_yield-forest < 25.61 or P_yield-forest > 44.63 [set exit 0] [set exit 1] ]
                         ]
     set exit 0
     if p_cover-type = 7 [while [exit = 0]
                                [set P_yield-forest random-normal 18.28 7.39
                                 ifelse P_yield-forest < 1.00 or P_yield-forest > 25.61 [set exit 0] [set exit 1] ]
                         ]
     set exit 0
     if p_cover-type = 5 [while [exit = 0]
                                [set P_yield-forest random-normal 8.37 6.26
                                 ifelse P_yield-forest < 1 or P_yield-forest > 19.73 [set exit 0] [set exit 1] ]
                         ]
     ]
     Show-Stand-Basal-Area
end
;--------------------------------End--------------------------------------------

;--------------------------------To---------------------------------------------
To Show-Stand-Basal-Area
    ask patches with [p_cover-type > -999]
    [set pcolor scale-color green p_yield-forest 45 0

     if P_cover-type = 0 [set Pcolor 0]        ; Nodata (cloud, cloud's shade)
     if P_cover-type = 1 [set Pcolor 9]        ; Upland crop
     if P_cover-type = 2 [set Pcolor 9]        ; Paddy rice
     if P_cover-type = 3 [set Pcolor 9]        ; Agroforestry
     if P_cover-type = 4 [set Pcolor 9]        ; Young plantation
     if P_cover-type = 8 [set Pcolor 9]        ; Scrub land
     if P_cover-type = 9 [set Pcolor 9]        ; Grassland
     if P_cover-type = 10 [set Pcolor 12]      ; Road
     if P_cover-type = 11 [set Pcolor 9]       ; Bareland (rocky/gravel surface)
     if P_cover-type = 12 [set Pcolor 102]     ; River/stream
    ]
end
;--------------------------------End--------------------------------------------
;--------------------------------To---------------------------------------------
to Show-Village-Territory
  ask patches with [ p_cover-type > -999]
   [if P_village = -999 [set Pcolor 9.999]  ; Outside the boundry of the catchment
    if P_village = 0 [set Pcolor 6]         ; Within the catchment but outside village boundary (claimed as state land)
    if P_village = 1 [set Pcolor 45]        ; Territory of Arom village
    if P_village = 2 [set Pcolor 95]        ; Territory of Parinh village
    if P_village = 3 [set Pcolor 25]        ; Territory of Consam village
    if P_village = 4 [set Pcolor 58]        ; Territory of Pahy village
    if P_village = 5 [set Pcolor 56]        ; Territory of Contom village
    if P_village = 23 [set Pcolor 62]       ; Territory shared by Parinh and Consam villages
    if P_village = 234 [set Pcolor 65]      ; Territory shared by Paring, Consam, and Pahy villages
    if P_village = 12345 [set Pcolor 75] ]  ; Territory shared by the five villages
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Show-Holdings
  ask patches with [ p_cover-type > -999] [
    ; if P_owner-point = 0 [set Pcolor 6]         ; Within the catchment but outside village boundary (claimed as state land)
    ;if P_owner-point > 1000 and P_owner-point < 2000 [set Pcolor 45]        ; Territory of Arom village
    ;if P_owner-point > 2000 and P_owner-point < 3000  [set Pcolor 95]       ; Territory of Parinh village
    ;if P_owner-point > 3000 and P_owner-point < 4000  [set Pcolor 25]       ; Territory of Consam village
    ;if P_owner-point > 4000 and P_owner-point < 5000  [set Pcolor 58]       ; Territory of Pahy village
    ;if P_owner-point > 5000 [set Pcolor 56]                                 ; Territory of Contom village
    if P_owner > 0 [set Pcolor red]
    ]
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Generate-The-Remain-Population
  ; The purpose of this procedure is to generate the whole population which is most similar to the survey household dataset, with given population size N set by users.
  ; The remain household population is: N - 69 = (69 * floor(N/69) - 1) + (N mod 69). Because the part (69 * floor(N/69) - 1) is an multiple of 69, at best it should be
  ; generated by copying exactly the set of sampled households (section 1). Because the part (N mod 69) is less than 69, at best it is generated by random selection
  ; from 69 surveyed household (section 2).
  ; Section 1: i) Multiply the 69 surveyed households by (floor(N/69)-1), and ii) Generate holding parcel center point of new household
  ask turtles with [H_name != "hatched_1" and H_name != "hatched_2" and H_name != 0]
     [hatch floor ((number-of-initial-households / 69) - 1)                   ; i)Create new turtles, each identical to its parent
       [set H_id H_id + 100                                                   ;   create H_id for the new household
        set H_name "hatched_1"
        ask patches with [P_owner-point = ([H_id] of myself - 100)]             ; ii) Generate new holding parcel center point for the new household
            [sprout 1 [set H_id [P_owner-point] of patch-here + 100   ; sprout a temporary turle on each center of the holding parcel of the parent turtle
                       set H_village [P_village] of patch-here
                       set parcel_cover [P_cover-type] of patch-here  ; and copy data on i) owner, 2) village, 3) cover type and 4) parcel area to store in this new sprouted
                       set parcel_area  [P_parcel-area] of patch-here ; turtle. The spouted turtles will act as the information transporters (i.e., transporter)
                       let random_patch one-of patches with [(P_owner-point = 0) and (P_village = [H_village] of myself) and (P_cover-type = [parcel_cover] of myself)]
                       if random_patch != nobody
                      [ask random_patch                                       ; The transporter turtle select randomly a patch, bounded by the following conditions
                          [
;                           set [xcor] of myself pxcor                           ; The sprouted turtle jump to the selected patch, which is as a center of a
;                           set [ycor] of myself pycor                           ;  new holding parcel of the hatched turtle.
                           move-to random_patch
                           set P_owner-point  [H_id] of myself                  ; The sprouted turtle transfers information on cover type (from the parrent parcel) to the new parcel
                           set P_cover-type   [parcel_cover] of myself          ; The sprouted
                           set P_parcel-area  [parcel_area] of myself           ; Transfer information on parcel area from the parrent patch for the new patch
                           ]]
                       die                                                    ; after the sprouted turtle finishes his duty, he disappears.
                      ]
              ]
         let random_patch1 one-of patches with [P_owner-point = [H_id] of myself and P_village = [H_village] of myself and P_cover-type = 3]
         ifelse random_patch1 != nobody                                        ; Set the house location of the hatched household
              [ask random_patch1                                               ;
                      [move-to random_patch1
;                       set [xcor] of myself  pxcor                                ; Set x-coordinate of the new household's house
;                       set [ycor] of myself  pycor                                ; Set y-coordinate of the new household's house
                      ] ]

          [let fallback_patch one-of patches with [P_owner-point = [H_id] of myself]
           if fallback_patch != nobody [
               ask fallback_patch
                      [move-to patch-here
          ] ] ]
       ]
     ]

  ; Section 2: i) Select randomly (N mod 69) households from the 69 surveyed households, and ii) Generate holding parcel center point of new household
  ask n-of (number-of-initial-households mod 69) turtles with [H_name != "hatched_1"]    ; Select randomly (N mod 69) households from the 69 surveyed households
      [hatch 1                                                                  ; Create new turtles, each identical to its parent
           [set H_id H_id + 100                                                 ;   create H_id for the new household
            set H_name "hatched_2"
            ask patches with [P_owner-point = ([H_id] of myself - 100)]             ; ii) Generate new holding parcel center point for the new household
               [sprout 1 [set H_id [P_owner-point] of patch-here + 100    ; sprout a temporary turle on each center of the holding parcel of the parent turtle
                          set H_village [P_village] of patch-here
                          set parcel_cover [P_cover-type] of patch-here   ; and copy data on i) owner, 2)cover type and iii) parcel area to store in this new sprouted
                          set parcel_area  [P_parcel-area] of patch-here  ; turtle. The spouted turtles will act as the information transporters (i.e., transporter)
                          let random_patch one-of patches with [(P_owner-point = 0) and (P_village = [H_village] of myself) and (P_cover-type = [parcel_cover] of myself)]
                          if random_patch != nobody
                          [ask random_patch   ; The transporter turtle select randomly a patch, bounded by the following conditions
                              [
                               move-to random_patch
                               set P_owner-point  [H_id] of myself                  ; The sprouted turtle transfers information on cover type (from the parrent parcel) to the new parcel
                               set P_cover-type   [parcel_cover] of myself          ; The sprouted
                               set P_parcel-area  [parcel_area] of myself           ; Transfer information on parcel area from the parrent patch for the new patch
                              ]
                          die                                                     ; after the sprouted turtle finishes his duty, he disappears.
                         ]]
               ]
            let random_patch1 one-of patches with [P_owner-point = [H_id] of myself and P_village = [H_village] of myself and P_cover-type = 3]
            ifelse random_patch1 != nobody
               [ask random_patch1                                                  ; Set the house location of the hatched household
                         [move-to random_patch1
                         ] ]
               [let fallback_patch one-of patches with [P_owner-point = [H_id] of myself]
                if fallback_patch != nobody [
                ask fallback_patch
                       [move-to patch-here
                 ] ] ]
           ]
         ]
ask turtles with [H_id = 0] [die] ; remove empty households, in the case they exist
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Generate-Holding-Parcels-of-The-Remain-Households
ask patches with [P_owner-point > 0]
   [set P_owner P_owner-point
    let n-patch round(P_parcel-area / 900)
    if n-patch = 0 [set n-patch 1]
    let radius 1
    while [(count (patches in-radius-nowrap radius with [P_cover-type = [P_cover-type] of myself and P_owner-point = 0])) <= n-patch]
          [set radius (radius + 1)]
    ask n-of n-patch patches in-radius-nowrap radius with [P_cover-type = [P_cover-type] of myself and P_owner-point = 0]
          [set P_owner [P_owner-point] of myself]
   ]
;ask patches with [P_owner != 0 and (P_cover-type = 1 or P_cover-type = 2 or P_cover-type = 3) ] [set pcolor yellow]
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
; This procedure calculate the grid of P_protect in according to FIPI's watershed protection zoning system.
to Calculate-Score-for-Protection-Zoning
ask patches with [P_cover-type > -999]
   [let rain-score 0                    ; set the score of the rain factor as a local variable
    let slope-score 0                   ; set the score of the slope factor as a local variable
    let elevation-score 0               ; set the score of the relative elevation factor as a local variable
    let soil-score 0                    ; set the score of the soil hardness/statbility factor as a local variable

    ; calculate rain factor score
    if average-annual-rainfall <= 1000                                      ; rain-score = 2 if rainfall <= 1000 mm/year
       [set rain-score 2]
    if average-annual-rainfall > 1000 and average-annual-rainfall <= 2000   ; rain-score = 4 if 1000 <= rainfall <= 2000 mm/year
       [set rain-score 4]
    if average-annual-rainfall > 2000                                       ; rain-score = 6 if rainfall > 2000 mm/year
       [set rain-score 6]

    ; calculate slope factor score
    if P_slope <= 8                                                         ; slope-score = 0.5 if P_slope <= 8 degree
       [set slope-score 0.5]
    if P_slope > 8 and P_slope <= 15                                        ; slope-score = 1 if 8 < P_slope <= 15 degree
       [set slope-score 1]
    if P_slope > 15 and P_slope <= 25                                       ; slope-score = 2 if 15 < P_slope <= 25 degree
       [set slope-score 2]
    if P_slope > 25 and P_slope <= 35                                       ; slope-score = 4 if 25 < P_slope <= 35 degree
       [set slope-score 4]
    if P_slope > 35                                                         ; slope-score = 6 if P_slope <= 8 degree
       [set slope-score 6]

    ; calculate elevation factor score
    if P_elevation <= (26 + ((1371 - 26) / 3))                              ; elevation-score = 1 if P_evelation <= (min + (max-min)/3)
       [set elevation-score 1]
    if P_elevation > (26 + ((1371 - 26) / 3)) and P_elevation <= (26 + ((1371 - 26) * (2 / 3))) ; elevation-score = 2 if (min + (max-min)/3) < P_evelation <= (min + (max-min)*(2/3))
       [set elevation-score 2]
    if P_elevation > (26 + ((1371 - 26) * (2 / 3)))                         ; elevation-score = 1 if P_evelation <= (min + (max-min)/3)
       [set elevation-score 3]

    ; calculate soil factor score
    set soil-score 2                                                        ; assuming the soil condition in Hong Ha meet the category of DD2 in the scoring system.

    ; calculate the zoning score index
    set P_zone-score (rain-score + slope-score + elevation-score + soil-score)
    set pcolor scale-color orange p_slope 53 0
   ]
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Define-Protection-Zone
ask patches with [P_cover-type > -999]
   [ifelse P_zone-score > theta-protect      ; theta-protect is the threshold of the zoning score index, which a global variables set by users, to define the protection zone
      [set P_protect 1
       set pcolor orange]
      [set pcolor blue]
   ]
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
;This procedure is to update the internal state of household, according to the rule set F_H-internal in Chapter 3. Note: this procedure is within the annual production cycle


;--------------------------------To----------------------------------------------
to AGENT-CATEGORIZER
ask turtles with [H_id > 0 and H_size > 0]
   [let D_h1 0                      let D_h2 0                          let D_h3 0                ; The Squared Chi-Squared Distance of groups I, II, and III, respectively.

    ; Set the centroids of groups I, II, and III (Data source: Table 4-5, Chapter 4)
    let H_labor1 2.7                let H_labor2 2.8                    let H_labor3 2.3          ; The mean H_labor of groups I, II, and III, respectively.
    let H_depend1 1.27              let H_depend2 1.31                  let H_depend3 1.26        ; The mean H_depend of groups I, II, and III, respectively.
    let H_holding-pers1 3149        let H_holding-pers2 1622            let H_holding-pers3 5418  ; The mean H_holding-pers of groups I, II, and III, respectively.
    let H_income-pers1 1358         let H_income-pers2 1159             let H_income-pers3 4000   ; The mean H_income-pers of groups I, II, and III, respectively.
    let H_%in-livestock1 4.2        let H_%in-livestock2 11.6           let H_%in-livestock3 4.8  ; The mean H_%in-livestock of groups I, II, and III, respectively.
    let H_%in-paddy1 25.6           let H_%in-paddy2 5.5                let H_%in-paddy3 3.5      ; The mean H_%in-paddy of groups I, II, and III, respectively.

    ; Calculate D_h1 for every household h
    set D_h1 ((((H_labor - H_labor1) ^ 2) / (H_labor + H_labor1)) +
              (((H_depend - H_depend1) ^ 2) / (H_depend + H_depend1)) +
              (((H_holding-pers - H_holding-pers1) ^ 2) / (H_holding-pers + H_holding-pers1)) +
              (((H_income-pers - H_income-pers1) ^ 2) / (H_income-pers + H_income-pers1)) +
              (((H_%in-livestock - H_%in-livestock1) ^ 2) / (H_%in-livestock + H_%in-livestock1)) +
              (((H_%in-paddy - H_%in-paddy1) ^ 2) / (H_%in-paddy + H_%in-paddy1))
             )

    ; Calculate D_h2 for every household h
    set D_h2 ((((H_labor - H_labor2) ^ 2) / (H_labor + H_labor2)) +
              (((H_depend - H_depend2) ^ 2) / (H_depend + H_depend2)) +
              (((H_holding-pers - H_holding-pers2) ^ 2) / (H_holding-pers + H_holding-pers2)) +
              (((H_income-pers - H_income-pers2) ^ 2) / (H_income-pers + H_income-pers2)) +
              (((H_%in-livestock - H_%in-livestock2) ^ 2) / (H_%in-livestock + H_%in-livestock2)) +
              (((H_%in-paddy - H_%in-paddy2) ^ 2) / (H_%in-paddy + H_%in-paddy2))
             )

    ; Calculate D_h3 for every household h
    set D_h3 ((((H_labor - H_labor3) ^ 2) / (H_labor + H_labor3)) +
              (((H_depend - H_depend3) ^ 2) / (H_depend + H_depend3)) +
              (((H_holding-pers - H_holding-pers3) ^ 2) / (H_holding-pers + H_holding-pers3)) +
              (((H_income-pers - H_income-pers3) ^ 2) / (H_income-pers + H_income-pers3)) +
              (((H_%in-livestock - H_%in-livestock3) ^ 2) / (H_%in-livestock + H_%in-livestock3)) +
              (((H_%in-paddy - H_%in-paddy3) ^ 2) / (H_%in-paddy + H_%in-paddy3))
             )

    ; Now, to categorize the household h by resetting the group membership H_g of the household
    if D_h1 = min(list D_h1 D_h2 D_h3)
       [if H_g != 1 [set %L-crop     46 - 9 + random-float 2 * 9
                     set %L-livestock 2 - 2 + random-float 2 * 2
                     set %L-logging   1 - 1 + random-float 2 * 1
                     set %L-NTFPs     2 - 2 + random-float 2 * 2
                     set %L-others    1 - 1 + random-float 2 * 1
                     set %L-leisure   100 - (%L-crop + %L-livestock + %L-logging + %L-NTFPs + %L-others)]
        set H_g 1]
    if D_h2 = min(list D_h1 D_h2 D_h3)
       [if H_g != 2 [set %L-crop     37 - 6 + random-float 2 * 6
                     set %L-livestock 6 - 2 + random-float 2 * 2
                     set %L-logging   1 - 1 + random-float 2 * 1
                     set %L-NTFPs     6 - 2 + random-float 2 * 2
                     set %L-others    1 - 1 + random-float 2 * 1
                     set %L-leisure   100 - (%L-crop + %L-livestock + %L-logging + %L-NTFPs + %L-others)]
        set H_g 2]
    if D_h3 = min(list D_h1 D_h2 D_h3)
       [if H_g != 3 [set %L-crop     44 - 12 + random-float 2 * 12
                     set %L-livestock 3 - 2 + random-float 2 * 2
                     set %L-logging   1 - 1 + random-float 2 * 1
                     set %L-NTFPs     5 - 4 + random-float 2 * 4
                     set %L-others    2 - 2 + random-float 2 * 2
                     set %L-leisure   100 - (%L-crop + %L-livestock + %L-logging + %L-NTFPs + %L-others)]
        set H_g 3]
   ]
   show "Agent-Categorizer: Passed"
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Generate-Household-Coefficients ; This is a procedure to update new preference coefficients (beta) of households. This procedure is fired just after the execution of the "Agent-Categorizer"
ask turtles
[if H_g = 1
   [set b-road-upcrop -0.004 - 0.004 + random-float 0.004 * 2           set b-road-paddy 0.002 - 0.005 + random-float 0.005 * 2             set b-road-af -0.018 - 0.008 + random-float 0.008 * 2
    set b-house-upcrop 0.003 - 0.001 + random-float 0.001 * 2           set b-house-paddy 0.003 - 0.001 + random-float 0.001 * 2            set b-house-af -0.008 - 0.004 + random-float 0.004 * 2
    set b-river-upcrop 0.003 - 0.008 + random-float 0.008 * 2           set b-river-paddy -0.019 * 100 - 0.011 + random-float 0.011 * 2     set b-river-af -0.012 - 0.014 + random-float 0.014 * 2
    set b-slope-upcrop -0.229 - 0.097 + random-float 0.097 * 2          set b-slope-paddy -0.488 - 0.170 + random-float 0.170 * 2           set b-slope-af -0.12 - 0.164 + random-float 0.164 * 2
    set b-wetness-upcrop -0.197 - 0.157 + random-float 0.157 * 2        set b-wetness-paddy -0.118 - 0.163 + random-float 0.163 * 2         set b-wetness-af -0.276 - 0.206 + random-float 0.206 * 2
    set b-age-upcrop -0.032 - 0.064 + random-float 0.064 * 2            set b-age-paddy 0.028 - 0.069 + random-float 0.069 * 2              set b-age-af 0.061 - 0.114 + random-float 0.114 * 2
    set b-leader-upcrop -4.24 - 2.876 + random-float 2.876 * 2          set b-leader-paddy -1.727 - 3.148 + random-float 3.148 * 2          set b-leader-af -5.716 - 3.640 + random-float 3.640 * 2
    set b-edu-upcrop 0.339 - 3.165 + random-float 3.165 * 2             set b-edu-paddy -0.105 - 3.428 + random-float 3.428 * 2             set b-edu-af 13.081 - 6.653 + random-float 6.653 * 2
    set b-labor-upcrop 1.734 - 1.529 + random-float 1.529 * 2           set b-labor-paddy 1.154 - 1.601 + random-float 1.601 * 2            set b-labor-af 4.671 - 2.009 + random-float 2.009 * 2
    set b-depend-upcrop 2.233 - 1.960 + random-float 1.960 * 2          set b-depend-paddy 1.681 - 1.995 + random-float 1.995 * 2           set b-depend-af 4.222 - 2.503 + random-float 2.503 * 2
    set b-holding/pers-upcrop 0                                         set b-holding/pers-paddy 0                                          set b-holding/pers-af 0.001 - 0.001 + random-float 0.001 * 2
    set b-income/pers-upcrop 0.001 - 0.002 + random-float 0.002 * 2     set b-income/pers-paddy 0.001 - 0.002 + random-float 0.002 * 2      set b-income/pers-af -0.004 - 0.002 + random-float 0.002 * 2
    set b-extension-upcrop -1.401 - 2.727 + random-float 2.727 * 2      set b-extension-paddy -0.195 - 2.874 + random-float 2.874 * 2       set b-extension-af -1.027 - 3.623 + random-float 3.623 * 2
    set b-subsidy-upcrop 0.173 - 0.008 + random-float 0.008 * 2         set b-subsidy-paddy 0.172 - 0.008 + random-float 0.008 * 2          set b-subsidy-af 0.173
    set b-0-upcrop -1.135 - 8.006 + random-float 8.006 * 2              set b-0-paddy 2.221 - 8.480 + random-float 8.480 * 2                set b-0-af -25.887 - 14.463 + random-float 14.463 * 2
   ]
 if H_g = 2
   [set b-road-upcrop 0 - 0.004 + random-float 0.004 * 2                set b-road-paddy 0.002 - 0.004 + random-float 0.004 * 2             set b-road-af -0.006 - 0.006 + random-float 0.006 * 2
    set b-house-upcrop 0.001 - 0.001 + random-float 0.001 * 2           set b-house-paddy 0.001 - 0.001 + random-float 0.001 * 2            set b-house-af -0.004 - 0.001 + random-float 0.001 * 2
    set b-river-upcrop -0.023 - 0.009 + random-float 0.009 * 2          set b-river-paddy -0.028 * 100 - 0.010 + random-float 0.010 * 2     set b-river-af -0.004 - 0.011 + random-float 0.011 * 2
    set b-slope-upcrop 0.039 - 0.113 + random-float 0.113 * 2           set b-slope-paddy -0.233 - 0.142 + random-float 0.142 * 2           set b-slope-af 0.05 - 0.135 + random-float 0.135 * 2
    set b-wetness-upcrop 0.18 - 0.157 + random-float 0.157 * 2          set b-wetness-paddy 0.084 - 0.160 + random-float 0.160 * 2          set b-wetness-af 0.241 - 0.171 + random-float 0.171 * 2
    set b-age-upcrop -0.079 - 0.044 + random-float 0.044 * 2            set b-age-paddy -0.098 - 0.045 + random-float 0.045 * 2             set b-age-af -0.041 - 0.049 + random-float 0.049 * 2
    set b-leader-upcrop -2.385 - 1.963 + random-float 1.963 * 2         set b-leader-paddy -1.313 - 2.033 + random-float 2.033 * 2          set b-leader-af -1.855 - 2.072 + random-float 2.072 * 2
    set b-edu-upcrop -2.012 - 1.540 + random-float 1.540 * 2            set b-edu-paddy -1.872 - 1.588 + random-float 1.588 * 2             set b-edu-af -2.925 - 1.757 + random-float 1.757 * 2
    set b-labor-upcrop 0.692 - 0.635 + random-float 0.635 * 2           set b-labor-paddy 0.639 - 0.655 + random-float 0.655 * 2            set b-labor-af -0.671 - 0.757 + random-float 0.757 * 2
    set b-depend-upcrop 1.994 - 1.700 + random-float 1.700 * 2          set b-depend-paddy 1.674 - 1.726 + random-float 1.726 * 2           set b-depend-af 3.323 - 1.783 + random-float 1.783 * 2
    set b-holding/pers-upcrop 0                                         set b-holding/pers-paddy -0.001                                     set b-holding/pers-af 0
    set b-income/pers-upcrop 0 - 0.001 + random-float 0.001 * 2         set b-income/pers-paddy 0 - 0.001 + random-float 0.001 * 2          set b-income/pers-af -0.002 - 0.001 + random-float 0.001 * 2
    set b-extension-upcrop 0.166 - 1.540 + random-float 1.540 * 2       set b-extension-paddy -0.437 - 1.596 + random-float 1.596 * 2       set b-extension-af 0.645 - 1.679 + random-float 1.679 * 2
    set b-subsidy-upcrop 0.171 - 0.002 + random-float 0.002 * 2         set b-subsidy-paddy 0.171 - 0.003 + random-float 0.003 * 2          set b-subsidy-af 0.171
    set b-0-upcrop 3.027 - 4.315 + random-float 4.315 * 2               set b-0-paddy 6.511 - 4.464 + random-float 4.464 * 2                set b-0-af -4.35 - 5.054 + random-float 5.054 * 2
   ]
 if H_g = 3
   [set b-road-upcrop -0.01 - 0.008 + random-float 0.008 * 2           set b-road-paddy -0.004 - 0.009 + random-float 0.009 * 2             set b-road-af -0.046 - 0.017 + random-float 0.017 * 2
    set b-house-upcrop 0.001 - 0.001 + random-float 0.001 * 2          set b-house-paddy -0.001 - 0.002 + random-float 0.002 * 2            set b-house-af 0.001 - 0.001 + random-float 0.001 * 2
    set b-river-upcrop -0.001 - 0.013 + random-float 0.013 * 2         set b-river-paddy (0.006 - 0.014) * 100 + random-float 0.014 * 2           set b-river-af 0.019 - 0.017 + random-float 0.017 * 2
    set b-slope-upcrop -0.319 - 0.170 + random-float 0.170 * 2         set b-slope-paddy -0.422 - 0.182 + random-float 0.182 * 2            set b-slope-af -0.038 - 0.216 + random-float 0.216 * 2
    set b-wetness-upcrop 0.275 - 0.382 + random-float 0.382 * 2        set b-wetness-paddy (0.269 - 0.388) + random-float 0.388 * 2           set b-wetness-af 0.374 - 0.394 + random-float 0.394 * 2
    set b-age-upcrop -0.038 - 0.210 + random-float 0.210 * 2           set b-age-paddy 0.067 - 0.215 + random-float 0.215 * 2               set b-age-af 0.11 - 0.213 + random-float 0.213 * 2
    set b-leader-upcrop 0                                              set b-leader-paddy 0                                                 set b-leader-af 0
    set b-edu-upcrop 0                                                 set b-edu-paddy 0                                                    set b-edu-af 0
    set b-labor-upcrop 5.749 - 7.272 + random-float 7.272 * 2          set b-labor-paddy 9.119 - 7.377 + random-float 7.377 * 2             set b-labor-af 7.456 - 7.395 + random-float 7.395 * 2
    set b-depend-upcrop 7.864 - 8.651 + random-float 8.651 * 2         set b-depend-paddy 12.811 - 8.804 + random-float 8.804 * 2           set b-depend-af 8.847 - 8.845 + random-float 8.845 * 2
    set b-holding/pers-upcrop 0                                        set b-holding/pers-paddy 0.001                                       set b-holding/pers-af 0.001 - 0.001 + random-float 0.001 * 2
    set b-income/pers-upcrop -0.002 - 0.002 + random-float 0.002 * 2   set b-income/pers-paddy -0.001 - 0.002 + random-float 0.002 * 2      set b-income/pers-af -0.001 - 0.002 + random-float 0.002 * 2
    set b-extension-upcrop 0                                           set b-extension-paddy 0                                              set b-extension-af 0
    set b-subsidy-upcrop -0.009 - 0.012 + random-float 0.012 * 2       set b-subsidy-paddy -0.016 - 0.013 + random-float 0.013 * 2          set b-subsidy-af 0
    set b-0-upcrop -15.138 - 39.276 + random-float 39.276 * 2          set b-0-paddy -39.587 - 40.213 + random-float 40.213 * 2             set b-0-af -38.24 - 39.967 + random-float 39.967 * 2
   ]
]
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Labor-Independent-Income
ask turtles with [H_id > 0 and H_size > 0]
[set h_in-social H_%in-social * 0.01 * H_income
 set h_in-livestock H_%in-livestock * 0.01 * H_income
 set h_in-trading H_%in-trading * 0.01 * H_income ]
end
;--------------------------------End---------------------------------------------


;--------------------------------To----------------------------------------------
To To-Fallow
ask patches with [P_cover-type > 0 and P_owner > 0 ]
 [; For a holding patch that is currently with upland crop, the decision parameter is the ratio P_t/T_crop
  if (P_cover-type = 1)
    [let T_crop 0      		                                           ; Total cultivating time-length �Tcrop� is a local variable, the rules below are specific in HongHa (VN)
     if (P_cover-type = 1 and P_slope > 15) [set T_crop 5 ] 	       ; T_crop of annual upland crop fields on slope <15% is about 4  years
     if (P_cover-type = 1 and P_slope <= 15) [set T_crop 8 ] 	       ; T_crop of annual upland crop fields on slope >15% is about 7 years
     ifelse P_t > T_crop [set P_t 0 set P_active 0 set P_cover-type 9]
       [ifelse (random-float 1 > (P_t / T_crop))			               ; Now fire the fallow rule in random-proportional to fallow probability P_t / T_crop
               [set P_active 1]                                      ; Decide to continue to use the patch for upland cropping
               [set P_active 0 set P_t 1 set P_cover-type 9]         ; Decide to fallow the current upland cropping patch, then
                                                                     ; the land cover of the fallowed patch will be converted to grassland (P_cover-type = 9)
       ]
     ]
 ; For a holding patch that is currently fallowed, the decision parameter will be the vegetation status of the patch. Farmers will re-use the fallowed patch if
 ; the patch cover is become shrub (P_cover-type = 8) or open natural forest. Note that the fallowed patch is gradually converted to the more vegetative status
 ; due to the NaturalTransition routine.
 if (P_cover-type = 8 or P_cover-type = 7)
     [set P_active 1]

 if (P_cover-type = 9 and random-float 1 < P_t / 5)
     [set P_active 1]

 ; In the cases of paddy rice and fruit-based agroforestry, fallowing is not a consideration. However, farmers decide if evaluation for new adoption should be
 ; made, or maintaining  the previous land-use is. There is a very little chance (e.g. 1%) for the first case.
 if (P_paddyzone-fixed = 1 or P_homegarden-fixed = 1)
    [ifelse random-float 1 < 0.01
           [set P_active 1]
           [set P_active 0]
     ]
 ;
 if P_cover-type = 4 or P_cover-type = 5 [set P_active 0]
 ]
End
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Decision-Vector-Calculate
ask turtles with [H_id != 0]
   [ask patches with [P_owner = [H_id] of myself and P_active = 1 ]
       [let sum-expV 0
        let best-landuse 0 let realization 0 let Pmax 0
        let P-upcrop 0 let P-paddy 0 let P-af 0
        set  P_hij-upcrop 0  set P_hij-paddy 0  set P_hij-af 0

        set P-upcrop exp (([b-road-upcrop] of myself * P_distance-road)+ ([b-house-upcrop] of myself * distance myself) + ([b-river-upcrop] of myself * P_distance-river)
                         + ([b-slope-upcrop] of myself * P_slope) + ([b-wetness-upcrop] of myself * P_wetness) + ([b-age-upcrop] of myself * [H_age] of myself)
                         + ([b-leader-upcrop] of myself * [H_leader] of myself)+ ([b-edu-upcrop] of myself * [H_edu] of myself)
                         + ([b-labor-upcrop] of myself * [H_labor] of myself) + ([b-depend-upcrop] of myself * [H_depend] of myself)
                         + ([b-holding/pers-upcrop] of myself * [H_holding-pers] of myself) + ([b-income/pers-upcrop] of myself * [H_income-pers] of myself)
                         + ([b-extension-upcrop] of myself * [H_extension] of myself) + ([b-subsidy-upcrop] of myself * [H_subsidy] of myself) + [b-0-upcrop] of myself)

        set P-paddy exp (([b-road-paddy] of myself * P_distance-road) + ([b-house-paddy] of myself * distance myself) + ([b-river-paddy] of myself * P_distance-river)
                         + ([b-slope-paddy] of myself * P_slope)  + ([b-wetness-paddy] of myself * P_wetness) + ([b-age-paddy] of myself * [H_age] of myself)
                         + ([b-leader-paddy] of myself * [H_leader] of myself)+ ([b-edu-paddy] of myself * [H_edu] of myself)
                         + ([b-labor-paddy] of myself * [H_labor] of myself) + ([b-depend-paddy] of myself * [H_depend] of myself)
                         + ([b-holding/pers-paddy] of myself * [H_holding-pers] of myself) + ([b-income/pers-paddy] of myself * [H_income-pers] of myself)
                         + ([b-extension-paddy] of myself * [H_extension] of myself) + ([b-subsidy-paddy] of myself * [H_subsidy] of myself) + [b-0-paddy] of myself)

        set P-af exp (([b-road-af] of myself * P_distance-road)+ ([b-house-af] of myself * distance myself) + ([b-river-af] of myself * P_distance-river)
                         + ([b-slope-af] of myself * P_slope) + ([b-wetness-af] of myself * P_wetness) + ([b-age-af] of myself * [H_age] of myself)
                         + ([b-leader-af] of myself * [H_leader] of myself) + ([b-edu-af] of myself * [H_edu] of myself)
                         + ([b-labor-af] of myself * [H_labor] of myself) + ([b-depend-af] of myself * [H_depend] of myself)
                         + ([b-holding/pers-af] of myself * [H_holding-pers] of myself)  + ([b-income/pers-af] of myself * [H_income-pers] of myself)
                         + ([b-extension-af] of myself * [H_extension] of myself) + ([b-subsidy-af] of myself * [H_subsidy] of myself) + [b-0-af] of myself)
        set sum-expV  P-upcrop + P-paddy + P-af
        set P-upcrop (P-upcrop / sum-expV) set P_hij-upcrop P-upcrop
        set P-paddy  (P-paddy / sum-expV)  set P_hij-upcrop P-paddy
        set P-af     (P-af / sum-expV)     set P_hij-upcrop P-af

        while [realization = 0]
              [if (P_hij-upcrop = 0 and P_hij-paddy = 0 and P_hij-af = 0)
                 [set P_hij-upcrop P-upcrop  set P_hij-paddy P-paddy   set P_hij-af P-af] ; Now rational choice (maximizing utility), but not finally selected yet.
               if P_hij-upcrop >= P_hij-paddy and P_hij-upcrop >= P_hij-af
                 [set best-landuse 1  set Pmax P_hij-upcrop]
               if P_hij-paddy >= P_hij-upcrop and P_hij-paddy >= P_hij-af
                 [set best-landuse 2  set Pmax P_hij-paddy]
               if P_hij-af >= P_hij-paddy and P_hij-af >= P_hij-upcrop
                 [set best-landuse 3  set Pmax P_hij-af]

               ifelse random-float 1 <= Pmax                               ; Now, bounded rational choice through realizing the Pmax
                 [set realization 1
                  if best-landuse != P_cover-type [set P_t 1]              ; If land-cover change, reset P_t to be 0
                  set P_cover-type best-landuse]
                 [if best-landuse = 1 [set P_hij-upcrop 0]
                  if best-landuse = 2 [set P_hij-paddy 0]
                  if best-landuse = 3 [set P_hij-af 0]]
              ]
       ]
   ]
   show-landcover
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Constraint-Breaking
ask patches with [P_cover-type > -999]
   [set P_break 1 ; Set default value of P_break is 1.
    if (P_cover-type = 10 or P_cover-type = 11 or P_cover-type = 12 or P_slope >= 30) ; Biophysical constraints (river, road, etc.).
           [set P_break  0]
    if (P_owner > 0 or P_cover-type = 1 or P_cover-type = 2 or P_cover-type = 3 )     ; Ownership constraints (land being owned by households).
           [set P_break  0]
    if (P_protect = 1 and random-float 1 <= theta-enforce / 100 )                     ; Protection rule 1: Not allow to open new cultivation area in protected zone (enforcement = theta-enforce)
		       [set P_break  0]
		if (P_cover-type = 4 or P_cover-type = 5)                                         ; Protection rule 2: Not allow to cut and convert protective plantation (enforcement = 100%)
		   [set P_break 0]
		if (P_cover-type = 6)                                                             ; Protection rule 3: Not allow to clearly cut and replace dense natural forest (enforcement = 100%)
		   [set P_break 0]
		if (P_cover-type = 7 and random-float 1 <= theta-enforce / 100 )                  ; Protection rule 4; Not allow to clearly cut poor/open natural forest (enforcement = theta-enforce)
		   [set P_break 0]
	 ]
End

;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Decision-Matrix-Calculate
   ask patches with [P_cover-type > -999] [set P_hij-upcrop 0 set P_hij-paddy 0 set P_hij-af 0]
    let radius ((vision / 30) + random 3)
    let sum-expV 0
    let best-patch-upcrop nobody let best-patch-paddy nobody let best-patch-af nobody let best-patch nobody
    let best-landuse 0
    set  P_hij-upcrop 0  set P_hij-paddy 0  set P_hij-af 0

    let H-age H_age     let H-leader H_leader         let H-edu H_edu         let H-labor H_labor          let H-depend H_depend
    let H-holding-pers H_holding-pers    let H-income-pers H_income-pers      let H-extension H_extension  let H-subsidy H_subsidy
    let house patch-here

    let beta-road-upcrop          b-road-upcrop
    let beta-house-upcrop         b-house-upcrop
    let beta-river-upcrop         b-river-upcrop
    let beta-slope-upcrop         b-slope-upcrop
    let beta-wetness-upcrop       b-wetness-upcrop
    let beta-age-upcrop           b-age-upcrop
    let beta-leader-upcrop        b-leader-upcrop
    let beta-edu-upcrop           b-edu-upcrop
    let beta-labor-upcrop         b-labor-upcrop
    let beta-depend-upcrop        b-depend-upcrop
    let beta-holding/pers-upcrop  b-holding/pers-upcrop
    let beta-income/pers-upcrop   b-income/pers-upcrop
    let beta-extension-upcrop     b-extension-upcrop
    let beta-subsidy-upcrop       b-subsidy-upcrop
    let beta-0-upcrop             b-0-upcrop

    let beta-road-paddy          b-road-paddy
    let beta-house-paddy         b-house-paddy
    let beta-river-paddy         b-river-paddy
    let beta-slope-paddy         b-slope-paddy
    let beta-wetness-paddy       b-wetness-paddy
    let beta-age-paddy           b-age-paddy
    let beta-leader-paddy        b-leader-paddy
    let beta-edu-paddy           b-edu-paddy
    let beta-labor-paddy         b-labor-paddy
    let beta-depend-paddy        b-depend-paddy
    let beta-holding/pers-paddy  b-holding/pers-paddy
    let beta-income/pers-paddy   b-income/pers-paddy
    let beta-extension-paddy     b-extension-paddy
    let beta-subsidy-paddy       b-subsidy-paddy
    let beta-0-paddy             b-0-paddy

    let beta-road-af          b-road-af
    let beta-house-af         b-house-af
    let beta-river-af         b-river-af
    let beta-slope-af         b-slope-af
    let beta-wetness-af       b-wetness-af
    let beta-age-af           b-age-af
    let beta-leader-af        b-leader-af
    let beta-edu-af           b-edu-af
    let beta-labor-af         b-labor-af
    let beta-depend-af        b-depend-af
    let beta-holding/pers-af  b-holding/pers-af
    let beta-income/pers-af   b-income/pers-af
    let beta-extension-af     b-extension-af
    let beta-subsidy-af       b-subsidy-af
    let beta-0-af             b-0-af

    ; Now, calculate the Decision Matrix
    ask patches with [P_owner-point = [H_id] of myself and P_active = 1]
     [ask patches in-radius radius with [P_break = 1 and self != myself and (P_village = [P_village] of myself or P_village = 0 or P_village > 6)]
       [; set pcolor violet
        set P_hij-upcrop exp ((beta-road-upcrop * P_distance-road)+ (beta-house-upcrop * distance house) + (beta-river-upcrop * P_distance-river)
                         + (beta-slope-upcrop * P_slope) + (beta-wetness-upcrop * P_wetness) + (beta-age-upcrop * H-age)
                         + (beta-leader-upcrop * H-leader)+ (beta-edu-upcrop * H-edu)
                         + (beta-labor-upcrop * H-labor) + (beta-depend-upcrop * H-depend)
                         + (beta-holding/pers-upcrop * H-holding-pers) + (beta-income/pers-upcrop * H-income-pers)
                         + (beta-extension-upcrop * H-extension) + (beta-subsidy-upcrop * H-subsidy) + beta-0-upcrop)

        set P_hij-paddy exp ((beta-road-paddy * P_distance-road)+ (beta-house-paddy * distance house) + (beta-river-paddy * P_distance-river)
                         + (beta-slope-paddy * P_slope) + (beta-wetness-paddy * P_wetness) + (beta-age-paddy * H-age)
                         + (beta-leader-paddy * H-leader)+ (beta-edu-paddy * H-edu)
                         + (beta-labor-paddy * H-labor) + (beta-depend-paddy * H-depend)
                         + (beta-holding/pers-paddy * H-holding-pers) + (beta-income/pers-paddy * H-income-pers)
                         + (beta-extension-paddy * H-extension) + (beta-subsidy-paddy * H-subsidy) + beta-0-paddy)

        set P_hij-af exp ((beta-road-af * P_distance-road)+ (beta-house-af * distance house) + (beta-river-af * P_distance-river)
                         + (beta-slope-af * P_slope) + (beta-wetness-af * P_wetness) + (beta-age-af * H-age)
                         + (beta-leader-af * H-leader)+ (beta-edu-af * H-edu)
                         + (beta-labor-af * H-labor) + (beta-depend-af * H-depend)
                         + (beta-holding/pers-af * H-holding-pers) + (beta-income/pers-af * H-income-pers)
                         + (beta-extension-af * H-extension) + (beta-subsidy-af * H-subsidy) + beta-0-af)
       ]
     set sum-expV (sum [P_hij-upcrop] of  patches in-radius radius with [P_break = 1 and self != myself and (P_village = [P_village] of myself or P_village = 0 or P_village > 6)]
                      + sum [P_hij-paddy] of  patches in-radius radius with [P_break = 1 and self != myself and (P_village = [P_village] of myself or P_village = 0 or P_village > 6)]
                      + sum [P_hij-af] of  patches in-radius radius with [P_break = 1 and self != myself and (P_village = [P_village] of myself or P_village = 0 or P_village > 6)])

     ask patches in-radius radius with [P_break = 1 and self != myself and (P_village = [P_village] of myself or P_village = 0 or P_village > 6)]
        [ifelse sum-expV > 0
           [set P_hij-upcrop (P_hij-upcrop / sum-expV)
            set P_hij-paddy  (P_hij-paddy / sum-expV)
            set P_hij-af     (P_hij-af / sum-expV)]
           [set P_hij-upcrop 0 set P_hij-paddy 0 set P_hij-af 0]
        ]
     ; Now, the rational choice of location and land use
     set best-patch-upcrop max-one-of patches in-radius radius with [P_break = 1 and self != myself and (P_village = [P_village] of myself or P_village = 0 or P_village > 6)] [P_hij-upcrop] ; identify the best patch for upcrop
     set best-patch-paddy  max-one-of patches in-radius radius with [P_break = 1 and self != myself and (P_village = [P_village] of myself or P_village = 0 or P_village > 6)] [P_hij-paddy]  ; identify the best patch for paddy
     set best-patch-af     max-one-of patches in-radius radius with [P_break = 1 and self != myself and (P_village = [P_village] of myself or P_village = 0 or P_village > 6)] [P_hij-af]     ; identidy the best patch for af

     ; Now, identify the best patch, which is the overal best among the three specific best patches that have identified above; and the best land use
     if best-patch-upcrop != nobody and best-patch-paddy != nobody and best-patch-af != nobody
       [if [P_hij-upcrop] of best-patch-upcrop >= [P_hij-paddy] of best-patch-paddy and [P_hij-upcrop] of best-patch-upcrop >= [P_hij-af] of best-patch-af
               [ask best-patch-upcrop [
                set P_cover-type 1
                set P_owner-point [H_id] of myself
                set P_owner [H_id] of myself
                set P_t 1
                set P_new 1
               ]
          ]

        if [P_hij-paddy] of best-patch-paddy > [P_hij-upcrop] of best-patch-upcrop and [P_hij-paddy] of best-patch-paddy > [P_hij-af] of best-patch-af
               [ask best-patch-paddy [
                set P_cover-type 2
                set P_owner-point [H_id] of myself
                set P_owner [H_id] of myself
                set P_t 1
                set P_new 1
               ]
          ]

        if [P_hij-af] of best-patch-af > [P_hij-paddy] of best-patch-paddy and [P_hij-af] of best-patch-af > [P_hij-upcrop] of best-patch-upcrop
               [ask best-patch-af [
                set P_cover-type  3
                set P_owner-point [H_id] of myself
                set P_owner [H_id] of myself
                set P_t 1
                set P_new 1
               ]
          ]
       ]
    ]

end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Agricultural-Yield-Dynamics
let P-slope 0 let P-As 0 let P-t 0 let W-chemical-subsidy 0 let lny-upcrop 0 let lny-paddy 0 let lny-af 0
set P_yield-upcrop 0 set P_yield-paddy 0 set P_yield-af 0 set I-chem 0 set I-labor 0
if [H_cropping-area] of myself != 0 [set W-chemical-subsidy W-subsidy * 10000 / [H_cropping-area] of myself]
if P_cover-type = 1
     [set I-chem (153 - 101 + random 2 * 101) + W-chemical-subsidy
      set I-labor (681 - 101 + random 2 * 101)
      ifelse P_slope = 0 [set P-slope 1] [set P-slope P_slope]          ; correct math error due to 0 value of P_slope
      ifelse P_upslope-area = 0 [set P-As 1] [set P-As P_upslope-area]  ; correct math error due to 0 value of P_upslope-area
      ifelse P_t = 0 [set P-t 1] [set P-t P_t]                          ; correct math error due to 0 value of P_t
      set lny-upcrop 6.130 + 0.045 * ln(I-chem) + 0.368 * ln(I-labor) + (-0.271) * ln(P-slope) + 0.021 * ln(P-As) + (-0.335)* ln(P-t) ; calculate deterministic lnYield
      set lny-upcrop lny-upcrop - (0.619) + random-float (2 * 0.619)                                                                  ; calculate the random-bounded lnYield
      set P_yield-upcrop exp(lny-upcrop)]                                                                                             ; calculate Yield = exp(lnYield)

if P_cover-type = 2
     [set I-chem (2463 - 817 + random 2 * 817) + W-chemical-subsidy
      set I-labor (882 - 125 + random 2 * 125)
      ifelse P_slope = 0 [set P-slope 1] [set P-slope P_slope]          ; correct math error due to 0 value of P_slope
      ifelse P_upslope-area = 0 [set P-As 1] [set P-As P_upslope-area]  ; correct math error due to 0 value of P_upslope-area
      ifelse P_t = 0 [set P-t 1] [set P-t P_t]                          ; correct math error due to 0 value of P_t
      set lny-paddy 5.418 + 0.040 * ln(I-chem) + 0.470 * ln(I-labor) + (-0.125) * ln(P-slope) + 0.007 * ln(P-As) + (-0.029)* ln(P-t) ; calculate deterministic lnYield
      set lny-paddy lny-paddy - (0.311) + random-float (2 * 0.311)                                                                   ; calculate the random-bounded lnYield
      set P_yield-paddy exp(lny-paddy)]                                                                                              ; calculate Yield = exp(lnYield)

if P_cover-type = 3
     [set I-chem (78 - 63 + random 2 * 63) + W-chemical-subsidy
      set I-labor (448 - 118 + random 2 * 118)
      ifelse P_slope = 0 [set P-slope 1] [set P-slope P_slope]          ; correct math error due to 0 value of P_slope
      ifelse P_upslope-area = 0 [set P-As 1] [set P-As P_upslope-area]  ; correct math error due to 0 value of P_upslope-area
      ifelse P_t = 0 [set P-t 1] [set P-t P_t]                          ; correct math error due to 0 value of P_t
      set lny-af 3.117 + 0.004 * ln(I-chem) + 0.452 * ln(I-labor) + (0.221) * ln(P-slope) + 0.054 * ln(P-As) + (0.584)* ln(P-t) ; calculate deterministic lnYield
      set lny-af lny-af - (0.710) + random-float (2 * 0.710)                                                                    ; calculate the random-bounded lnYield
      set P_yield-af exp(lny-af)]                                                                                               ; calculate Yield = exp(lnYield)
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to FOREST-YIELD-DYNAMICS
ask patches with [P_cover-type = 6 or P_cover-type = 7]
   [let equilP_Gr 38
    let epsilon 10 ^ -6
    let maxZ_G 1.29
    let a  maxZ_G / (equilP_Gr ^ epsilon * (epsilon ^(epsilon /(1 - epsilon)) - epsilon ^(1 /(1 - epsilon))))
    let b  maxZ_G / (equilP_Gr * (epsilon ^(epsilon /(1 - epsilon)) - epsilon ^(1 /(1 - epsilon))))
    let g_logged 0.2827 + random-float 0.3534 ; size of an logged tree
    let N_logged 1 ; number of tree on the patch (900 m2) is logged.
    let logged_amount 0
    let G_damage 0
    let G_mortality 0 ; Note: Household must set this in the forest choice
    let Z_G 0
    set Z_G  a * (P_yield-forest ^ epsilon) - b * P_yield-forest         ; calculate the net natural growth Z_G

    ifelse P_logged = 1
          [set logged_amount    N_logged * g_logged * 10000 / 900
           set G_damage  P_yield-forest * (0.0052 * N_logged + 0.0536)   ; calculate logging damage
           set Pt 1]
          [set G_damage 0
           if Pt > 0 [set Pt Pt + 1]]

    if  Pt > 1 and Pt <= 4
       [set G_mortality P_yield-forest * (0.0058 * N_logged + 0.0412)]   ; calculate logging-induced mortality
    set P_yield-forest  (P_yield-forest + Z_G - (logged_amount + G_damage + G_mortality / 3)) ; calculate the net actual growth
    set P_logged 0
   ]

ask patches with [P_cover-type = 5]
   [let equilP_Gr 38
    let epsilon 10 ^ -6
    let maxZ_G 1.5
    let a  maxZ_G / (equilP_Gr ^ epsilon * (epsilon ^(epsilon /(1 - epsilon)) - epsilon ^(1 /(1 - epsilon))))
    let b  maxZ_G / (equilP_Gr * (epsilon ^(epsilon /(1 - epsilon)) - epsilon ^(1 /(1 - epsilon))))
    let g_logged 0.2827 + random-float 0.3534 ; size of an logged tree
    let N_logged 1 ; number of tree on the patch (900 m2) is logged.
    let logged_amount 0
    let G_damage 0
    let G_mortality 0 ; Note: Household must set this in the forest choice
    let Z_G 0
    set Z_G  a * (P_yield-forest ^ epsilon) - b * P_yield-forest         ; calculate the net natural growth Z_G
    ifelse P_logged = 1
          [set logged_amount    N_logged * g_logged * 10000 / 900
           set G_damage  P_yield-forest * (0.0052 * N_logged + 0.0536)   ; calculate logging damage
           set Pt 1]
          [set G_damage 0
           if Pt > 0 [set Pt Pt + 1]]
    if  Pt > 1 and Pt <= 4
       [set G_mortality P_yield-forest * (0.0058 * N_logged + 0.0412)]   ; calculate logging-induced mortality
    set P_yield-forest  (P_yield-forest + Z_G - (logged_amount + G_damage + G_mortality / 3)) ; calculate the net actual growth
   ]
show "Forest-Yield-Dynamics: Passed"
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Natural-Transition

ask patches
[if P_cover-type = 6 [set P_nat-forest 1]
 if P_cover-type = 7 [set P_nat-forest 2]]

; Transition rule N1
ask patches with [P_cover-type = 6 or P_cover-type = 7]
   [ifelse P_yield-forest > 25.61  [set P_cover-type 6] [set P_cover-type 7]
    if P_yield-forest < 1.00 [set P_cover-type 8]   ]

; Transition rule N2
ask patches with [P_cover-type = 8]
   [if (any? neighbors4 with [P_nat-forest = 2]) = true
      [if random-float 1 < 1 / (15 + random 6) [set P_cover-type 7 set P_yield-forest 1.00 set P_t 1]]
    if (any? neighbors4 with [P_nat-forest = 1]) = true
          [if random-float 1 < 1 / (7 + random 4) [set P_cover-type 7 set P_yield-forest 1.00 set P_t 1]]
   ]

; Transition rule N3
ask patches with [P_cover-type = 9]
   [if (any? neighbors with [P_nat-forest = 1 or P_nat-forest = 2] = true)
      [if random-float 1 <= 1 / (1 + random 3) [set P_cover-type 8 set P_t 1]]
   ]

; Transition rule N4
ask patches with [P_cover-type = 4]
   [if P_t > 3 + random 2 [set P_cover-type 5 set P_t 1 set P_yield-forest 1 + random-float 4]]

show-landcover
show "Natural-Transition: Passed"
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to Create-New-Households
; calculate the annual increment of the total household number, using the equation: Y = aT^b, or increment Y = ab(Y/a)^((b-1)/b), where Y - total number of households
; in the previous time-point, T- elapsed years, a and b - coefficients. According to the Chapter 4 (Figure 4-2), a = 22, and b = 0.75
let a 22 let b 0.75
let N_hhs count turtles
let hhs-increment round (a * b * (N_hhs / a)^ ((b - 1) / b) - 1 + random-float 1)

ask n-of hhs-increment turtles  with [H_age >= 22 and H_age <= 28]
   [hatch 1                                                                   ; i)Create new turtles, each identical to its parent
       [set H_id H_id + 300                                                               ;   create H_id for the new household
        set H_name "hatched_3"
        ask patches with [P_owner-point = ([H_id] of myself - 300)]             ; ii) Generate new holding parcel center point for the new household
            [sprout 1 [set H_id [P_owner-point] of patch-here + 300   ; sprout a temporary turle on each center of the holding parcel of the parent turtle
                       set H_village [P_village] of patch-here
                       set parcel_cover [P_cover-type] of patch-here  ; and copy data on i) owner, 2) village, 3) cover type and 4) parcel area to store in this new sprouted
                       set parcel_area  [P_parcel-area] of patch-here ; turtle. The spouted turtles will act as the information transporters (i.e., transporter)
                       let random_patch2 one-of patches with [(P_owner-point = 0) and (P_village = [H_village] of myself) and (P_cover-type = [parcel_cover] of myself)]
                       if random_patch2 != nobody
                      [ask random_patch2                                      ; The transporter turtle select randomly a patch, bounded by the following conditions
                          [move-to random_patch2
                           set P_owner-point  [H_id] of myself                  ; The sprouted turtle transfers information on cover type (from the parrent parcel) to the new parcel
                           set P_cover-type   [parcel_cover] of myself          ; The sprouted
                           set P_parcel-area  [parcel_area] of myself           ; Transfer information on parcel area from the parrent patch for the new patch

                           set P_owner P_owner-point                          ; iii) create the holding parcel
                           let n-patch round(P_parcel-area / 900)
                           if n-patch = 0 [set n-patch 1]
                           let radius 1
                           while [(count (patches in-radius-nowrap radius with [P_cover-type = [P_cover-type] of myself and P_owner-point = 0])) <= n-patch]
                                 [set radius (radius + 1)]
                           ask n-of n-patch patches in-radius-nowrap radius with [P_cover-type = [P_cover-type] of myself and P_owner-point = 0]
                                 [set P_owner [P_owner-point] of myself]
                          ]]
                       die                                                    ; after the sprouted turtle finishes his duty, he disappears.
                      ]
              ]
         let random_patch3 one-of patches with [P_owner-point = [H_id] of myself and P_village = [H_village] of myself and P_cover-type = 3]
         ifelse random_patch3 != nobody                                       ; iv) Set the house location of the hatched household
              [ask random_patch3                                              ;
                      [move-to random_patch3] ]                           ; Set y-coordinate of the new household's house

              [
            ask one-of patches with [P_owner-point = [H_id] of myself or (P_distance-road < 180 and P_village = [H_village] of myself)];
                      [move-to patch-here] ]                           ; Set y-coordinate of the new household's house
       ]
    ]
ask turtles with [H_id = 0] [die] ; remove empty households, in the case they exist
show "Create-New-Household: passed"
end
;--------------------------------End---------------------------------------------


;--------------------------------To----------------------------------------------
to SET-LABOR-BUDGET
ask turtles with [H_size > 0]
   [set L-crop       %L-crop * 0.01 * H_labor * 360
    set L-livestock  %L-livestock * 0.01 * H_labor * 360
    set L-logging    %L-logging * 0.01 * H_labor * 360
    set L-NTFPs      %L-NTFPs * 0.01 * H_labor * 360
    set L-others     %L-others * 0.01 * H_labor * 360 ]
show "set-labor-budget: passed"
end
;-------------------------------End----------------------------------------------


;-------------------------------To-----------------------------------------------
to FARMLAND-CHOICE

; Now, start with static phase
To-Fallow
show "To-Fallow: passed"

Decision-Vector-Calculate
show "Decision-Vector-Calculate: passed"

ask turtles with [H_id != 0 and H_size > 0]
   [set H_cropping-area (count patches with [P_active = 1 and P_owner = [H_id] of myself] * 900)
    if L-crop > 0  [ask patches with [P_owner = [H_id] of myself and P_cover-type = 2 and P_upslope-area >= 0]
                       [Agricultural-Yield-Dynamics]
                    set L-crop L-crop - sum [I-labor * 0.09] of patches with [P_owner = [H_id] of myself and P_cover-type = 2]
                   ]

    if L-crop > 0  [ask patches with [P_owner = [H_id] of myself and P_cover-type = 1 and P_upslope-area >= 0]
                       [Agricultural-Yield-Dynamics]
                    set L-crop L-crop - sum [I-labor * 0.09] of patches with [P_owner = [H_id] of myself and P_cover-type = 1]
                   ]

    if L-crop > 0  [ask patches with [P_owner = [H_id] of myself and P_cover-type = 3 and P_upslope-area >= 0]
                       [Agricultural-Yield-Dynamics]
                    set L-crop L-crop - sum [I-labor * 0.09] of patches with [P_owner = [H_id] of myself and P_cover-type = 3]
                   ]
   ]
show "Static Phase: passed"

; Now, start with mobile phase
ask patches with [P_elevation > -999] [set P_new 0]
ask turtles with [H_id != 0 and H_size > 0]
   [set H_cropping-area 0 ; This is just to make sure that the household do not apply chemical fertilizer in the newly opened plots
    while [L-crop > 0]
          [Constraint-Breaking
           Decision-Matrix-Calculate
           ask patches with [P_new = 1 and P_owner = [H_id] of myself and P_upslope-area > 0]
              [Agricultural-Yield-Dynamics]
           let spent-labor sum [I-labor * 0.09] of patches with [P_new = 1 and P_owner = [H_id] of myself]
           ifelse spent-labor != 0 [set L-crop L-crop - spent-labor]
                                   [set L-logging L-logging + L-crop * 1 / 3
                                    set L-NTFPs L-NTFPs + L-crop * 1 / 3
                                    set L-others L-others + L-crop * 1 / 3
                                    set L-crop 0]
          ]
   ]

ask patches with [P_cover-type > 0 and P_owner > 0] [set P_t P_t + 1]

show "Mobile phase: passed"
Show-Landcover


; Now, update income from crop production. Note: H_%in-upcrop, H_%in-paddy and H_%in-af at this stage is absolute values, have not yet converted into %.
ask turtles with [H_id != 0 and H_size > 0]
   [set h_in-upcrop sum [P_yield-upcrop * 0.09 * 2] of patches with [P_owner = [H_id] of myself and P_cover-type = 1 and P_yield-upcrop > 0] ; x2 because price: 1 kg raw rice = 2k VND
    set h_in-paddy sum [P_yield-paddy * 0.09 * 2] of patches with [P_owner = [H_id] of myself and P_cover-type = 2 and  P_yield-paddy > 0]
    set h_in-af sum [P_yield-af * 0.09 * 2] of patches with [P_owner = [H_id] of myself and P_cover-type = 3 and  P_yield-af > 0]
   ]
show "Update absolute income of crop production: passed"

show "Farmland-Choice: passed"
end
;-------------------------------End----------------------------------------------

;--------------------------------To----------------------------------------------
to FOREST-CHOICE
; Now, to log forest tree
ask patches with [P_cover-type > -999] [set P_logged 0]
ask turtles
   [set H_%in-logging 0 set H_%in-NTFPs 0
    while [L-logging > 0 ]
          [let nearest-forest-patch nobody
                while [nearest-forest-patch = nobody] [
                     set nearest-forest-patch  min-one-of patches with [P_cover-type = 6] [distance myself]
                ]
           let min-distance distance nearest-forest-patch
           let logged-patch one-of patches with [P_cover-type = 6 and distance myself >= min-distance and distance myself <= min-distance + 50 and P_logged = 0]
           if logged-patch = nobody [set logged-patch one-of patches with [P_cover-type = 6]]
           let labor-spent 3 + random 3  ; To log a forest tree of about 60 - 90 cm of dbh by axe, the household usually spends about 3 - 5 days
           if random-float 1 > theta-enforce / 100
              [ask logged-patch [
                  set P_logged 1
               set h_in-logging h_in-logging + labor-spent * (25 + random 6); labor cost of logging in Hongha: 25 - 30,000 VND /day.
                  ]
              ]
           set L-logging  L-logging - labor-spent
          ]
     set h_in-NTFPs L-NTFPs * (15 + random 10);
    ]
ask patches with [P_cover-type = 4 or P_cover-type = 5]
   [set P_t P_t + 1]
show "Forest-Choice: passed"
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
; This procedure generates incomes from livestock production and other activities
to GENERATE-OTHER-INCOME
ask turtles with [H_id > 0 and H_size > 0]
   [set h_in-livestock  (h_in-livestock - (0.05 * h_in-livestock) + random-float (0.1 * h_in-livestock)) ; +-%5 random fluctuation
    set h_in-social      h_in-social
    set h_in-trading    (h_in-trading - (0.05 * h_in-trading) + random-float (0.1 * h_in-trading)) ; +-%5 random fluctuation
    set h_in-sold-labor  L-others * (15 + random 10)
   ]
end
;--------------------------------End---------------------------------------------

;--------------------------------To----------------------------------------------
to UPDATE-HOUSEHOLDS-STATE
ask turtles with [H_id != 0 and H_size > 0]
   [; Update H_age
    ifelse H_age >= 76 + random (2 * 2)   ; This means maxH_age is about 76 - 80 years-old. Standard error of H_age = 2
           [set H_age (20 + random (2 * 2))] ; This means minH_age is about 20 - 24 years-old.
           [set H_age (H_age + 1)]

    ; Update H_edu
    if H_edu = 0
      [if random-float 1 < (theta-edu / 100) [set H_edu 1] ]

    ; Update H_size
    set H_size H_size

    ; Update H_labor
    set H_labor (H_labor - 0.14 + random-float (0.28))

    ; Update H_depend
    set H_depend (H_depend - 0.1 + random-float (0.2))

    ; Update H_extension
    ifelse (random-float 1) < (theta-extension / 100)
       [set H_extension 1 ]
       [set H_extension 0 ]

    ; Update H_subsidy
    ifelse (random-float 1) < (theta-subsidy / 100)
       [set H_subsidy W-subsidy ]
       [set H_subsidy 0 ]

    ; Update income composition
    set H_income       (h_in-upcrop + h_in-paddy + h_in-af + h_in-logging + h_in-NTFPs + h_in-livestock + h_in-sold-labor + h_in-trading + h_in-social)
    set H_income-pers   h_income / h_size

    if H_income != 0
    [set H_%in-upcrop    h_in-upcrop * 100 / H_income
     set H_%in-paddy     h_in-paddy * 100 / H_income
     set H_%in-af        h_in-af * 100 / H_income
     set H_%in-crop      (H_%in-upcrop + H_%in-paddy + H_%in-af)

     set H_%in-livestock h_in-livestock * 100 / H_income

     ; set H_%in-forestry   (H_%in-logging + H_%in-NTFPs) * 100 / H_income ; as in version 1-x
     set H_%in-logging   H_in-logging * 100 / H_income
     set H_%in-NTFPs     H_in-NTFPs * 100 / H_income
     set H_%in-forestry   (H_in-logging + H_in-NTFPs) * 100 / H_income ; adjusted in this version (version 2-x)

     ; set H_%in-others   (H_%in-sold-labor + H_%in-trading + H_%in-social) * 100 / H_income ; as in version 1-x
     set H_%in-trading   H_in-trading * 100 / H_income
     set H_%in-sold-labor H_in-sold-labor * 100 / H_income
     set H_%in-social    H_in-social * 100 / H_income
     set H_%in-others   (H_in-sold-labor + H_in-trading + H_in-social) * 100 / H_income ; adjusted in this version (version 2-x)
    ]

    ; Now, update landholding composition
    set H_holding count patches with [P_owner = [H_id] of myself] * 900
    if H_holding = 0 [die]
    set H_holding-pers H_holding / H_size
    set H_%upcrop count patches with [P_owner = [H_id] of myself and P_cover-type = 1] * 900 * 100 / H_holding
    set H_%paddy count patches with [P_owner = [H_id] of myself and P_cover-type = 2] * 900 * 100 / H_holding
    set H_%af count patches with [P_owner = [H_id] of myself and P_cover-type = 3] * 900 * 100 / H_holding
    set H_%plantation count patches with [P_owner = [H_id] of myself and (P_cover-type = 4 or P_cover-type = 5)] * 900 * 100 / H_holding
    set H_%fallow count patches with [P_owner = [H_id] of myself and (P_cover-type = 8 or P_cover-type = 9 or P_cover-type = 7)] * 900 * 100 / H_holding
  ]
show "Updating the household's profile: passed"
end
;--------------------------------End---------------------------------------------


;------------------------------To-------------------------------------------------
to DRAW-GRAPHS
Draw-Coverage-of-Main-Type
Draw-ForestCoverage-vs-Distance-to-Road
Draw-ForestYield-Non-Disturbed-Stand
Draw-ForestYield-Disturbed-Stand



Draw-Population
Draw-Size-of-HouseholdGroup1
Draw-Size-of-HouseholdGroup2
Draw-Size-of-HouseholdGroup3

Draw-Area-of-Cultivated-Land
Draw-FarmSize-HouseholdGroup1
Draw-FarmSize-HouseholdGroup2
Draw-FarmSize-HouseholdGroup3

Draw-Yield-of-Agricultural-Type
Draw-Yield-of-Agricultural-Type-HouseholdGroup1
Draw-Yield-of-Agricultural-Type-HouseholdGroup2
Draw-Yield-of-Agricultural-Type-HouseholdGroup3

Draw-GrossIncome
Draw-Lorenz-Gini
Draw-GrossIncome-HouseholdGroup1
Draw-GrossIncome-HouseholdGroup2
Draw-GrossIncome-HouseholdGroup3

show "Draw-Graphs: Passed"
show "This year has been passed! Congratulation"
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-Coverage-of-Main-Type
  let total-area count patches with [p_cover-type > -999]
  let rich-forest ((count patches with [p_cover-type = 6]) / total-area) * 100
  let poor-forest ((count patches with [p_cover-type = 7]) / total-area) * 100
  let shrub ((count patches with [p_cover-type = 8]) / total-area) * 100
  let grass ((count patches with [p_cover-type = 9]) / total-area) * 100
  let plantation ((count patches with [p_cover-type = 4 or p_cover-type = 5]) / total-area) * 100
  let cultivated ((count patches with [p_cover-type = 1 or p_cover-type = 2 or p_cover-type = 3]) / total-area) * 100


  set-current-plot "Coverage of the main land-use/cover types"
  set-current-plot-pen "Dense/rich natural forest"
  plot rich-forest
  set-current-plot-pen "Open/poor natural forest"
  plot poor-forest
  set-current-plot-pen "Shrub land"
  plot shrub
  set-current-plot-pen "Grass land"
  plot grass
  set-current-plot-pen "Acacia plantation"
  plot plantation
  set-current-plot-pen "Cultivated land"
  plot cultivated

end
;------------------------------End------------------------------------------------
;------------------------------To-------------------------------------------------
to Draw-ForestCoverage-vs-Distance-to-Road
  let total-area-1km count patches with [p_distance-road >= 0 and p_distance-road < 1000]
  let rich-forest-1km ((count patches with [p_cover-type = 6 and p_distance-road >= 0 and p_distance-road < 1000 ]) / total-area-1km) * 100

  let total-area-2km count patches with [p_distance-road >= 0 and p_distance-road < 2000]
  let rich-forest-2km ((count patches with [p_cover-type = 6 and p_distance-road < 2000 ]) / total-area-2km) * 100

  let total-area-3km count patches with [p_distance-road >= 0 and p_distance-road < 3000]
  let rich-forest-3km ((count patches with [p_cover-type = 6 and p_distance-road >= 0 and p_distance-road < 3000 ]) / total-area-3km) * 100

  let total-area-4km count patches with [p_distance-road >= 0 and p_distance-road < 4000]
  let rich-forest-4km ((count patches with [p_cover-type = 6 and p_distance-road >= 0 and p_distance-road < 4000 ]) / total-area-4km) * 100

  let total-area-whole count patches with [p_cover-type > -999]
  let rich-forest-whole ((count patches with [p_cover-type = 6]) / total-area-whole) * 100


  set-current-plot "Dense natural forest coverage at different scales"
  set-current-plot-pen "Zone with D-road < 1km"
  plot rich-forest-1km
  set-current-plot-pen "Zone with D-road < 2km"
  plot rich-forest-2km
  set-current-plot-pen "Zone with D-road < 3km"
  plot rich-forest-3km
  set-current-plot-pen "Zone with D-road < 4km"
  plot rich-forest-4km
  set-current-plot-pen "Whole watershed"
  plot rich-forest-whole
 end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-ForestYield-Non-Disturbed-Stand
  ; ask patches with [pxcor >= -169 and pxcor <= -158 and pycor >= 109 and pycor <= 118]  [set pcolor red]
  let forest-yield-non-disturbed mean [P_yield-forest] of patches with [pxcor >= -169 and pxcor <= -158 and pycor >= 109 and pycor <= 118]

  set-current-plot "Yield of a 15ha-forest stand (remote)"
  set-current-plot-pen "Stand basal area"
  plot forest-yield-non-disturbed
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-ForestYield-Disturbed-Stand
  ; ask patches with [pxcor >= 55 and pxcor <= 64 and pycor >= 72 and pycor <= 81]  [set pcolor red]
  let forest-yield-disturbed mean [P_yield-forest] of patches with [pxcor >= 55 and pxcor <= 64 and pycor >= 72 and pycor <= 81]

  set-current-plot "Yield of a 15ha-forest stand (not far)"
  set-current-plot-pen "Stand basal area"
  plot forest-yield-disturbed
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
To Show-Monitored-Stands
ask patches with [((pxcor = -169 or pxcor = -158) and (pycor >= 109 and pycor <= 118)) or ((pxcor >= -169 and pxcor <= -158) and (pycor = 109 or pycor = 118))  ]  [set pcolor red]
ask patches with [((pxcor = 55 or pxcor = 64) and (pycor >= 72 and pycor <= 81)) or ((pxcor >= 55 and pxcor <= 64) and (pycor = 72 or pycor = 81))]  [set pcolor red]
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-Area-of-Cultivated-Land
  let area-upcrop count patches with [p_cover-type = 1] * 0.09
  let area-paddy  count patches with [p_cover-type = 2] * 0.09
  let area-af     count patches with [p_cover-type = 3] * 0.09

  set-current-plot "Area of cultivated cover types"
  set-current-plot-pen "Upland crop"
  plot area-upcrop
  set-current-plot-pen "Paddy rice"
  plot area-paddy
  set-current-plot-pen "Agroforestry"
  plot area-af

end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-Yield-of-Agricultural-Type
  let average-upcrop-yield mean [P_yield-upcrop] of patches with [p_cover-type = 1] / 1000 ;(orgiginal unit: kg rice/ha/yr, plotted unit: ton rice/ha/yr)
  let average-paddy-yield mean [P_yield-paddy] of patches with [p_cover-type = 2] / 1000
  let average-af-yield mean [P_yield-af] of patches with [p_cover-type = 3] / 1000

  set-current-plot "Average yield of agricultural type"
  set-current-plot-pen "Upland crop"
  plot average-upcrop-yield

  set-current-plot-pen "Paddy rice"
  plot average-paddy-yield

   set-current-plot-pen "Agroforestry"
  plot average-af-yield
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-Population
  let households count turtles with [H_id > 0]
  let persons sum [H_size] of turtles with [H_id > 0]

  set-current-plot "Total population"
  set-current-plot-pen "Households"
  plot households
  set-current-plot-pen "Persons"
  plot persons

end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-GrossIncome
  let total-gross-income mean [H_income-pers] of turtles with [H_size > 0]
  let gross-income-crop mean [ H_income-pers * (H_%in-upcrop + H_%in-paddy + H_%in-af) * 0.01] of turtles with [H_size > 0]
  let gross-income-livestock mean [H_income-pers * H_%in-livestock * 0.01] of turtles with [H_size > 0]
  let gross-income-logging mean [H_income-pers * H_%in-logging * 0.01] of turtles with [H_size > 0]
  let gross-income-NTFPs mean [H_income-pers * H_%in-NTFPs * 0.01] of turtles with [H_size > 0]
  let gross-income-others mean [H_income-pers * H_%in-others * 0.01] of turtles with [H_size > 0]

  set-current-plot "Household gross income and structure"

  set-current-plot-pen "Gross income"
  plot total-gross-income

  set-current-plot-pen "from Crop"
  plot gross-income-crop

  set-current-plot-pen "from Livestock"
  plot gross-income-livestock

  set-current-plot-pen "from Logging"
  plot gross-income-logging

  set-current-plot-pen "from NTFPs"
  plot gross-income-NTFPs

  set-current-plot-pen "from Others"
  plot gross-income-others
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-Lorenz-Gini
  let num-households count turtles with [H_size > 0]
  set-current-plot "Lorenz Curve"
  clear-plot

  ;draw a straight line from lower left to upper right
  set-current-plot-pen "Equal curve"
  plot 0
  plot 100

  set-current-plot-pen "Lorenz curve"
  set-plot-pen-interval 100 / num-households
  plot 0

  let sorted-wealths sort [H_income] of turtles
  let total-wealth sum sorted-wealths
  let wealth-sum-so-far 0
  let index 0
  let gini-index-reserve 0

  ;; now actually plot the Lorenz curve -- along the way, we also
  ;; calculate the Gini index
  repeat num-households [
    set wealth-sum-so-far (wealth-sum-so-far + item index sorted-wealths)
    plot (wealth-sum-so-far / total-wealth) * 100
    set index (index + 1)
    set gini-index-reserve
      gini-index-reserve +
      (index / num-households) -
      (wealth-sum-so-far / total-wealth)
  ]

  ;; plot Gini Index
  set-current-plot "Gini index vs. time"
  plot (gini-index-reserve / num-households) / area-of-equality-triangle
end

to-report area-of-equality-triangle
  ;; not really necessary to compute this when num-households is large;
  ;; if num-household is large, could just use estimate of 0.5
  let num-households count turtles with [H_size > 0]
  report (num-households * (num-households - 1) / 2) / (num-households ^ 2)
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to reduce-households-to-be-quicker
ask turtles with [who > 30] [die]
end

To Map-for-print
ask patches with [P_cover-type = -999]
[set Pcolor white]
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
To Quick-Import
import-world "c:\\VN-LUDAS\\outputs\\S0_world_0yr.csv"
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
;to Export-Landscape-Data
;let filename1 "P_LandUse_"
;let filename2 "P_ForestYield_"
;let filename3 "P_PaddyYield_"
;let filename4 "P_UpcropYield_"
;let filename5 "P_AfYield_"
;let filename6 "P_Holdings_"
;
;let suffix1 word elapsed-years "yr.png"
;let suffix2 word elapsed-years "yr.txt"
;
;;; Now, export maps of several dynamic landscape variables in png image files (for illustration only)
;Map-for-print ; converting "null" area into white color
;export-view directory-out + filename1 + scenario-name + "_" + run-replicate + "_" + suffix1 ; Exporting png file of land-use/cover
;Show-Stand-Basal-Area
;export-view directory-out + filename2 + scenario-name + "_" + run-replicate + "_" + suffix1 ; Exporting png file of forest yield
;Show-Holdings
;export-view directory-out + filename6 + scenario-name + "_" + run-replicate + "_" + suffix1 ; Exporting png file of household's land (i.e. holdings)
;show-landcover
;
;;; Now, export the raster file of land-use/cover
;file-open directory-out + filename1 + scenario-name + "_" + run-replicate + "_" + suffix2
;ask patches
;[
;file-write p_cover-type
;]
;file-close
;
;;; Now, export the raster file of forest yield
;file-open directory-out + filename2 + scenario-name + "_" + run-replicate + "_" + suffix2
;ask patches
;[
;file-write p_yield-forest
;]
;file-close
;
;;; Now, export the raster file of paddy rice yield
;file-open directory-out + filename3 + scenario-name + "_" + run-replicate + "_" + suffix2
;ask patches
;[
;file-write p_yield-paddy
;]
;file-close
;
;;; Now, export the raster file of upland crop yield
;file-open directory-out + filename4 + scenario-name + "_" + run-replicate + "_" + suffix2
;ask patches
;[
;file-write p_yield-upcrop
;]
;file-close
;
;;; Now, export the raster file of agroforestry yield
;file-open directory-out + filename5 + scenario-name + "_" + run-replicate + "_" + suffix2
;ask patches
;[
;file-write p_yield-af
;]
;file-close
;
;;; Now, export the raster file of household land (household explicit via H_id)
;file-open directory-out + filename6 + scenario-name + "_" + run-replicate + "_" + suffix2
;ask patches
;[
;file-write p_owner
;]
;file-close
;
;end
;;----------------------------------------End--------------------------------------
;
;;------------------------------To-------------------------------------------------
;to Export-Household-Data
;let test "test_"
;let file-name1 "H_Group_"
;let file-name2 "H_Size_"
;let file-name3 "H_Labor_"
;let file-name4 "H_Depend_"
;let file-name5 "H_Edu_"
;let file-name6 "H_HoldingPer_"
;let file-name7 "H_NPlots_"
;let file-name8 "H_%Paddy_"
;let file-name9 "H_%UpCrop_"
;let file-name10 "H_%Af_"
;let file-name11 "H_%Plantation_"
;let file-name12 "H_%Fallow_"
;let file-name13 "H_IncomePer_"
;let file-name14 "H_%In-Paddy_"
;let file-name15 "H_%In-Upcrop_"
;let file-name16 "H_%In-Af_"
;let file-name17 "H_%In-Livestock_"
;let file-name18 "H_%In-Forestry_"
;let file-name19 "H_%In-Others_"
;
;let file-name20 "H_%In-Logging_"
;let file-name21 "H_%In-NTFPs_"
;let file-name22 "H_%In-Social_"
;let file-name23 "H_%In-Labor_"
;let file-name24 "H_%In-Trading"
;
;let suffix elapsed-years + "yr.txt"
;
;;; Now, export the csv file of H_group
;file-open directory-out + file-name1 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_g
;]
;file-close
;
;;; Now, export the csv file of H_size
;file-open directory-out + file-name2 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_size
;]
;file-close
;
;;; Now, export the csv file of H_Labor
;file-open directory-out + file-name3 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_labor
;]
;file-close
;
;;; Now, export the csv file of H_depend
;file-open directory-out + file-name4 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_depend
;]
;file-close
;
;;; Now, export the csv file of H_edu
;file-open directory-out + file-name5 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_edu
;]
;file-close
;
;;; Now, export the csv file of H_holding-per
;file-open directory-out + file-name6 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_holding-pers
;]
;file-close
;
;;; Now, export the csv file of H_nplots
;file-open directory-out + file-name7 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_nplots
;]
;file-close
;
;;; Now, export the csv file of H_%paddy
;file-open directory-out + file-name8 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%paddy
;]
;file-close
;
;;; Now, export the csv file of H_%upcrop
;file-open directory-out + file-name9 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%upcrop
;]
;file-close
;
;;; Now, export the csv file of H_%af
;file-open directory-out + file-name10 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%af
;]
;file-close
;
;;; Now, export the csv file of H_%plantation
;file-open directory-out + file-name11 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%plantation
;]
;file-close
;
;;; Now, export the csv file of H_%fallow
;file-open directory-out + file-name12 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%fallow
;]
;file-close
;
;;; Now, export the csv file of H_Income-Pers
;file-open directory-out + file-name13 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_Income-pers
;]
;file-close
;
;;; Now, export the csv file of H_%in-paddy
;file-open directory-out + file-name14 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%in-paddy
;]
;file-close
;
;;; Now, export the csv file of H_%in-upcrop
;file-open directory-out + file-name15 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%in-upcrop
;]
;file-close
;
;;; Now, export the csv file of H_%In-Af
;file-open directory-out + file-name16 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%in-af
;]
;file-close
;
;;; Now, export the csv file of H_%in-Livestock
;file-open directory-out + file-name17 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%In-livestock
;]
;file-close
;
;;; Now, export the csv file of H_%in-forestry
;file-open directory-out + file-name18 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%In-forestry
;]
;file-close
;
;;; Now, export the csv file of H_%In-others
;file-open directory-out + file-name19 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%In-others
;]
;file-close
;
;;; Now, export the csv file of H_%In-logging
;file-open directory-out + file-name20 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%In-logging
;]
;file-close
;
;;; Now, export the csv file of H_%In-NTFPs
;file-open directory-out + file-name21 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%In-NTFPs
;]
;file-close
;
;;; Now, export the csv file of H_%In-Social
;file-open directory-out + file-name22 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%In-social
;]
;file-close
;
;;; Now, export the csv file of H_%In-Sold-labor
;file-open directory-out + file-name23 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%In-Sold-labor
;]
;file-close
;
;;; Now, export the csv file of H_%In-trading
;file-open directory-out + file-name24 + scenario-name + "_" + run-replicate + "_" + suffix
;ask turtles
;[
;file-write H_%In-trading
;]
;file-close
;
;end
;;----------------------------------------End--------------------------------------
;;------------------------------To-------------------------------------------------
;to Select-Output-Directory
;set directory-out user-directory
;set scenario-name user-input "Please type a name of your defined scenario (e.g. S0)! This name will be included in simulated output files to be distinguished from other scenarios"
;set run-replicate user-input "Please type a name of your replication (e.g. Re1)! This name will be included in simulated output files to be distinguished from other scenarios"
;end
;;---------------------------------End----------------------------------------------
;
;;------------------------------To-------------------------------------------------
;to Quick-Export-LUCC-Data
;let directory user-directory
;let filename1 directory + user-input "Please type the name of the output image file: ___.png"
;let filename2 directory + user-input "Please type the name of the output data file: ___.txt"
;export-view filename1
;file-open filename2
;ask patches
;[
;file-write p_cover-type
;]
;file-close
;end
;;---------------------------------End----------------------------------------------

;------------------------------To-------------------------------------------------
to Status-message
show word "Running scenario: " scenario-name
show word "Replication: " run-replicate
end
;---------------------------------End----------------------------------------------

;------------------------------To-------------------------------------------------
; to Set-Policy-Factors
; set number-of-initial-households 240  ; the default value of innitial total population is 240, as the current status in 2002
; set vision 480  ; the default value of household vision is 480m of radius, as interviewed in 2002
; set average-annual-rainfall 2700  ; the default value of annual rainfall is 2700 mm, as the average of 10 years
; set theta-protect 9.5  ; the default value of the protection score threshold is 9.5 (using FIPI scale), as the current policy setting in 2002
; set theta-enforce 50 ; the default value of policy enforcement for foprest protection rules is 50%, as the current status in 2002
; set theta-extension 67 ; the default value of population percentage reached by agricultural extension services is 67%, as the current status in 2002
; set theta-subsidy 23 ; the default value of population percentage subsidized by agrochemicals is 23%, as the current status in 2002
; set W-subsidy 260 ; the default value of agrochemical subsidy amount is 260,000 VND/household/yr, as the current status in 2002
; set theta-edu 10 ; the default value of annual coverage in adult education is 10%
; if (user-choice "Experimental set-up for INITIAL POPULATION: Yes- Please change the related slider as you want No- Accept the default value " [ "yes" "No"]) = "yes"
;  [ Halt ]
; end
;---------------------------------------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-Size-of-HouseholdGroup1
  let group-size-household count turtles with [H_g = 1]
  let group-size-person sum [H_size] of turtles with [H_g = 1]

  set-current-plot "Population of household group 1"
  set-current-plot-pen "No. of households"
  plot group-size-household
  set-current-plot-pen "No. of persons"
  plot group-size-person

end
;------------------------------End------------------------------------------------
;------------------------------To-------------------------------------------------
to Draw-Size-of-HouseholdGroup2
  let group-size-household count turtles with [H_g = 2]
  let group-size-person sum [H_size] of turtles with [H_g = 2]

  set-current-plot "Population of household group 2"
  set-current-plot-pen "No. of households"
  plot group-size-household
  set-current-plot-pen "No. of persons"
  plot group-size-person

end
;------------------------------End------------------------------------------------
;------------------------------To-------------------------------------------------
to Draw-Size-of-HouseholdGroup3
  let group-size-household count turtles with [H_g = 3]
  let group-size-person sum [H_size] of turtles with [H_g = 3]

  set-current-plot "Population of household group 3"
  set-current-plot-pen "No. of households"
  plot group-size-household
  set-current-plot-pen "No. of persons"
  plot group-size-person

end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-FarmSize-HouseholdGroup1

ask turtles [ask patches with [P_owner = [H_id] of myself] [set P_g [H_g] of myself]]
  let n-hhs count turtles with [H_g = 1]
  let farmsize-upcrop (count patches with [p_cover-type = 1 and P_g = 1]) * 0.09 / n-hhs
  let farmsize-paddy (count patches with [p_cover-type = 2 and P_g = 1]) * 0.09 / n-hhs
  let farmsize-af (count patches with [p_cover-type = 3 and P_g = 1]) * 0.09 / n-hhs
  let farmsize-whole (farmsize-upcrop + farmsize-paddy + farmsize-af)

  set-current-plot "Farm size of household group 1"
  set-current-plot-pen "Whole farm"
  plot farmsize-whole
  set-current-plot-pen "Upland crop"
  plot farmsize-upcrop
  set-current-plot-pen "Paddy rice"
  plot farmsize-paddy
  set-current-plot-pen "Agroforestry"
  plot farmsize-af
end
;------------------------------End------------------------------------------------
;------------------------------To-------------------------------------------------
to Draw-FarmSize-HouseholdGroup2

ask turtles [ask patches with [P_owner = [H_id] of myself] [set P_g [H_g] of myself]]
  let n-hhs count turtles with [H_g = 2]
  let farmsize-upcrop (count patches with [p_cover-type = 1 and P_g = 2]) * 0.09 / n-hhs
  let farmsize-paddy (count patches with [p_cover-type = 2 and P_g = 2]) * 0.09 / n-hhs
  let farmsize-af (count patches with [p_cover-type = 3 and P_g = 2]) * 0.09 / n-hhs
  let farmsize-whole (farmsize-upcrop + farmsize-paddy + farmsize-af)

  set-current-plot "Farm size of household group 2"
  set-current-plot-pen "Whole farm"
  plot farmsize-whole
  set-current-plot-pen "Upland crop"
  plot farmsize-upcrop
  set-current-plot-pen "Paddy rice"
  plot farmsize-paddy
  set-current-plot-pen "Agroforestry"
  plot farmsize-af
end
;------------------------------End------------------------------------------------
;------------------------------To-------------------------------------------------
to Draw-FarmSize-HouseholdGroup3

ask turtles [ask patches with [P_owner = [H_id] of myself] [set P_g [H_g] of myself]]
  let n-hhs count turtles with [H_g = 3]
  let farmsize-upcrop (count patches with [p_cover-type = 1 and P_g = 3]) * 0.09 / n-hhs
  let farmsize-paddy (count patches with [p_cover-type = 2 and P_g = 3]) * 0.09 / n-hhs
  let farmsize-af (count patches with [p_cover-type = 3 and P_g = 3]) * 0.09 / n-hhs
  let farmsize-whole (farmsize-upcrop + farmsize-paddy + farmsize-af)

  set-current-plot "Farm size of household group 3"
  set-current-plot-pen "Whole farm"
  plot farmsize-whole
  set-current-plot-pen "Upland crop"
  plot farmsize-upcrop
  set-current-plot-pen "Paddy rice"
  plot farmsize-paddy
  set-current-plot-pen "Agroforestry"
  plot farmsize-af
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-Yield-of-Agricultural-Type-HouseholdGroup1
let average-upcrop-yield 0
let average-paddy-yield 0
let average-af-yield 0
ask turtles [ask patches with [P_owner = [H_id] of myself] [set P_g [H_g] of myself]]

  set average-upcrop-yield mean [P_yield-upcrop] of patches with [p_cover-type = 1 and P_g = 1] / 1000 ;(orgiginal unit: kg rice/ha/yr, plotted unit: ton rice/ha/yr)
  set average-paddy-yield mean [P_yield-paddy] of patches with [p_cover-type = 2 and P_g = 1] / 1000
  set average-af-yield mean [P_yield-af] of patches with [p_cover-type = 3 and P_g = 1] / 1000

  set-current-plot "Average crop yield - Household group 1"
  set-current-plot-pen "Upland crop"
  plot average-upcrop-yield

  set-current-plot-pen "Paddy rice"
  plot average-paddy-yield

  set-current-plot-pen "Agroforestry"
  plot average-af-yield
end
;------------------------------End------------------------------------------------
;------------------------------To-------------------------------------------------
to Draw-Yield-of-Agricultural-Type-HouseholdGroup2
let average-upcrop-yield 0
let average-paddy-yield 0
let average-af-yield 0
ask turtles [ask patches with [P_owner = [H_id] of myself] [set P_g [H_g] of myself]]

  set average-upcrop-yield mean [P_yield-upcrop] of patches with [p_cover-type = 1 and P_g = 2] / 1000 ;(orgiginal unit: kg rice/ha/yr, plotted unit: ton rice/ha/yr)
  set average-paddy-yield mean [P_yield-paddy] of patches with [p_cover-type = 2 and P_g = 2] / 1000
  set average-af-yield mean [P_yield-af] of patches with [p_cover-type = 3 and P_g = 2] / 1000

  set-current-plot "Average crop yield - Household group 2"
  set-current-plot-pen "Upland crop"
  plot average-upcrop-yield

  set-current-plot-pen "Paddy rice"
  plot average-paddy-yield

  set-current-plot-pen "Agroforestry"
  plot average-af-yield
end
;------------------------------End------------------------------------------------
;------------------------------To-------------------------------------------------
to Draw-Yield-of-Agricultural-Type-HouseholdGroup3
let average-upcrop-yield 0
let average-paddy-yield 0
let average-af-yield 0
ask turtles [ask patches with [P_owner = [H_id] of myself] [set P_g [H_g] of myself]]

  set average-upcrop-yield mean [P_yield-upcrop] of patches with [p_cover-type = 1 and P_g = 3] / 1000 ;(orgiginal unit: kg rice/ha/yr, plotted unit: ton rice/ha/yr)
  set average-paddy-yield mean [P_yield-paddy] of patches with [p_cover-type = 2 and P_g = 3] / 1000
  set average-af-yield mean [P_yield-af] of patches with [p_cover-type = 3 and P_g = 3] / 1000

  set-current-plot "Average crop yield - Household group 3"
  set-current-plot-pen "Upland crop"
  plot average-upcrop-yield

  set-current-plot-pen "Paddy rice"
  plot average-paddy-yield

  set-current-plot-pen "Agroforestry"
  plot average-af-yield
end
;------------------------------End------------------------------------------------

;------------------------------To-------------------------------------------------
to Draw-GrossIncome-HouseholdGroup1
  let total-gross-income mean [H_income-pers] of turtles with [H_g = 1]
  let gross-income-crop mean [ H_income-pers * H_%in-crop * 0.01] of turtles with [H_g = 1]
  let gross-income-livestock mean [H_income-pers * H_%in-livestock * 0.01] of turtles with [H_g = 1]
  let gross-income-logging mean [H_income-pers * H_%in-logging * 0.01] of turtles with [H_g = 1]
  let gross-income-NTFPs mean [H_income-pers * H_%in-NTFPs * 0.01] of turtles with [H_g = 1]
  let gross-income-others (total-gross-income - gross-income-crop - gross-income-livestock - gross-income-logging - gross-income-NTFPs)

  set-current-plot "Household gross income and structure - Group 1"

  set-current-plot-pen "Gross income"
  plot total-gross-income

  set-current-plot-pen "from Crop"
  plot gross-income-crop

  set-current-plot-pen "from Livestock"
  plot gross-income-livestock

  set-current-plot-pen "from Logging"
  plot gross-income-logging

  set-current-plot-pen "from NTFPs"
  plot gross-income-NTFPs

  set-current-plot-pen "from Others"
  plot gross-income-others

end
;------------------------------End------------------------------------------------
;------------------------------To-------------------------------------------------
to Draw-GrossIncome-HouseholdGroup2
  let total-gross-income mean [H_income-pers] of turtles with [H_g = 2]
  let gross-income-crop mean [ H_income-pers * H_%in-crop * 0.01] of turtles with [H_g = 2]
  let gross-income-livestock mean [H_income-pers * H_%in-livestock * 0.01] of turtles with [H_g = 2]
  let gross-income-logging mean [H_income-pers * H_%in-logging * 0.01] of turtles with [H_g = 2]
  let gross-income-NTFPs mean [H_income-pers * H_%in-NTFPs * 0.01] of turtles with [H_g = 2]
  let gross-income-others (total-gross-income - gross-income-crop - gross-income-livestock - gross-income-logging - gross-income-NTFPs)

  set-current-plot "Household gross income and structure - Group 2"

  set-current-plot-pen "Gross income"
  plot total-gross-income

  set-current-plot-pen "from Crop"
  plot gross-income-crop

  set-current-plot-pen "from Livestock"
  plot gross-income-livestock

  set-current-plot-pen "from Logging"
  plot gross-income-logging

  set-current-plot-pen "from NTFPs"
  plot gross-income-NTFPs

  set-current-plot-pen "from Others"
  plot gross-income-others

end
;------------------------------End------------------------------------------------
;------------------------------To-------------------------------------------------
to Draw-GrossIncome-HouseholdGroup3
  let total-gross-income mean [H_income-pers] of turtles with [H_g = 3]
  let gross-income-crop mean [ H_income-pers * H_%in-crop * 0.01] of turtles with [H_g = 3]
  let gross-income-livestock mean [H_income-pers * H_%in-livestock * 0.01] of turtles with [H_g = 3]
  let gross-income-logging mean [H_income-pers * H_%in-logging * 0.01] of turtles with [H_g = 3]
  let gross-income-NTFPs mean [H_income-pers * H_%in-NTFPs * 0.01] of turtles with [H_g = 3]
  let gross-income-others (total-gross-income - gross-income-crop - gross-income-livestock - gross-income-logging - gross-income-NTFPs)

  set-current-plot "Household gross income and structure - Group 3"

  set-current-plot-pen "Gross income"
  plot total-gross-income

  set-current-plot-pen "from Crop"
  plot gross-income-crop

  set-current-plot-pen "from Livestock"
  plot gross-income-livestock

  set-current-plot-pen "from Logging"
  plot gross-income-logging

  set-current-plot-pen "from NTFPs"
  plot gross-income-NTFPs

  set-current-plot-pen "from Others"
  plot gross-income-others

end
;------------------------------End------------------------------------------------
@#$#@#$#@
GRAPHICS-WINDOW
207
31
1071
614
-1
-1
1.78
1
20
1
1
1
0
1
1
1
-240
240
-161
161
0
0
1
ticks
30.0

BUTTON
1073
73
1229
106
Show elevation
show-elevation
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
1073
106
1229
139
Show slope angle
show-slope
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
1073
139
1229
172
Show upslope area
show-upslope-area
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
1073
172
1229
205
Show wetness index
Show-wetness
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
1073
235
1229
268
Show distance to rivers
show-distance-to-river
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
1073
268
1229
301
Show distance to roads
show-distance-to-road
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1096
215
1219
233
Physical accessibility :
11
0.0
0

BUTTON
1073
333
1229
368
Show land use/cover
show-landcover
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
1073
398
1229
433
Show stand basal area
show-stand-basal-area
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1094
379
1208
397
Forest condition :
11
0.0
0

TEXTBOX
1096
314
1212
332
Land use/cover :
11
0.0
0

BUTTON
1073
498
1229
533
Show village territory
show-village-territory
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1095
478
1220
497
Institutional accessibility :
11
0.0
0

SLIDER
0
89
207
122
Number-of-initial-households
Number-of-initial-households
69
500
240.0
1
1
(hh)
HORIZONTAL

SLIDER
0
155
207
188
Average-annual-rainfall
Average-annual-rainfall
100
5000
2600.0
100
1
(mm/yr)
HORIZONTAL

SLIDER
0
236
207
269
theta-protect
theta-protect
4.5
18
9.5
0.1
1
(FIPI score)
HORIZONTAL

SLIDER
0
291
207
324
theta-enforce
theta-enforce
0
100
54.0
1
1
%
HORIZONTAL

SLIDER
0
379
207
412
theta-extension
theta-extension
0
100
55.0
1
1
(%)
HORIZONTAL

TEXTBOX
21
359
201
377
% of the total households reached :
11
0.0
0

TEXTBOX
20
273
170
291
Enforcement degree (%) :
11
0.0
0

TEXTBOX
20
217
204
235
Threshold score for protection zone :
11
0.0
0

SLIDER
0
466
207
499
theta-subsidy
theta-subsidy
0
100
23.0
1
1
(%)
HORIZONTAL

TEXTBOX
20
448
196
466
% of the total households reached :
11
0.0
0

SLIDER
0
522
207
555
W-subsidy
W-subsidy
0
500
260.0
10
1
(1000 VND/hh/yr)
HORIZONTAL

TEXTBOX
18
503
134
521
Subsidy amount :
11
0.0
0

TEXTBOX
4
431
201
449
2.4. AGROCHEMICAL SUBSIDY POLICY:
11
0.0
0

TEXTBOX
4
343
200
361
2.3. AGRICULTURE EXTENSION POLICY:
11
0.0
0

TEXTBOX
4
199
176
217
2.2. PROTECTION ZONING POLICY:
11
0.0
0

TEXTBOX
5
70
183
88
2.1. BASIC GLOBAL PARAMETERS:
11
0.0
0

SLIDER
0
604
208
637
theta-edu
theta-edu
0
100
10.0
1
1
(%)
HORIZONTAL

TEXTBOX
18
585
184
603
Rate of illiteracy eradication (%) :
11
0.0
0

SLIDER
0
122
207
155
Vision
Vision
0
1000
480.0
30
1
(m)
HORIZONTAL

PLOT
914
33
1074
243
Legend
NIL
NIL
0.0
0.0
0.0
0.0
false
true
"" ""
PENS
"Dense/rich natural forest" 1.0 0 -16751104 true "" ""
"Open/poor natural forest" 1.0 0 -16711885 true "" ""
"Shrub land" 1.0 0 -11221820 true "" ""
"Grass land" 1.0 0 -26113 true "" ""
"Young plantation" 1.0 0 -3342439 true "" ""
"Forest plantation" 1.0 0 -10040320 true "" ""
"Upland crop" 1.0 0 -205 true "" ""
"Paddy rice" 1.0 0 -16763905 true "" ""
"Agro-forestry" 1.0 0 -39424 true "" ""
"River / stream" 1.0 0 -16777063 true "" ""
"Road" 1.0 0 -6750208 true "" ""
"Rocky surface" 1.0 0 -10066330 true "" ""

BUTTON
0
31
105
64
1. INITIALIZATION
INITIALIZATION
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
1073
532
1229
567
Show FIPI Zoning score
Calculate-Score-For-Protection-Zoning
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
1073
567
1229
602
Show Protection Zone
Define-Protection-Zone
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
1073
602
1229
637
Show Land Holdings
Show-Holdings
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
0
637
441
924
Coverage of the main land-use/cover types
Elapsed time (year)
Coverage (%)
0.0
30.0
0.0
50.0
true
true
"" ""
PENS
"Dense/rich natural forest" 1.0 0 -16751104 true "" ""
"Open/poor natural forest" 1.0 0 -13840069 true "" ""
"Shrub land" 1.0 0 -16711732 true "" ""
"Grass land" 1.0 0 -39220 true "" ""
"Acacia plantation" 1.0 0 -10040320 true "" ""
"Cultivated land" 1.0 0 -2674135 true "" ""

PLOT
767
637
1136
924
Area of cultivated cover types
Elapsed time (year)
Area (ha)
0.0
30.0
0.0
300.0
true
true
"" ""
PENS
"Upland crop" 1.0 0 -1184463 true "" ""
"Paddy rice" 1.0 0 -13345367 true "" ""
"Agroforestry" 1.0 0 -955883 true "" ""

BUTTON
105
31
209
64
4. SIMULATION
SIMULATION
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1077
32
1222
51
LANDSCAPE VARIABLES :
11
0.0
0

TEXTBOX
1095
53
1197
71
Terrain variables :
11
0.0
0

PLOT
1229
31
1482
335
Lorenz curve
%population
%wealth
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Equal curve" 100.0 0 -16777216 true "" ""
"Lorenz curve" 1.0 0 -2674135 true "" ""

PLOT
1229
334
1482
637
Gini index vs. time
Elapsed time (year)
Gini index
0.0
30.0
0.0
1.0
true
false
"" ""
PENS
"Gini" 1.0 0 -13345367 true "" ""

MONITOR
208
544
300
589
Elapsed years
elapsed-years
0
1
11

CHOOSER
208
592
300
637
Stop-when
Stop-when
5 10 15 20 25 30 35 40 45 50 "any time"
5

BUTTON
994
602
1073
637
Map for print
Map-for-print
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
0
924
441
1206
Dense natural forest coverage at different scales
Elapsed time (year)
Coverage (%)
0.0
30.0
0.0
50.0
true
true
"" ""
PENS
"Zone with D-road < 1km" 1.0 0 -52429 true "" ""
"Zone with D-road < 2km" 1.0 0 -26266 true "" ""
"Zone with D-road < 3km" 1.0 0 -3368704 true "" ""
"Zone with D-road < 4km" 1.0 0 -13369600 true "" ""
"Whole watershed" 1.0 0 -16737997 true "" ""

PLOT
767
924
1136
1206
Average yield of agricultural type
Elapse time (year)
Yield (1000 kg rice/ha/year)
0.0
30.0
0.0
15.0
true
true
"" ""
PENS
"Upland crop" 1.0 0 -1184463 true "" ""
"Paddy rice" 1.0 0 -16777012 true "" ""
"Agroforestry" 1.0 0 -39424 true "" ""

PLOT
1136
637
1482
924
Household gross income and structure
Elapsed time (year)
1000 VND/person/yr
0.0
30.0
0.0
5000.0
true
true
"" ""
PENS
"from Crop" 1.0 0 -1184463 true "" ""
"from Livestock" 1.0 0 -6459832 true "" ""
"from Logging" 1.0 0 -16738048 true "" ""
"from NTFPs" 1.0 0 -5825686 true "" ""
"from Others" 1.0 0 -955883 true "" ""
"Gross income" 1.0 0 -16777216 true "" ""

PLOT
441
637
767
924
Yield of a 15ha-forest stand (not far)
Elapsed time (year)
Stand basal area (m2/ha)
0.0
30.0
0.0
40.0
true
false
"" ""
PENS
"Stand basal area" 1.0 0 -16738048 true "" ""

PLOT
1136
924
1482
1206
Total population
Elapsed time (year)
No. of households
0.0
30.0
200.0
2500.0
true
true
"" ""
PENS
"Households" 1.0 0 -16777216 true "" ""
"Persons" 1.0 0 -2674135 true "" ""

PLOT
441
924
767
1206
Yield of a 15ha-forest stand (remote)
Elapsed time (year)
Stand basal area (m2/ha)
0.0
30.0
0.0
40.0
true
false
"" ""
PENS
"Stand basal area" 1.0 0 -16737997 true "" ""

BUTTON
1073
433
1229
468
Show monitored stands
Show-Monitored-Stands
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
4
570
87
588
2.5. EDUCATION:
11
0.0
0

BUTTON
208
55
288
88
1. Quick import
Quick-Import
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
438
37
910
55
  VIETNAM LAND-USE/COVER DYNAMICS SIMULATOR (VN-LUDAS). 2005 by Q. B. Le, ZEF-Bonn
11
0.0
0

TEXTBOX
438
56
751
74
  applied for Hong Ha watershed, A-Luoi district, central Vietnam
11
0.0
0

PLOT
0
1204
441
1486
Population of household group 1
Elapsed time (year)
No. of households
0.0
30.0
0.0
1500.0
true
true
"" ""
PENS
"No. of households" 1.0 0 -16777216 true "" ""
"No. of persons" 1.0 0 -2674135 true "" ""

PLOT
440
1205
881
1486
Population of household group 2
Elapsed time (year)
No. of households
0.0
30.0
0.0
1500.0
true
true
"" ""
PENS
"No. of households" 1.0 0 -16777216 true "" ""
"No. of persons" 1.0 0 -2674135 true "" ""

PLOT
881
1205
1322
1486
Population of household group 3
Elapsed time (year)
No. of households
0.0
30.0
0.0
1500.0
true
true
"" ""
PENS
"No. of households" 1.0 0 -16777216 true "" ""
"No. of persons" 1.0 0 -2674135 true "" ""

PLOT
0
1485
441
1765
Farm size of household group 1
Elapsed time (year)
ha/household
0.0
30.0
0.0
1.5
true
true
"" ""
PENS
"Whole farm" 1.0 0 -16777216 true "" ""
"Upland crop" 1.0 0 -1184463 true "" ""
"Paddy rice" 1.0 0 -13345367 true "" ""
"Agroforestry" 1.0 0 -955883 true "" ""

PLOT
440
1485
881
1765
Farm size of household group 2
Elapsed time (year)
ha/household
0.0
30.0
0.0
1.5
true
true
"" ""
PENS
"Whole farm" 1.0 0 -16777216 true "" ""
"Upland crop" 1.0 0 -1184463 true "" ""
"Paddy rice" 1.0 0 -13345367 true "" ""
"Agroforestry" 1.0 0 -955883 true "" ""

PLOT
881
1485
1322
1765
Farm size of household group 3
Elapsed time (year)
ha/household
0.0
30.0
0.0
1.5
true
true
"" ""
PENS
"Whole farm" 1.0 0 -16777216 true "" ""
"Upland crop" 1.0 0 -1184463 true "" ""
"Paddy rice" 1.0 0 -13345367 true "" ""
"Agroforestry" 1.0 0 -955883 true "" ""

PLOT
0
1765
441
2045
Average crop yield - Household group 1
Elapsed time (year)
Ton rice/ha/year
0.0
30.0
0.0
15.0
true
true
"" ""
PENS
"Upland crop" 1.0 0 -1184463 true "" ""
"Paddy rice" 1.0 0 -13345367 true "" ""
"Agroforestry" 1.0 0 -955883 true "" ""

PLOT
441
1765
882
2045
Average crop yield - Household group 2
Elapsed time (year)
Ton rice/ha/year
0.0
30.0
0.0
15.0
true
true
"" ""
PENS
"Upland crop" 1.0 0 -1184463 true "" ""
"Paddy rice" 1.0 0 -13345367 true "" ""
"Agroforestry" 1.0 0 -955883 true "" ""

PLOT
882
1765
1322
2045
Average crop yield - Household group 3
Elapsed time (year)
Ton rice/ha/year
0.0
30.0
0.0
15.0
true
true
"" ""
PENS
"Upland crop" 1.0 0 -1184463 true "" ""
"Paddy rice" 1.0 0 -13345367 true "" ""
"Agroforestry" 1.0 0 -955883 true "" ""

PLOT
0
2044
441
2323
Household gross income and structure - Group 1
Elapsed time (year)
1000 VND/person/yr
0.0
30.0
0.0
5000.0
true
true
"" ""
PENS
"from Crop" 1.0 0 -1184463 true "" ""
"from Livestock" 1.0 0 -6459832 true "" ""
"from Logging" 1.0 0 -10899396 true "" ""
"from NTFPs" 1.0 0 -5825686 true "" ""
"from Others" 1.0 0 -955883 true "" ""
"Gross income" 1.0 0 -16777216 true "" ""

PLOT
441
2045
882
2323
Household gross income and structure - Group 2
Elapsed time (year)
1000 VND/person/yr
0.0
30.0
0.0
5000.0
true
true
"" ""
PENS
"from Crop" 1.0 0 -1184463 true "" ""
"from Livestock" 1.0 0 -6459832 true "" ""
"from Logging" 1.0 0 -10899396 true "" ""
"from NTFPs" 1.0 0 -5825686 true "" ""
"from Others" 1.0 0 -955883 true "" ""
"Gross income" 1.0 0 -16777216 true "" ""

PLOT
882
2045
1322
2323
Household gross income and structure - Group 3
Elapsed time (year)
1000 VND/person/yr
0.0
30.0
0.0
5000.0
true
true
"" ""
PENS
"from Crop" 1.0 0 -1184463 true "" ""
"from Livestock" 1.0 0 -6459832 true "" ""
"from Logging" 1.0 0 -10899396 true "" ""
"from NTFPs" 1.0 0 -5825686 true "" ""
"from Others" 1.0 0 -955883 true "" ""
"Gross income" 1.0 0 -16777216 true "" ""

@#$#@#$#@
For non-commercial uses, the LUDAS model and example input data, together with a short user�s guide are offered free of charge from its author (Quang Bao Le). If the model (either the whole model, or its sub-models, or its modified form) is used for a published work, citations of all below papers are required.
****************** End of LUDAS Model Copyright Notice *************************************

****************************Le (2005)*********************************************
Le, Q.B., 2005. Multi-Agent System for Simulation of Land-Use and Land-Cover Change: A Theoretical Framework and Its First Implementation for An Upland Watershed in the Central Coast of Vietnam. Cuvillier Verlag, G�ttingen, Germany. 289 p.

Abstract (short). Land-use/cover change is one of the most disturbing human-induced changes of the natural environment. This study presents a multi-agent model to simulate spatiotemporal land-use changes and community dynamics in forest margins, emerging from household interactions and land-use policies. The study integrates calibrated models of land-use decision making and relevant ecological processes into structures of household agents and land automata, providing a coupled human-landscape system. The operational model allows the systematic generation of integrated land-use change scenarios resulting from changes in policy and, once validated, will provide a scientific basis for optimizing the management of land and forest resources.

Keywords: coupled human-environment systems; complexity; agent-based models; multi-agent systems; simulation-based scenarios, land-use change; policy decision support; LUDAS; Vietnam

***************************Le et al. (2008)****************************************
Le, Q.B., Park, S.J., Vlek, P.L.G., Cremers, A.B. (2008). Land Use Dynamic Simulator (LUDAS): A multi-agent system model for simulating spatio-temporal dynamics of coupled human-landscape system. I. Structure and theoretical specification. Ecological Informatics 3, 135-153.

Abstract. This paper presents the concept and theoretical specification of a multi-agent based model for spatio-temporal simulation of a coupled human-landscape system. The model falls into the class of �all agents�, where the human population and the landscape environment are all self-organized interactive agents. The model framework is represented by four components: (i) a system of human population defining specific behavioural patterns of farm households in land-use decision-making according to typological livelihood groups, (ii) a system of landscape environment characterizing individual land patches with multiple attributes, representing the dynamics of crop and forest yields as well as land-use/cover transitions in response to household behaviour and natural constraints, (iii) a set of policy factors that are important for land-use choices, and (iv) a decision-making procedure integrating household, environmental and policy information into land-use decisions of household agents. In the model, the bounded-rational approach, based on utility maximization using spatial multi-nominal logistic functions, is nested with heuristic rule-based techniques to represent decision-making mechanisms of households regarding land use. Empirical verifications of the model�s components and the application of the model to a watershed in Vietnam for integrated assessments of policy impacts on landscape and community dynamics are subjects of a companion paper.

Keywords: complexity; coupled human-environment systems; multi-agent models; household decisions; land-use change dynamics; spatio-temporal visualization; policy decision support

*************************Le et al. (2010)******************************************
Le, Q.B., Park, S.J., Vlek, P.L.G., 2010. Land use dynamic simulator (LUDAS): A multi-agent system model for simulating spatio-temporal dynamics of coupled human-landscape system. 2. Scenario-based applications for impact assessment of land-use policies. Ecological Informatics 5, 203-221.

Abstract. Assessment of future socio-ecological consequences of land-use policies is useful for supporting decisions about what and where to invest for the best overall environmental and developmental outcomes. However, the task faces a great challenge due to the inherent complexity of coupled human-landscape systems and the long-term perspective required for sustainability assessment. Multi-agent system models have been recognised to be well suited to express the co-evolutions of the human and landscape systems in response to policy interventions. This paper applies the Land Use Dynamics Simulator (LUDAS) framework presented by Le et al. [Ecological Informatics 3 (2008) 135] to a mountain watershed in central Vietnam for supporting the design of land-use policies that enhance environmental and socio-economical benefits in long term. With an exploratory modelling strategy for complex integrated systems, our purpose is to assess relative impacts of policy interventions by measuring the long-term landscape and community divergences (compared with a baseline) driven from the widest plausible range of options for a given policy. Model�s tests include empirical verification and validation of sub-models, rational evaluation of coupled model�s structure, and behaviour tests using sensitivity/uncertainty analyses. We design experiments of replicated simulations for relevant policy factors in the study region that include (i) forest protection zoning, (ii) agricultural extension and (iii) agrochemical subsidies. As expected, the stronger human-environment interactions the performance indicators involve, the more uncertain the indicators are. Similar to the findings globally summarised by Liu et al. [Science 317 (2007) 1513], time lags between the implementation of land-use policies and the appearance of socio-ecological consequences are observed in our case.  Long-term legacies are found in the responses of the total cropping area, farm size and income distribution to changes in forest protection zoning, implying that impact assessment of nature conservation policies on rural livelihoods must be considered in multiple decades. Our comparative assessment of alternative future socio-ecological scenarios shows that it is challenging to attain better either household income or forest conservation by straightforward expanding the current agricultural extensions and subsidy schemes without improving the qualities of the services. The results also suggest that the policy intervention that strengthens the enforcement of forest protection in the critical areas of the watershed and simultaneously create incentives and opportunities for agricultural production in the less critical areas will likely promote forest restoration and community income in long run. We also discuss limitations of the simulation model and recommend future directions for model development.

Keywords: coupled human-environment systems; agent-based models; multi-agent systems; simulation-based scenarios, land-use change; policy decision support; LUDAS; Vietnam

*************************Le et al. (submitted)*********************************************
Le, Q.B., Seidl, R., Scholz, R.W. (submitted). Feedback loops and types of adaptation in the modelling of land-use decisions in an agent-based simulation: A case study in the central Vietnam mountains. Environmental Modelling & Software.

Abstract. A key challenge of land-use modelling for supporting sustainable land management is to understand how environmental feedback that emerges from land-use actions can reshape land-use decisions in the long term. To investigate this issue, we apply the Human-Environment System framework formulated by Scholz (2011) as a conceptual guide to read typical feedback loops in land-use systems. Next, we use an agent-based land-use change model (LUDAS) developed by Le et al. (2008; 2010) to test the sensitivity of long-term land-use dynamics to the inclusion of secondary feedback loop learning with respect to different system performance indicators at different levels of aggregation. Simulation experiments were based on a case study that was carried out in the Hong Ha watershed (Vietnam). In LUDAS, goal-directed land-use decisions by household agents are explicitly modelled (i.e. agents calculate utilities for all land-use and location alternatives and likely select the alternative with the highest utility). We specified two model versions that represent two mechanisms of human adaptation in land-use decisions to environmental changes that emerged from land-use actions. The first mechanism includes only primary feedback loop learning, i.e. households adapt to the annual change in socio-ecological conditions at household and farm levels by choosing the best land-use in the best location. The second mechanism includes the first one and secondary feedback loop learning, in which households can change their behavioural model in response to changes in socio-ecological conditions at the landscape�community level and in the longer term. Spatial-temporal patterns of land-use and interrelated community income changes driven from the two feedback mechanisms are compared in order to evaluate the added value of the inclusion of secondary feedback loop learning. The results demonstrate that the effect of the added secondary feedback loop learning on land-use dynamics depends on domain type, time scale, and aggregation level of the impact indicators. We also discuss limitations of the modelling approach and recommend directions for further work.

Keywords: human�environment interaction; agent-based modelling; land-use change; adaptive decision-making; feedback loop learning; Vietnam
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
Circle -7500403 true true 30 30 240

circle 2
false
0
Circle -7500403 true true 16 16 270
Circle -16777216 true false 46 46 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

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
Polygon -7500403 true true 60 270 150 0 240 270 15 105 285 105
Polygon -7500403 true true 75 120 105 210 195 210 225 120 150 75

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>count turtles</metric>
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
0
@#$#@#$#@
