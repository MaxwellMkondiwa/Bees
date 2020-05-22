$title Simulate NLP model using the calibrated results and do forage adjustment

$ontext
Here are the instructions of setglobal options
1. Setglobal runmix/run2015/run2016.
        Runmix will read V and honey matrix from 2015 and 2016 calibration, then take the average
        run2015 will only read V and honey matrix from 2015 calibration
        run2016 will only read V and honey matrix from 2016 calibration

2. setglboal Vbound x
       x is the lower bound of V matrix elements

3. setglobal singleyear 2015/2016/201516
      when set as 2015, the small model of 2015 (honey price/quantity/ pollination requirement from 2015 data) will be run
      when set as 2016, the small model of 2016 (honey price/quantity/ pollination requirement from 2015 data) will be run
      when set as 201516, the full model will be run using two years data
$offtext

$setglobal singleyear  2016
$setglobal runmix
$setglobal Vbound 90

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
$load Vnew1=VV.l  honeynew1=honeyV.l  PoliCost1=PoliCost.l
$gdxin

$gdxin MPEC_%yyear2%_%Vbound%.gdx
$load Vnew2=VV.l  honeynew2=honeyV.l  PoliCost2=PoliCost.l
$gdxin


Vnew(period, location)= (vnew1(Period,Location) +vnew2(Period,Location) )/2;
honeynew(Period,Location)  = (honeynew1(Period,Location) + honeynew2(Period,Location))/2;
V(period, location)= vnew(period, location);
honey(period, location)= honeynew(period, location);
policost= (policost1+policost2)  /2;


parameter beebase1(period, location, t) record bee.l from the baseline (no forage nor almond acreage nor mortality changes);
$gdxin TRANSPORT_ind_p.gdx
$load beebase1=bee.l
$gdxin


$if exist TRANSPORT_ind_p.gdx execute_loadpoint 'TRANSPORT_ind_p.gdx'

option  Savepoint=0;
Option Solslack=0;

set Flocation forage locations  /
AKW
Appl
Avoc
BT
Cran
ChCA
Cucu
Melo
Pear
Plum
Prun
Squa
chwa
hAvg
R2
R3
R4

/;



set mapforage(Flocation,location)
/
hAvg  .  hAvg
R2    .  ( hBT, hPear, hCran, BT , Pear, Cran)
R3    .  (hAKW, hAvoc,    hChCA , hCucu , hMelo , hPlum ,  hPrun ,  hSqua,
           AKW,  Avoc,     ChCA ,  Cucu ,  Melo ,  Plum ,   Prun ,   Squa)
R4    .  ( hAppl ,   Appl ,   hchwa, chwa)
/ ;

parameter
Beebase(period, Flocation, t) save the baseline bee hives in each Forage region
beesave(period, Flocation, t) save the solved bee hives in each Forage region ;
Beebase(period, Flocation, t) = sum(mapforage(Flocation,location), beebase1(period, location, t));


parameter beta beta index in forage ratio function  /0.00/;
V(period, location)$(sum((mapforage(Flocation,location), t), beebase(period,Flocation, t))=0)=0;

$macro fratiofunction(Beetemp,beeBase)    \
  ((sum(subt1$beebase,   (1 + beta - beta*(Beetemp/beeBase) ))  /sum(subt1, 1$beebase))$sum(subt1, 1$beebase)    \
   +0$(sum(subt1, beebase=0)) )\


*####################################################
*  This section defines the model: Transportation   *
*####################################################
VARIABLES
         Obj       social welfare ($thousands)
  ;

set sublocation(location) sublocation to test the model;
sublocation(location)=yes;
alias (sublocation, sublocation2)

POSITIVE VARIABLES
         BEE(Period,Location,t)                    hives in each location during each time period after shipping (thousands of hives)
         BEEA(Period,location,t)                   hives in each location at start of each time period prior to shipping  (thousands of hives)
         SPLIT(Period,Location,t)                  Number of hives created through splits   (thousands of hives)
         HONEYSALES1(t)                            yearly honey sales   (thousand of lbs)
         HONEYSALES2(t)                            yearly honey sales   (thousand of lbs)
         TRANS(location,Location2,Period,t)        shipment quantities  (thousands of hives)
         BEEF(period, Flocation, t)                Bee in each Forage region

