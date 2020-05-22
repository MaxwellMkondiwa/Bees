* Joint data

set t the year of the data/ 2015, 2016/;
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* BASIC SETTINGS OF THE MODEL
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Sets
Location    pollination and honey production locations
/AKW   almonds watermelon                , hAKW   honey near akw
Appl  apple pollination                     , hAppl  honey near apple
Avoc  avocade pollination                   , hAvoc  honey near avocade
BT    blueberries pollination               , hBT    honey near blueberries
Cran  cranberries pollination               , hCran  honey near cranberries
ChCA  callifonia cheery pollination         , hChCA  honey near california cherry
Cucu  cucumber pollination                  , hCucu  honey production near cucumber
Melo  melons pollination                    , hMelo  honey near melons
Pear  Pears pollination                     , hPear  honey nearpears
Plum  plums pollination                     , hPlum  honey nearplums
Prun  prunes pollination                    , hPrun  honey nearprunes
Squa  squash pollination                    , hSqua  honey nearsquash
chwa  sweet cherry in WA pollination        , hchwa  honey nearWashington cherry
hAvg  aggreagted ND SD and MT honey places
/

AllCrop    Separate Crops
/Almond Almond, Appl apple, Avoc avocade, BT blueberry,
ChcaE california cheery (early), ChcaL california cherry (late), Chwa Cherry in Washington,
Cran cranberry, Cucu cucumber, Melo melons, Pear, Plum, Prun, Squa squash, Wmelon watermelon, honey/

Period time periods (half month)
/ Feb2        ,         Mar1        ,         Mar2        ,         Apr1        ,         Apr2
May1        ,         May2        ,         Jun1        ,         Jun2
Jul1        ,         Jul2        ,         Aug1        ,         Aug2        ,         Sep1
Sep2        ,         Oct1        ,         Oct2        ,         Nov1
Nov2        ,         Dec1        ,         Dec2        ,         Jan1        ,         Jan2
Feb1/

Quarter Quarters
/Q1*Q4/

states /CA, WA, OR, ND, SD, MT/

MapCropLocationStates (AllCrop, location,  states) map crops to location and states
/
Almond     .   AKW   .CA     ,            honey      .  hAKW    .CA
Wmelon     .   AKW   .CA     ,            honey      .  hAppl   .WA
Appl       .   Appl  .WA     ,            honey      .  hAvoc   .CA
Avoc       .   Avoc  .CA     ,            honey      .  hBT     .OR
BT         .   BT    .OR     ,            honey      .  hCran   .OR
Cran       .   Cran  .OR     ,            honey      .  hChCA   .CA
ChCAE      .   ChCA  .CA     ,            honey      .  hCucu   .CA
ChCAL      .   ChCA  .CA     ,            honey      .  hMelo   .CA
Cucu       .   Cucu  .CA     ,            honey      .  hPear   .OR
Melo       .   Melo  .CA     ,            honey      .  hPlum   .CA
Pear       .   Pear  .OR     ,            honey      .  hPrun   .CA
Plum       .   Plum  .CA     ,            honey      .  hSqua   .CA
Prun       .   Prun  .CA     ,            honey      .  hchwa   .WA
Squa       .   Squa  .CA
chwa       .   chwa  .WA
honey      .   hAvg  .ND
honey      .   hAvg  .SD
honey      .   hAvg  .MT       /


;

* seperate the honey locations and pollination locations
set HLocation(Location) subset of all locations honey production location
    PLocation(Location) subset of all locations pollination location    ;

HLocation(Location)
     $ sum((sameas(allcrop,'honey'), states),MapCropLocationStates (AllCrop,location,  states) )=yes;
PLocation(Location) =yes;
Plocation(Hlocation)=no;

alias(Location,location2);

