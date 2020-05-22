$title Simulate NLP model using the calibrated results

$ontext
Here are the instructions of setglobal options
1. Setglobal runmix/run2015/run2016.
        Runmix will read V and honey matrix from 2015 and 2016 calibration, then take the average
        run2015 will only read V and honey matrix from 2015 calibration
        run2016 will only read V and honey matrix from 2016 calibration

2. setglboal Vbound x
       x is the lower bound of V matrix elements

3. setglobal testmodel
      when this one is turned on, the code will generate modelstatus.xlsx file to record the calibration results

4. setglobal singleyear 2015/2016/201516
      when set as 2015, the small model of 2015 (honey price/quantity/ pollination requirement from 2015 data) will be run
      when set as 2016, the small model of 2016 (honey price/quantity/ pollination requirement from 2015 data) will be run
      when set as 201516, the full model will be run using two years data
$offtext

$setglobal runmix
$setglobal Vbound 90
*$setglobal testmodel
$setglobal singleyear  201516



$ifthen setglobal run2016
$setglobal yyear1 2016
$setglobal yyear2 2016
$endif

$ifthen setglobal run2015
$setglobal yyear1 2015
$setglobal yyear2 2015
$endif

$ifthen setglobal runmix
$setglobal yyear1 2016
$setglobal yyear2 2015
$endif



parameter vnew1(Period,Location)     Calibrated V matrix 1
          honeynew1(Period,Location) Calibrated Honey matrix 1
          vnew2(Period,Location)     Calibrated V matrix 2
          honeynew2(Period,Location) Calibrated Honey matrix 2
          PoliCost1                  Calibrated extra feeding cost during polination
          PoliCost2                  Calibrated extra feeding cost during polination
          caliobj                    record calibration objective function
          PoliCost                   Average of Calibrated extra feeding cost during polination
          vnew(period, location)     Average of Calibrated V matrix
          honeynew(period, location) Average of Calibrated Honey matrix;


* read calibrated result
$gdxin MPEC_%yyear1%_%Vbound%.gdx
$load Vnew1=VV.l  honeynew1=honeyV.l  PoliCost1=PoliCost.l   caliobj= obj.l
$gdxin

$gdxin MPEC_%yyear2%_%Vbound%.gdx
$load Vnew2=VV.l  honeynew2=honeyV.l  PoliCost2=PoliCost.l
$gdxin


Vnew(period, location)= (vnew1(Period,Location) +vnew2(Period,Location) )/2;
honeynew(Period,Location)  = (honeynew1(Period,Location) + honeynew2(Period,Location))/2;
V(period, location)= vnew(period, location);
honey(period, location)= honeynew(period, location);
policost= (policost1+policost2)  /2;




*####################################################
*  This section defines the model: Transportation   *
*####################################################
VARIABLES
         Obj       social welfare ($thousands)
         Art       artificial variable;

set sublocation(location) sublocation to test the model;
sublocation(location)=yes;
alias (sublocation, sublocation2)

POSITIVE VARIABLES
         BEE(Period,Location,t)               hives in each location during each time period after shipping (thousands of hives)
         BEEA(Period,location,t)              hives in each location at start of each time period prior to shipping  (thousands of hives)
         SPLIT(Period,Location,t)             Number of hives created through splits   (thousands of hives)
         HONEYSALES1(t)                       yearly honey sales   (thousand of lbs)
         HONEYSALES2(t)                       yearly honey sales   (thousand of lbs)
         TRANS(location,Location2,Period,t)   shipment quantities  (thousands of hives)

EQUATIONS
         ObjEq                               objective function
         SUPPLY(location,Period,t)           quantities shipped limited to supplies
         RENTED(Location,Period,t)           quantities rented limited to quantities shipped minus loss
         BEG(Period,Location,t)              quantity at beginning of time period is equal to q at end of last period
         POLQUANT(Period,Location,t)         setting quantities demanded at pollination location
         HONBAL(t)                           Honey quantity supplied greater than or equal to quantity demanded    (million of lbs of honey)
         MGMT2(Period,Location,t)            can only split to the extent that population is available
         HONBAL1(t)                          honeysales1 is non-zero only if the total production is less than some criteria
         HONBAL2(t)                          the product of honeysales1 and honeysales2 is zero


         ;

scalar k parameter to adjust consumer surplus/10/;

$ifthen %singleyear%== 2016
         set subt(t) /2016/;
         BEE.l(Period,Location,'2015')=0;
         BEEA.l(Period,location,'2015')=0;
         SPLIT.l(Period,Location,'2015')=0;
         HONEYSALES1.l('2015') =0;
         HONEYSALES2.l('2015')=1;
         HONEYSALES2.l('2016')=70;
         TRANS.l(location,Location2,Period,'2015') =0;

$endif