;
EQUATIONS
         ObjEq                               objective function
         SUPPLY(location,Period,t)           quantities shipped limited to supplies
         RENTED(Location,Period,t)           quantities rented limited to quantities shipped minus loss
         BEG1(Period,Location,t)             quantity at beginning of time period is equal to q at end of last period
         BEG2(Period,Location,t)             quantity at beginning of time period is equal to q at end of last period

         POLQUANT(Period,Location,t)         setting quantities demanded at pollination location
         HONBAL(t)                           Honey quantity supplied greater than or equal to quantity demanded    (million of lbs of honey)
         MGMT(Period,Location,t)             can only split to the extent that population is available
         HONBAL1(t)                          honeysales1 is non-zero only if the total production is less than some criteria
         HONBAL2(t)                          the product of honeysales1 and honeysales2 is zero
         BEG_sp(Period,Location,t)           quantity at beginning of time period is equal to q at end of last period
         MGMT_sp(Period,Location,t)          can only split to the extent that population is available
         BEEFBAL(period, Flocation, t)       sum up the bees within one region to beef

         ;

scalar k/10/;

$ifthen %singleyear%== 2016
         set subt(t) /2016/;
         BEE.l(Period,Location,'2016')=beebase1(period, location,'2016');
         BEE.l(Period,Location,'2015')=0;
         BEEA.l(Period,location,'2015')=0;
         SPLIT.l(Period,Location,'2015')=0;
         HONEYSALES1.l('2015') =0;
         HONEYSALES2.l('2015')=1;
         TRANS.l(location,Location2,Period,'2015') =0;

$endif

$ifthen %singleyear%== 2015
         set subt(t) /2015/;
         BEE.l(Period,Location,'2015')=beebase1(period, location,'2015');
         BEE.l(Period,Location,'2016')=0;
         BEEA.l(Period,location,'2016')=0;
         SPLIT.l(Period,Location,'2016')=0;
         HONEYSALES1.l('2016') =0;
         HONEYSALES2.l('2016')=1;
         TRANS.l(location,Location2,Period,'2016') =0;

$endif

$ifthen %singleyear%== 201516
         set subt(t) /2015, 2016/;
         BEE.l(Period,Location,t)=beebase1(period, location,t);
$endif


BEEF.l(Period,FLocation,subt)=  sum(mapforage(Flocation,location), beebase1(period, location, subt));



alias(subt, subt1);

$macro shippingC(subt) \
     SUM((sublocation,subLocation2,Period),shipcost*Distance(sublocation,subLocation2)*TRANS(sublocation,subLocation2,Period,subt) $[V(Period--1,subLocation) and V(Period,subLocation2) ])  \

$macro splitC(subt)       \
     SUM((Period,subLocation),SplitCost*SPLIT(Period,subLocation,subt)$(V(period,sublocation) )  ) \

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
       -sum(subt, PoliC(subt))
      ]
  ;
   SUPPLY(sublocation,Period,subt)$V(Period--1,subLocation) ..     SUM(subLocation2, TRANS(sublocation,subLocation2,Period,subt)
                                                                                          $[V(Period--1,subLocation) and V(Period,subLocation2) ]  )
                                                                               -BEEA(Period,sublocation,subt)=E=0 ;

   RENTED(subLocation2,Period,subt)$V(Period,subLocation2)..
               BEE(Period,subLocation2,subt)$V(Period,subLocation2)
                     - SUM(sublocation$V(Period--1,subLocation) ,
                                  (1-LossRate(sublocation,subLocation2))*TRANS(sublocation,subLocation2,Period,subt)$[V(Period--1,subLocation) and V(Period,subLocation2) ]) =E=0;

   BEG1(Period,subLocation,subt)$(V(Period,subLocation)   )..
              -{
                +V(Period,subLocation)
                  *sum(mapforage(Flocation,sublocation), fratiofunction(BEEF(Period,FLocation,subt1),BEEBase(Period,FLocation,subt1)))
                  *BEE(Period,subLocation,subt)

                +SPLIT(Period,subLocation,subt)
                        }

             + BEEA(Period++1,subLocation,subt) =L=0;

   BEG2(Period,subLocation,subt)$(V(Period,subLocation)   )..
              -{
                +BEE(Period,subLocation,subt)

                +SPLIT(Period,subLocation,subt)
                        }

             + BEEA(Period++1,subLocation,subt) =L=0;


   BEG_sp(Period,subLocation,subt)$(V(Period,subLocation)   )..
              -{
                +min(1,  V(Period,subLocation)
                          *sum(mapforage(Flocation,sublocation), fratiofunction(BEEsave(Period,FLocation,subt1),BEEBase(Period,FLocation,subt1))) )
                          *BEE(Period,subLocation,subt)

                +SPLIT(Period,subLocation,subt)
                        }

             + BEEA(Period++1,subLocation,subt) =E=0;

   POLQUANT(Period,subLocation,subt)
          $(PollHives(Period,subLocation,subt))..
            PollHives(Period,subLocation,subt)- BEE(Period,subLocation,subt)$V(Period,subLocation) =L=0;

   HONBAL(subt).. -SUM((Period,subLocation),Honey(Period,subLocation)*BEE(Period,subLocation,subt)$V(Period,subLocation))/1000 + (HONEYSALES1(subt)+HONEYSALES2(subt)) =E=0;

   HONBAL1(subt).. HONEYSALES1(subt) =L=  [min( k, (1/k)**(1/epsilon))] *honeyquantity1(subt);
   HONBAL2(subt)..  HONEYSALES1(subt)*HONEYSALES2(subt)=E=0;

   MGMT(Period,subLocation,subt)$( V(period,sublocation)) ..

         -max(0, V(Period,subLocation)*sum(mapforage(Flocation,sublocation), fratiofunction(BEEF(Period,FLocation,subt1),BEEBase(Period,FLocation,subt1)))-1)
                  *BEE(Period,subLocation,subt)$V(Period,subLocation)
             +SPLIT(Period,subLocation,subt)=L= 0 ;

   MGMT_sp(Period,subLocation,subt)$( V(period,sublocation)) ..

         -max(0, V(Period,subLocation)*sum(mapforage(Flocation,sublocation), fratiofunction(BEEsave(Period,FLocation,subt1),BEEBase(Period,FLocation,subt1))) -1)
                 *BEE(Period,subLocation,subt)$V(Period,subLocation)
               + SPLIT(Period,subLocation,subt)=L= 0 ;

   BEEFBAL(period, Flocation, subt)$sum(mapforage(Flocation,sublocation),V(period,sublocation))..
          sum(mapforage(Flocation,sublocation), Bee(Period,subLocation,subt)$V(period,sublocation))=E=BeeF(period,Flocation, subt);