set mapPHlocation(location, location2)    link pollination and honey location   /
    AKW    .     hAKW
    Appl   .     hAppl
    Avoc   .     hAvoc
    BT     .     hBT
    Cran   .     hCran
    ChCA   .     hChCA
    Cucu   .     hCucu
    Melo   .     hMelo
    Pear   .     hPear
    Plum   .     hPlum
    Prun   .     hPrun
    Squa   .     hSqua
    chwa   .     hchwa
/    ;
Set Table MapCropPollSeason(ALLCrop, Location, Period)  map crops with location and pollination season
                   Feb2        Mar1        Mar2        Apr1        Apr2

Appl  .Appl                                                         YES
Avoc  .Avoc                                 YES         YES
BT    .BT                                                           YES
Pear  .Pear                                                         YES
Plum  .Plum         YES         YES
Prun  .Prun                                             YES         YES
chwa  .chwa                                 YES         YES
Almond.AKW          YES         YES
ChcaE .ChCA         YES         YES
ChcaL .ChCA                                 YES         YES

          +        May1        May2        Jun1        Jun2        Jul1

Appl  .Appl         YES
BT    .BT           YES         YES         YES
Cran  .Cran                                 YES         YES
Cucu  .Cucu                                             YES         YES
Melo  .Melo                                 YES         YES         YES
Pear  .Pear         YES
Squa  .Squa                                             YES         YES
Wmelon.AKW                                                          YES

          +        Jul2        Aug1        Aug2        Sep1

Cucu  .Cucu         YES         YES
Melo  .Melo         YES
Squa  .Squa         YES         YES         YES         YES
Wmelon.AKW          YES

;
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*  Data part starts from Here
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Table
FeedingCost2(Period, states, t) Cost of feeding 1 hive for time period Period  (dollars per hive)
             CA.2015    OR.2015   WA.2015   MT.2015   ND.2015   SD.2015
      Feb2     4.285     4.397     4.474     4.538     4.531     4.579
      Mar1     4.345     4.397     4.474     4.538     4.531     4.579
      Mar2     3.918     4.319     4.313     4.161     4.531     4.579
      Apr1     4.039     4.319     4.313     4.161     4.531     4.579
      Apr2     3.701     3.941     3.899     3.829     3.972     4.387
      May1     3.701     3.941     4.032     3.829     3.972     4.387
      May2     3.566     3.528     3.626     3.452     3.893     3.823
      Jun1     3.933     3.702     3.742     3.563     3.893     4.016
      Jun2     3.463     3.452     3.469     3.563     3.609     3.452
      Jul1     3.598     3.714     3.496     3.784     3.864     3.452
      Jul2     3.473     3.704     3.452     3.784     3.452     3.452
      Aug1     3.744     3.884     3.786     3.784     3.452     3.452
      Aug2     3.744     3.884     3.786     3.784     3.452     3.452
      Sep1     4.014     4.136     4.029     3.784     3.933     3.452
      Sep2     4.245     4.136     4.029     3.784     3.933     3.452
      Oct1     4.302     4.343     4.474     4.538     3.962     4.016
      Oct2     4.302     4.343     4.474     4.538     3.962     4.016
      Nov1     4.773     4.437     4.474     4.538     4.531     4.579
      Nov2     4.773     4.437     4.474     4.538     4.531     4.579
      Dec1     4.773     4.437     4.474     4.538     4.531     4.579
      Dec2     4.773     4.437     4.474     4.538     4.531     4.579
      Jan1     4.773     4.437     4.474     4.538     4.531     4.579
      Jan2     4.473     4.428     4.474     4.538     4.531     4.579
      Feb1     4.473     4.428     4.474     4.538     4.531     4.579