$ifthen %singleyear%== 2015
         set subt(t) /2015/;
         BEE.l(Period,Location,'2016')=0;
         BEEA.l(Period,location,'2016')=0;
         SPLIT.l(Period,Location,'2016')=0;
         HONEYSALES1.l('2016') =0;
         HONEYSALES2.l('2016')=1;
         HONEYSALES2.l('2015')=70;
         TRANS.l(location,Location2,Period,'2016') =0;

$endif

$ifthen %singleyear%== 201516
         set subt(t) /2015, 2016/;
         HONEYSALES2.l(t)=70;

$endif

$macro shippingC(subt) \
     SUM((sublocation,subLocation2,Period),shipcost*Distance(sublocation,subLocation2)*TRANS(sublocation,subLocation2,Period,subt) $[V(Period--1,subLocation) and V(Period,subLocation2) ])  \

$macro splitC(subt)       \
     SUM((Period,subLocation),SplitCost*SPLIT(Period,subLocation,subt)$(V(Period,subLocation)>1  )  ) \

$macro feedingC(subt)\
      SUM((Period, sublocation),FeedingCost(Period, sublocation)*BEE(Period,subLocation,subt)$V(Period,subLocation))  \

$macro ExtractC(subt) \
    (HONEYSALES1(subt)+HONEYSALES2(subt)) *1000*HoneyExtractCost \

$macro PoliC(subt)   \
         SUM((MapCropPollSeason(ALLCrop, subLocation, Period)),    PoliCost* BEE(Period,subLocation,subt)$V(Period,subLocation))      \



$macro cs(subt) \
        1000* [ ( epsilon/(1.+epsilon)* honeyquantity1(subt) *honeyprice1(subt) *(HONEYSALES2(subt)/honeyquantity1(subt) )** (1+(1./epsilon))    \
                -   epsilon/(1.+epsilon)*[max( 1/k, k**epsilon)]**(1+(1./epsilon)) * honeyquantity1(subt)  *honeyprice1(subt)     \
                 +  [max( 1/k, k**(epsilon))] *[min( k, (1/k)**(1/epsilon))]  * honeyquantity1(subt) *honeyprice1(subt)   )  \
              +  [min( k, (1/k)**(1/epsilon))] * honeyprice1(subt) *HONEYSALES1(subt) ]




ObjEq..
  Obj=E=
    - [
       + sum(subt, cs(subt))
       -sum(subt, ShippingC(subt)  )
       -sum(subt,splitC(subt))
       -sum(subt,feedingC(subt))
       -sum(subt,ExtractC(subt))
       -sum(subt, PoliC(subt)) ]
;


   SUPPLY(sublocation,Period,subt)$V(Period--1,subLocation) ..     SUM(subLocation2, TRANS(sublocation,subLocation2,Period,subt)
                                                                                          $[V(Period--1,subLocation) and V(Period,subLocation2) ]  )
                                                                               -BEEA(Period,sublocation,subt)=E=0 ;

   RENTED(subLocation2,Period,subt)$V(Period,subLocation2)..
               BEE(Period,subLocation2,subt)$V(Period,subLocation2)
                     - SUM(sublocation$V(Period--1,subLocation) ,
                                  (1-LossRate(sublocation,subLocation2))*TRANS(sublocation,subLocation2,Period,subt)$[V(Period--1,subLocation) and V(Period,subLocation2) ]) =E=0;

   BEG(Period,subLocation,subt)$V(Period--1,subLocation)..
              -{
                +(V(Period--1,subLocation)*BEE(Period--1,subLocation,subt))
                    $( V(Period--1,subLocation)<=1)
                +(BEE(Period--1,subLocation,subt)+SPLIT(Period--1,subLocation,subt))
                         $( V(Period--1,subLocation)>1)}

             + BEEA(Period,subLocation,subt) =E=0;


   POLQUANT(Period,subLocation,subt)
          $(PollHives(Period,subLocation,subt))..
            PollHives(Period,subLocation,subt)- BEE(Period,subLocation,subt)$V(Period,subLocation) =L=0;

   HONBAL(subt).. -SUM((Period,subLocation),Honey(Period,subLocation)*BEE(Period,subLocation,subt)$V(Period,subLocation))/1000 + (HONEYSALES1(subt)+HONEYSALES2(subt)) =E=0;

   HONBAL1(subt).. HONEYSALES1(subt) =L=  [min( k, (1/k)**(1/epsilon))] *honeyquantity1(subt);
   HONBAL2(subt)..  HONEYSALES1(subt)*HONEYSALES2(subt)=E=0;


   MGMT2(Period,subLocation,subt)
          $(V(Period,subLocation)>1
      )..
         -((V(Period,subLocation)-1)*BEE(Period,subLocation,subt)$V(Period,subLocation))+ SPLIT(Period,subLocation,subt)=L= 0 ;


option reslim=1000000;



MODEL TRANSPORT_ind /ALL/ ;

option limrow =0;
option limcol=0;
Option Solslack=0;
SOLVE TRANSPORT_ind USING NLP MINIMIZING Obj;