option reslim=1000000;


option Savepoint=0;



MODEL TRANSPORT /   ObjEq  ,   SUPPLY   , RENTED,  BEG1, BEG2, POLQUANT , HONBAL , MGMT ,HONBAL1, HONBAL2, BEEFBAL / ;


MODEL TRANSPORT_sp /   ObjEq  ,   SUPPLY   , RENTED,   BEG_sp  , POLQUANT , HONBAL , MGMT_sp ,HONBAL1, HONBAL2 / ;


option dnlp=ipopt;

SOLVE TRANSPORT USING dNLP MINIMIZING Obj;

parameter fratio1(period, Flocation,*) save forage adjustment ratio
          PollPrice(allcrop,t,*)       save pollination prices
          comparebee(period, location, t, *)  compare bees in different runs
          comparebeea(period, location, t, *) compare beeA in different runs
          comparesplit(period, location, t, *) compare split amount in different runs ;
beesave(period,Flocation,t)= beeF.l(period, Flocation, t);
fratio1(period, Flocation,'1')  =  fratiofunction(BEEF.l(Period,FLocation,subt1),BEEBase(Period,FLocation,subt1));
PollPrice(allcrop,subt,'1') = -sum(MapCropPollSeason(ALLCrop, subLocation, Period), 1*POLQUANT.m(Period,subLocation,subt))  ;
comparebee(period, location, t, '1')=bee.l(period, location, t);
comparebeea(period, location, t, '1')=beea.l(period, location, t);
comparesplit(period, location, t, '1')= split.l(period, location,t);
display fratio1, beeF.l, bee.l;
option dnlp=conopt;
SOLVE TRANSPORT_sp USING NLP MINIMIZING Obj;

fratio1(period, Flocation,'2')  =  fratiofunction(BEEsave(Period,FLocation,subt1),BEEBase(Period,FLocation,subt1));
PollPrice(allcrop,subt,'2') = -sum(MapCropPollSeason(ALLCrop, subLocation, Period), 1*POLQUANT.m(Period,subLocation,subt))  ;
comparebee(period, location, t, '2')=bee.l(period, location, t);
comparebeea(period, location, t, '2')=beea.l(period, location, t);
comparesplit(period, location, t, '2')= split.l(period, location,t);
fratio1(period, Flocation,'diff')= fratio1(period, Flocation,'2')-fratio1(period, Flocation,'1')    ;

option fratio1:7:2:1;
display fratio1, pollprice, comparebee, comparebeea, comparesplit;