+
              CA.2016    OR.2016   WA.2016   MT.2016   ND.2016   SD.2016
      Feb2      4.33     4.444     4.521     4.587     4.579     4.628
      Mar1     4.392     4.444     4.521     4.587     4.579     4.628
      Mar2      3.96     4.365     4.359     4.205     4.579     4.628
      Apr1     4.082     4.365     4.359     4.205     4.579     4.628
      Apr2     3.741     3.983      3.94      3.87     4.014     4.434
      May1     3.741     3.983     4.075      3.87     4.014     4.434
      May2     3.604     3.566     3.664     3.489     3.935     3.864
      Jun1     3.975     3.741     3.781     3.601     3.935     4.059
      Jun2       3.5     3.489     3.505     3.601     3.647     3.489
      Jul1     3.636     3.753     3.533     3.824     3.905     3.489
      Jul2      3.51     3.744     3.489     3.824     3.489     3.489
      Aug1     3.783     3.925     3.827     3.824     3.489     3.489
      Aug2     3.783     3.925     3.827     3.824     3.489     3.489
      Sep1     4.057      4.18     4.072     3.824     3.974     3.489
      Sep2     4.291      4.18     4.072     3.824     3.974     3.489
      Oct1     4.348     4.389     4.521     4.587     4.004     4.059
      Oct2     4.348     4.389     4.521     4.587     4.004     4.059
      Nov1     4.823     4.484     4.521     4.587     4.579     4.628
      Nov2     4.823     4.484     4.521     4.587     4.579     4.628
      Dec1     4.823     4.484     4.521     4.587     4.579     4.628
      Dec2     4.823     4.484     4.521     4.587     4.579     4.628
      Jan1     4.823     4.484     4.521     4.587     4.579     4.628
      Jan2     4.521     4.475     4.521     4.587     4.579     4.628
      Feb1     4.521     4.475     4.521     4.587     4.579     4.628

;



parameters
HoneyExtractCost1(t)        cost of extracting one pound of honey         /2015 0.346, 2016 0.365/
Epsilon                     elasticity of demand                          /-0.76/
SplitCost1(t)               cost of splitting 1 hive (dollars per hive)   /2015 69.26, 2016 70/
Shipcost1(t)                cost of shipping 1000 hives 1 mile (thousands of dollars per thousands of hives per thousands of miles) /2015 8.01475219660103, 2016 8.1/
honeyprice1(t)              dollar per pound                             /2015 1.86, 2016 1.85/
honeyquantity1(t)           million pounds (observed)                    /2015 81.68,  2016 86.64/
LossRatePerKmiles           Loss per 1000 miles                          /0.05/  ;

parameters
HoneyExtractCost        cost of extracting one pound of honey
SplitCost               cost of splitting 1 hive (dollars per hive)
Shipcost                cost of shipping 1000 hives 1 mile (thousands of dollars per thousands of hives per thousands of miles)
FeedingCost1(Period, states) average feeding cost
;

*Take average of two years' costs
Feedingcost1(period, states) = sum(t, feedingcost2(period, states, t))/2;

HoneyExtractCost   = sum(t, HoneyExtractCost1(t))/2 ;
SplitCost          = sum(t, SplitCost1(t))/2        ;
Shipcost           = sum(t, Shipcost1(t))/2         ;


Table PollReq(Allcrop, t) pollination hives required by crops
                2015            2016
    Almond      1760            1590
    Wmelon        20              21
      Appl        91             105
      Avoc        52              69
        BT        33              33
      Cran       8.5               9
     ChcaE 12.107325       11.525108
     ChcaL 38.892675       43.474892
      Cucu         8              11
      Melo        36              50
      Pear       7.5              30
      Plum 8.0838323       13.073684
      Prun 11.916168       32.926316
      Squa      14.5             6.5
      Chwa        62              61
;


table CalibrationPrices(AllCrop, t)    observed pollination prices
                 2015         2016
    Almond       165           167
      Appl      52.7          51.5
      Avoc      27.7          40.8
        BT      39.4          46.5
     ChcaE       164     169.41176
     ChcaL      37.6        41.875
      Chwa      46.5          49.3
      Cran      69.3          74.3
      Cucu      36.7          28.9
      Melo      46.2            35
      Pear      51.9          53.1
      Plum       185           180
      Prun        18          18.5
      Squa      36.1          27.3
    Wmelon      46.8          38.7