*#########################################################################
* Report calculation                                                     #
*#########################################################################
parameter
BEEL(Period,Location,t)
BEEAL(Period,location,t)
SPLITL(Period,Location,t)
HONEYSALESL(t)
TRANSL(location,Location2,Period,t)
Honeyprice(t)
PollPrice(allcrop,t)
;

BEEL(Period,subLocation,t)$( BEE.L(Period,subLocation,t)>0.1)              = BEE.L(Period,subLocation,t)                 ;
BEEAL(Period,sublocation,t)$(BEEA.L(Period,sublocation,t)>0.1)              = BEEA.L(Period,sublocation,t)                 ;
SPLITL(Period,subLocation,t) $ (SPLIT.L(Period,subLocation,t)>0.1)          = SPLIT.L(Period,subLocation,t)                 ;
HONEYSALESL(t)$(HONEYSALES1.L(t)+HONEYSALES2.L(t)>0.1)                          = HONEYSALES1.L(t)+HONEYSALES2.L(t)                           ;
TRANSL(sublocation,subLocation2,Period,t)$(TRANS.L(sublocation,subLocation2,Period,t)>0.1)= TRANS.L(sublocation,subLocation2,Period,t)        ;
Honeyprice(t)= [(HONEYSALES2.L(t)$(HONEYSALES2.l(t)>0)/honeyquantity1(t))**(1./epsilon) ]* honeyprice1(t) + ([min( k, (1/k)**(1/epsilon))]* honeyprice1(t) )$(HONEYSALES1.l(t)>0);
PollPrice(allcrop,t) = -sum(MapCropPollSeason(ALLCrop, subLocation, Period), 1*POLQUANT.m(Period,subLocation,t))  ;

display Beel, beeal, splitl, honeysalesl,  transl,PollPrice, honeyprice;

$ifthen.x setglobal testmodel

$ondotl
parameter fitness(*,*, *);
fitness(Pcrop, t, 'SquaredError')
     =  power( PollPrice(Pcrop, t)*PollReq(Pcrop, t)-calibrationPrices(PCrop, t)*PollReq(Pcrop, t), 2)/1000;
fitness('honey', t, 'SquaredError')
      = power(honeyquantity1(t)*honeyprice1(t)*1000- 1000*[[(HONEYSALES2(t)/honeyquantity1(t))**(1./epsilon)]* honeyprice1(t)*HONEYSALES2(t)+ ([min( k, (1/k)**(1/epsilon))]* honeyprice1(t))*HONEYSALES1(t) ], 2) /1000;
fitness('total', t, 'SquaredError')
      = sum(pcrop, fitness(Pcrop, t, 'SquaredError') ) + fitness('honey', t, 'SquaredError');
fitness('total', 'total', 'SquaredError')= sum(t, fitness('total', t, 'SquaredError') );

fitness(Pcrop, t, 'SimPrice')=   PollPrice(Pcrop, t);
fitness(Pcrop, t, 'ObsPrice')=   calibrationPrices(PCrop, t);
fitness(Pcrop, t, 'Acres')=   PollReq(Pcrop, t);

fitness('honey', t, 'SimPrice')=  Honeyprice(t);
fitness('honey', t, 'ObsPrice')=  honeyprice1(t);
fitness('honey', t, 'SimQuantity')=  HONEYSALESL(t);
fitness('honey', t, 'ObsQuantity')= honeyquantity1(t);



$ifthen not setglobal runmix
parameter VHdistance(*) calculate the squared Distance of V and honey matrix weighted by acrage
          Vraw(period, location)
          HoneyRaw(period, location)

;

$gdxin rawdata.gdx
$load Vraw=V  honeyraw=honey
$gdxin

alias (period, period2);

VHdistance('V')= sum((period, location), power(Vraw(period, location)- V(period, location), 2)*Beel(Period,Location,'%yyear1%'))
                    /sum((period2,sublocation),Beel(Period2,subLocation,'%yyear1%'))  ;
VHdistance('Honey')= sum((period, location), power(Honeyraw(period, location)- Honey(period, location), 2)*Beel(Period,Location,'%yyear1%'))
                     /sum((period2,sublocation),Beel(Period2,subLocation,'%yyear1%'));
VHdistance('Total')= VHdistance('V')+VHdistance('Honey');
VHdistance('CalibrationObj')= caliobj;

if ( (not TRANSPORT_ind.modelstat=2   ),
   VHdistance('Error')=1;
);

if(  abs(caliobj- fitness('total', '%yyear1%', 'SquaredError'))>1,
   VHdistance('Error')=2;
);

display VHdistance;


execute_unload 'modelstatus.gdx'  fitness VHdistance
execute 'gdxxrw modelstatus.gdx  par=fitness rng=Fitness_%yyear1%_%Vbound%!A1 cdim=2 par=VHdistance rng=VHdistance_%yyear1%_%Vbound%!A1'

$endif

display fitness;

$offdotl
$endif.x