;




TABLE HoneyIndex(Period,states) honey produced per hive in each end location  (lb per hive)

                  CA        OR        WA        ND        SD        MT
      Feb2    0.0321    0.0033         0         0         0         0
      Mar1     0.028    0.0033         0         0         0         0
      Mar2     0.056    0.0164    0.0195         0         0    0.0398
      Apr1    0.0481    0.0164    0.0195         0         0    0.0398
      Apr2    0.0679    0.0662    0.0709     0.056    0.0134    0.0694
      May1    0.0679    0.0662    0.0547     0.056    0.0134    0.0694
      May2    0.0761    0.1258    0.1032     0.064    0.0667    0.1088
      Jun1    0.0519    0.1028    0.0904     0.064    0.0533     0.099
      Jun2    0.0839    0.1361    0.1227     0.096    0.1067     0.099
      Jul1    0.0761    0.0995    0.1194     0.072    0.1067    0.0791
      Jul2    0.0839    0.0995    0.1227     0.112    0.1067    0.0791
      Aug1    0.0679     0.076    0.0837     0.112    0.1067    0.0791
      Aug2    0.0679     0.076    0.0837     0.112    0.1067    0.0791
      Sep1    0.0519    0.0432    0.0547     0.064    0.1067    0.0791
      Sep2    0.0362    0.0432    0.0547     0.064    0.1067    0.0791
      Oct1    0.0321    0.0131         0     0.064    0.0533         0
      Oct2    0.0321    0.0131         0     0.064    0.0533         0
      Nov1         0         0         0         0         0         0
      Nov2         0         0         0         0         0         0
      Dec1         0         0         0         0         0         0
      Dec2         0         0         0         0         0         0
      Jan1         0         0         0         0         0         0
      Jan2    0.0201         0         0         0         0         0
      Feb1    0.0201         0         0         0         0         0


;
table honeys(states, t)   state level yearly honey production per hives (source USDA)
                 2015       2016
        CA        30         36
        MT        83         77
        ND        74         78
        OR        38         35
        SD        66         71
        WA        44         35


;



TABLE Distance(location,Location2)  shipping distance  (thousands of miles)
                 AKW      Appl      Avoc        BT      Cran      Chca      Cucu      Melo      Pear      Plum      Prun      Squa      Chwa     hAVG
       AKW         0    0.8017    0.2416     0.723    0.6014    0.0338     0.215    0.0649    0.7119    0.0249    0.1879    0.1735    0.8001    1.5957
      Appl    0.8136         0     1.051    0.2047    0.4407    0.7806    0.5989    0.8777    0.1156    0.8377    0.6241    0.7103    0.0494    1.1016
      Avoc      0.24    1.0378         0    0.9592    0.8376    0.2733    0.4512    0.1882    0.9481     0.219    0.4241    0.4254    1.0363    1.5292
        BT    0.7228    0.1928    0.9603         0    0.2398    0.6899    0.5081     0.787    0.0905     0.747    0.5333    0.6195    0.1912    1.2897
      Cran    0.6014    0.4289    0.8389    0.2401         0    0.5685    0.3868    0.6656    0.3266    0.6256     0.412    0.4982    0.4273    1.5258
      Chca    0.0338    0.7689    0.2746    0.6902    0.5686         0    0.1823    0.0979    0.6791    0.0579    0.1552    0.1407    0.7674    1.5629
      Cucu    0.2154    0.5869    0.4528    0.5082    0.3866    0.1824         0    0.2795    0.4971    0.2395    0.0273    0.1121    0.5854    1.4611
      Melo    0.0647    0.8659    0.1908    0.7872    0.6656     0.098    0.2792         0    0.7761    0.0436    0.2522    0.2377    0.8643    1.6171
      Pear    0.7121    0.1037    0.9495    0.0919    0.3278    0.6791    0.4974    0.7762         0    0.7362    0.5226    0.6088    0.1022    1.2006
      Plum    0.0249    0.8261    0.2206    0.7474    0.6258    0.0582    0.2395    0.0439    0.7363         0    0.2124    0.1979    0.8246    1.6122
      Prun    0.1884    0.6123    0.4258    0.5336     0.412    0.1554    0.0272    0.2525    0.5225    0.2125         0    0.0851    0.6108    1.4414
      Squa    0.1854    0.6984    0.4271    0.6197    0.4981    0.1524    0.1117    0.2495    0.6086    0.2095    0.0846         0    0.6968    1.4444
      Chwa    0.8002    0.0492    1.0376    0.1913    0.4273    0.7672    0.5855    0.8643    0.1022    0.8243    0.6107    0.6969         0    1.1338
      hAvg    1.5957    1.1016    1.5292    1.2897    1.5258    1.5629    1.4611    1.6171    1.2006    1.6122    1.4414    1.4444    1.1338         0

      hAKW         0    0.8017    0.2416     0.723    0.6014    0.0338     0.215    0.0649    0.7119    0.0249    0.1879    0.1735    0.8001    1.5957
     hAppl    0.8136         0     1.051    0.2047    0.4407    0.7806    0.5989    0.8777    0.1156    0.8377    0.6241    0.7103    0.0494    1.1016
     hAvoc      0.24    1.0378         0    0.9592    0.8376    0.2733    0.4512    0.1882    0.9481     0.219    0.4241    0.4254    1.0363    1.5292
       hBT    0.7228    0.1928    0.9603         0    0.2398    0.6899    0.5081     0.787    0.0905     0.747    0.5333    0.6195    0.1912    1.2897
     hCran    0.6014    0.4289    0.8389    0.2401         0    0.5685    0.3868    0.6656    0.3266    0.6256     0.412    0.4982    0.4273    1.5258
     hChca    0.0338    0.7689    0.2746    0.6902    0.5686         0    0.1823    0.0979    0.6791    0.0579    0.1552    0.1407    0.7674    1.5629
     hCucu    0.2154    0.5869    0.4528    0.5082    0.3866    0.1824         0    0.2795    0.4971    0.2395    0.0273    0.1121    0.5854    1.4611
     hMelo    0.0647    0.8659    0.1908    0.7872    0.6656     0.098    0.2792         0    0.7761    0.0436    0.2522    0.2377    0.8643    1.6171
     hPear    0.7121    0.1037    0.9495    0.0919    0.3278    0.6791    0.4974    0.7762         0    0.7362    0.5226    0.6088    0.1022    1.2006
     hPlum    0.0249    0.8261    0.2206    0.7474    0.6258    0.0582    0.2395    0.0439    0.7363         0    0.2124    0.1979    0.8246    1.6122
     hPrun    0.1884    0.6123    0.4258    0.5336     0.412    0.1554    0.0272    0.2525    0.5225    0.2125         0    0.0851    0.6108    1.4414
     hSqua    0.1854    0.6984    0.4271    0.6197    0.4981    0.1524    0.1117    0.2495    0.6086    0.2095    0.0846         0    0.6968    1.4444
     hChwa    0.8002    0.0492    1.0376    0.1913    0.4273    0.7672    0.5855    0.8643    0.1022    0.8243    0.6107    0.6969         0    1.1338


+
                hAKW     hAppl     hAvoc       hBT     hCran     hChca     hCucu     hMelo     hPear     hPlum     hPrun     hSqua     hChwa
       AKW         0    0.8017    0.2416     0.723    0.6014    0.0338     0.215    0.0649    0.7119    0.0249    0.1879    0.1735    0.8001
      Appl    0.8136         0     1.051    0.2047    0.4407    0.7806    0.5989    0.8777    0.1156    0.8377    0.6241    0.7103    0.0494
      Avoc      0.24    1.0378         0    0.9592    0.8376    0.2733    0.4512    0.1882    0.9481     0.219    0.4241    0.4254    1.0363
        BT    0.7228    0.1928    0.9603         0    0.2398    0.6899    0.5081     0.787    0.0905     0.747    0.5333    0.6195    0.1912
      Cran    0.6014    0.4289    0.8389    0.2401         0    0.5685    0.3868    0.6656    0.3266    0.6256     0.412    0.4982    0.4273
      Chca    0.0338    0.7689    0.2746    0.6902    0.5686         0    0.1823    0.0979    0.6791    0.0579    0.1552    0.1407    0.7674
      Cucu    0.2154    0.5869    0.4528    0.5082    0.3866    0.1824         0    0.2795    0.4971    0.2395    0.0273    0.1121    0.5854
      Melo    0.0647    0.8659    0.1908    0.7872    0.6656     0.098    0.2792         0    0.7761    0.0436    0.2522    0.2377    0.8643
      Pear    0.7121    0.1037    0.9495    0.0919    0.3278    0.6791    0.4974    0.7762         0    0.7362    0.5226    0.6088    0.1022
      Plum    0.0249    0.8261    0.2206    0.7474    0.6258    0.0582    0.2395    0.0439    0.7363         0    0.2124    0.1979    0.8246
      Prun    0.1884    0.6123    0.4258    0.5336     0.412    0.1554    0.0272    0.2525    0.5225    0.2125         0    0.0851    0.6108
      Squa    0.1854    0.6984    0.4271    0.6197    0.4981    0.1524    0.1117    0.2495    0.6086    0.2095    0.0846         0    0.6968
      Chwa    0.8002    0.0492    1.0376    0.1913    0.4273    0.7672    0.5855    0.8643    0.1022    0.8243    0.6107    0.6969         0
      hAvg    1.5957    1.1016    1.5292    1.2897    1.5258    1.5629    1.4611    1.6171    1.2006    1.6122    1.4414    1.4444    1.1338

      hAKW         0    0.8017    0.2416     0.723    0.6014    0.0338     0.215    0.0649    0.7119    0.0249    0.1879    0.1735    0.8001
     hAppl    0.8136         0     1.051    0.2047    0.4407    0.7806    0.5989    0.8777    0.1156    0.8377    0.6241    0.7103    0.0494
     hAvoc      0.24    1.0378         0    0.9592    0.8376    0.2733    0.4512    0.1882    0.9481     0.219    0.4241    0.4254    1.0363
       hBT    0.7228    0.1928    0.9603         0    0.2398    0.6899    0.5081     0.787    0.0905     0.747    0.5333    0.6195    0.1912
     hCran    0.6014    0.4289    0.8389    0.2401         0    0.5685    0.3868    0.6656    0.3266    0.6256     0.412    0.4982    0.4273
     hChca    0.0338    0.7689    0.2746    0.6902    0.5686         0    0.1823    0.0979    0.6791    0.0579    0.1552    0.1407    0.7674
     hCucu    0.2154    0.5869    0.4528    0.5082    0.3866    0.1824         0    0.2795    0.4971    0.2395    0.0273    0.1121    0.5854
     hMelo    0.0647    0.8659    0.1908    0.7872    0.6656     0.098    0.2792         0    0.7761    0.0436    0.2522    0.2377    0.8643
     hPear    0.7121    0.1037    0.9495    0.0919    0.3278    0.6791    0.4974    0.7762         0    0.7362    0.5226    0.6088    0.1022
     hPlum    0.0249    0.8261    0.2206    0.7474    0.6258    0.0582    0.2395    0.0439    0.7363         0    0.2124    0.1979    0.8246
     hPrun    0.1884    0.6123    0.4258    0.5336     0.412    0.1554    0.0272    0.2525    0.5225    0.2125         0    0.0851    0.6108
     hSqua    0.1854    0.6984    0.4271    0.6197    0.4981    0.1524    0.1117    0.2495    0.6086    0.2095    0.0846         0    0.6968
     hChwa    0.8002    0.0492    1.0376    0.1913    0.4273    0.7672    0.5855    0.8643    0.1022    0.8243    0.6107    0.6969         0



;



* data source for the following
* Honey Bee Colonies: Released May 12, 2016, by the National Agricultural Statistics Service (NASS), Agricultural Statistics Board, United States Department of Agriculture (USDA).

Table MaxColony(States, Quarter, t) Max colonies number in the state and quarter
             Q1.2015   Q2.2015    Q3.2015   Q4.2015     Q1.2016   Q2.2016    Q3.2016   Q4.2016
        CA   1690000   1050000    800000   1260000      1410000   1150000    820000   1330000
        MT     36000    210000    156000    123000        65000    157000    158000    124000
        ND    120000    450000    500000    275000       137000    530000    550000    390000
        OR     87000     95000    100000    114000        92000    132000    112000    124000
        SD     97000    290000    295000    205000        79000    182000    191000    146000
        WA    105000    127000     97000     89000       146000    143000     74000     97000

;

Table StartColony(States, Quarter, t)  start colonies at the first day of each quarter
             Q1.2015   Q2.2015    Q3.2015   Q4.2015     Q1.2016   Q2.2016    Q3.2016   Q4.2016
        CA   1440000   1040000    730000    750000      1130000   1110000    740000    770000
        MT      8500     36000    140000    116000        16500     62000    147000    124000
        ND     57000    121000    460000    230000        89000    110000    510000    385000
        OR     77000     82000     68000    100000        68000     77000    107000     98000
        SD     50000    100000    295000    194000        47000     51000    178000    146000
        WA     52000    105000     84000     87000        77000     91000     57000     65000
;

Table  LostColony(states, quarter, t)  lost colony in the state by quarter

              Q1.2015   Q2.2015    Q3.2015   Q4.2015     Q1.2016   Q2.2016    Q3.2016   Q4.2016
        CA    255000    104000     76000    149000        200000    108000     82000    205000
        MT      2200      4200     10500     10000           900      7000     11500     16000
        ND       620     29000     93000     35000          8500     27000     71000     44000
        OR      6500      5500      8500      8500          2900      4300      7500      9500
        SD      4600     21000     53000      9000         10500     11000     25000     11000
        WA     14000      5000     11500      6500         13500      6000      5000      9000
;

Table  AddedColony(states, quarter,t)  Added colony in the state by quarter

              Q1.2015   Q2.2015    Q3.2015   Q4.2015     Q1.2016   Q2.2016    Q3.2016   Q4.2016
        CA    250000    170000     40000     39000       210000    240000     33000     40000
        MT      1400     14000      3200      1000        24000     25000      4100      2700
        ND      1800     39000     11000      2700         4600     23000     25000     13500
        OR      4300     14500      8000       200         3800     19000      2900      1500
        SD      8500     27000      2100      2400         1600     15000      4200         0
        WA     13500     15000      1800       330         5500     21000      7500      3100
;

Table  RenovatedColony(states, quarter,t)  Added colony in the state by quarter

              Q1.2015   Q2.2015    Q3.2015   Q4.2015     Q1.2016   Q2.2016    Q3.2016   Q4.2016
        CA    124000    285000     93000     75000       139000    185000     78000     35000
        MT      1100     33000     10000        80            0     13500      6500         0
        ND       530     61000     22000      9000            0     95000    104000      2500
        OR      2400      9500     21000      1400         1300     16000      4300      1000
        SD      2800     23000     13000         0            0     13000      9500      2400
        WA      9000     13000     20000       170         1200     11500      2000       130


;
