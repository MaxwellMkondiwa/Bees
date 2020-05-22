$title MPEC model
$ontext
This is the calibration model to calibrate the V and H matrix
*setglobal joint2015/joint2016 is used to select calibration years
*set global Vbound is used to change the lower bound of V matrix
$offtext
$setglobal joint2015
$setglobal Vbound 90

Set season/spring, summer, winter/
 periodseason(period, season)
 / (Feb2        ,         Mar1        ,         Mar2        ,         Apr1        ,         Apr2
May1        ,         May2        ,         Jun1         ).spring
(       Jun2 , Jul1        ,         Jul2        ,         Aug1        ,         Aug2        ,         Sep1
Sep2        ,         Oct1        ) .summer
( Oct2        ,         Nov1
Nov2        ,         Dec1        ,         Dec2        ,         Jan1        ,         Jan2
Feb1).winter

/


$ifthen setglobal joint2016
$setglobal year 2016
$endif

$ifthen setglobal joint2015
$setglobal year 2015
$endif

$ifthen setglobal joint2015
$setglobal t1 ,'2015'
$setglobal t2 ('2015')
$endif

$ifthen setglobal joint2016
$setglobal t1 ,'2016'
$setglobal t2 ('2016')
$endif


set sublocation(location) subset of location to switch between large and small model;
sublocation(location)=yes;

alias (sublocation, sublocation2)
alias (period, period2)
option limrow=0;
option limcol=0;

parameter Vsave(period, location)     store observed V matrix
          honeysave(period, location) store observed honey matrix;

 Vsave(period, sublocation)= v(period, sublocation);
 honeysave(period, location)= honey(period, location);

set mapregion(location,location)  map location with forage regions (left if typical location in the region)
/

hBT   .  ( hPear, hCran)
hAKW    .  ( hAvoc,    hChCA , hCucu , hMelo , hPlum ,  hPrun ,  hSqua)
hAppl   .  ( hchwa )
/ ;

scalar k parameter used to adjust consumer surplus/10/;

*##################################
*          MPEC Model             #
*##################################
VARIABLES
         Obj       social welfare ($thousands)
         Vtol(period, location)  the tolerence for V matrix
         Htol(period, location)  the tolerence for H matrix
;


positive variable
         TRANS(location,Location2,Period)        shipment quantities  (thousands of hives)
         BEE(Period,Location)                    hives in each location during each time period after shipping (thousands of hives)
         BEEA(Period,location)                   hives in each location at start of each time period prior to shipping  (thousands of hives)
         SPLIT(Period,Location)                  Number of hives created through splits   (thousands of hives)
         HONEYSALES1                             yearly honey sales   (thousand of lbs)
         HONEYSALES2                             yearly honey sales   (thousand of lbs)


         VV(Period,Location)                     New V matrix as variable to calibrate the model
         HoneyV(Period,Location)                 New Honey matrix as variable to calibrate the model
         PollPrice(Pcrop)                        Calibrated Pollination price
         PoliCost                                extra polination cost per period (universal cost for all crops)
         VAvg(season, location)
negative variable
         SP_SUPPLY(location,Period)         shadow price of equation   quantities shipped limited to supplies
         SP_RENTED(Location,Period)         shadow price of equation   quantities rented limited to quantities shipped minus loss
         SP_BEG(Period,Location)            shadow price of equation   quantity at beginning of time period is equal to q at end of last period
         SP_HONBAL                          shadow price of equation   Honey quantity supplied greater than or equal to quantity demanded    (million of lbs of honey)
         SP_HONBAL1                         shadow price of equation   honeysales1 is non-zero only if the total production is less than some criteria
         SP_HONBAL2                         shadow price of equation   the product of honeysales1 and honeysales2 is zero
         SP_POLQUANT(Period,Location)       shadow price of equation   setting quantities demanded at pollination location
         SP_MGMT2(Period,Location)          shadow price of equation   can only split to the extent that population is available
         SP_HONGRIDBAL2

;

EQUATIONS

         SUPPLY(location,Period)           quantities shipped limited to supplies
         RENTED(Location,Period)           quantities rented limited to quantities shipped minus loss
         BEG(Period,Location)              quantity at beginning of time period is equal to q at end of last period
         POLQUANT(Period,Location)         setting quantities demanded at pollination location
         HONBAL                            Honey quantity supplied greater than or equal to quantity demanded    (million of lbs of honey)
         MGMT2(Period,Location)            can only split to the extent that population is available
         HONBAL1                           honeysales1 is non-zero only if the total production is less than some criteria
         HONBAL2                           the product of honeysales1 and honeysales2 is zero

         FOC_BEE(Period,Location)                FOC_hives in each location during each time period after shipping (thousands of hives)
         FOC_BEEA(Period,location)               FOC_hives in each location at start of each time period prior to shipping  (thousands of hives)
         FOC_SPLIT(Period,Location)              FOC_Number of hives created through splits   (thousands of hives)
         FOC_TRANS(location,Location2,Period)    FOC_shipment quantities  (thousands of hives)
         FOC_HONEYSALES1                         FOC_yearly honey sales   (thousand of lbs)
         FOC_HONEYSALES2                         FOC_yearly honey sales   (thousand of lbs)


        objeq                                    objective function
        PoolPrice_constraint(Pcrop)              get pollination prices from shadow price of equation POLQUANT
        VregionBal(location, location, period)   the honey location within one forage region should have the same V value each period
        HoneyRegionBal(location, location, period) the honey location within one forage region should have the same Honey value each period

        VtolUpper(period, location)
        VtolLower(period, location)
        HtolUpper(period, location)
        HtolLower(period, location)
        VseasonAvg(season, location)



;


*read the initial value (solution of MCP model)
$if exist TRANSPORT_MCP_oneyear_p.gdx execute_loadpoint 'TRANSPORT_MCP_oneyear_p.gdx';

parameter loadhoneysales;
$gdxin   TRANSPORT_MCP_oneyear_p.gdx
$load loadhoneysales=honeysales.l
$gdxin

honeysales2.l= 80;

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*                 MPEC model Part                          *
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

alias (pcrop, pcrop2);
*^^ objective funciton: Minimizing the SSE of pollination revenue by crops plus SSE of honey revenue between observed and simulated
objeq..
obj=e= [power(honeyquantity1%t2%*honeyprice1%t2%*1000- 1000*[[(HONEYSALES2/honeyquantity1%t2%)**(1./epsilon)]* honeyprice1%t2%*HONEYSALES2+ ([min( k, (1/k)**(1/epsilon))]* honeyprice1%t2% )*HONEYSALES1 ], 2)
       +  sum(Pcrop, power( PollPrice(Pcrop)*PollReq(Pcrop%t1%)-calibrationPrices(PCrop%t1%)*PollReq(Pcrop%t1%), 2))]/1000
      + sum((period,sublocation)$V(period, sublocation), power(VV(period, sublocation)-  sum(periodseason(period,season),VAvg(season, sublocation)), 2))
*       + sum((period, Hlocation), power(VV(period, Hlocation)- VV(period--1, Hlocation), 2)     )
*       + sum((period, Hlocation), power(HOneyV(period, Hlocation)- HoneyV(period--1, Hlocation), 2)     )
;

*^^ Pollination prices equal to sum of shadow prices of polquant during pollination season
PoolPrice_constraint(Pcrop)$sum(MapCropPollSeason(PCrop, subLocation, Period),1)..
   PollPrice(Pcrop)=e= -sum(MapCropPollSeason(PCrop, subLocation, Period), SP_POLQUANT(Period,subLocation)) ;

*^^ the honey location within one forage region should have the same V value each period
VregionBal(sublocation, sublocation2, period)
       $mapregion(sublocation,sublocation2) ..
          VV(Period,subLocation)=E= VV(Period,subLocation2) + Vtol(period, sublocation2);

*^^ the honey location within one forage region should have the same Honey value each period
HoneyRegionBal(sublocation, sublocation2, period)
       $mapregion(sublocation,sublocation2) ..
       HoneyV(Period,subLocation)=E= HoneyV(Period,subLocation2)+ Htol(period, sublocation2);

VseasonAvg(season, sublocation)..
       VAvg(season, sublocation) =E= sum(periodseason(period,season), VV(period, sublocation)$V(period, sublocation))/sum(periodseason(period,season), 1$V(period, sublocation));

VtolUpper(period, sublocation2)
          $sum(sublocation, mapregion(sublocation, sublocation2))..
      Vtol(period, sublocation2) =L= VV(period, sublocation2)* 0.001;

VtolLower(period, sublocation2)
          $sum(sublocation, mapregion(sublocation, sublocation2))..
      Vtol(period, sublocation2) =G= -VV(period, sublocation2)* 0.001;


HtolUpper(period, sublocation2)
          $sum(sublocation, mapregion(sublocation, sublocation2))..
      Htol(period, sublocation2) =L= HoneyV(period, sublocation2)* 0.001;

HtolLower(period, sublocation2)
          $sum(sublocation, mapregion(sublocation, sublocation2))..
      Htol(period, sublocation2) =G= - HoneyV(period, sublocation2)* 0.001;

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*      upper and lower bound of key varialbes              *
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

VV.up(Period,subLocation)= min(1.1, Vsave(period, sublocation) +0.09);
VV.lo(Period,subLocation)= max(%Vbound%/100, Vsave(period, sublocation) -(1-%Vbound%/100));
VV.lo(Period,subLocation)$(Vsave(period, sublocation) ge 1 )= 1+eps;
VV.up(Period,subLocation)$(Vsave(period, sublocation) and Vsave(period, sublocation)<1 )= 1-eps;
HoneyV.up(Period,subLocation)= Honeysave(Period,subLocation)*1.2;
HoneyV.lo(Period,subLocation)= Honeysave(Period,subLocation)*0.8;

VV.fx(Period,subLocation)$(Vsave(period, sublocation)=0)=0;
HoneyV.fx(Period,subLocation)$(Honeysave(Period,subLocation)=0)=0;

VV.l(Period,subLocation)=Vsave(period, sublocation);
HoneyV.l(Period,subLocation)=Honeysave(Period,subLocation);



*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*                 MCP model Part                           *
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

FOC_BEE(Period,subLocation)$V(Period,subLocation)..
  -  [ +SP_RENTED(subLocation,Period)$V(Period,subLocation)

     -SP_BEG(period++1,subLocation)*VV(Period,subLocation)$( V(Period,subLocation)<=1)
     -SP_BEG(period++1,subLocation)                      $( V(Period,subLocation)>1)

     -SP_POLQUANT(Period,subLocation)$(PollHives(Period,subLocation%t1%))

     -SP_HONBAL*HoneyV(Period,subLocation)/1000
     -(VV(Period,subLocation)-1)*SP_MGMT2(Period,subLocation)$(V(Period,subLocation)>1   )

]
=n=
 [  -  FeedingCost(Period, sublocation)
   -  sum(  MapCropPollSeason(ALLCrop, subLocation, Period) ,  PoliCost)] ;


FOC_BEEA(Period,sublocation)$V(Period--1,subLocation) ..
 -[   -SP_SUPPLY(sublocation,Period)$V(Period--1,subLocation)
    +SP_BEG(Period,subLocation) $V(Period--1,subLocation)
  ]
    =n= 0 ;


FOC_SPLIT(Period,subLocation)$(V(Period,subLocation)>1   )..


   -[  -SP_BEG(period++1,subLocation)
     +SP_MGMT2(Period,subLocation)  ]
    =n=
    -SplitCost;



FOC_HONEYSALES1..
  -[ +SP_HONBAL
     + SP_HONBAL1
    + SP_HONBAL2*HONEYSALES2

]
 =n=
     [min( k, (1/k)**(1/epsilon))] * honeyprice1%t2%      ;

FOC_HONEYSALES2..
  -[ +SP_HONBAL
    + SP_HONBAL2*HONEYSALES1

   ]
 =n=
       1000*honeyprice1%t2%  *(HONEYSALES2/honeyquantity1%t2%  )** ((1./epsilon))

       - 1000*HoneyExtractCost

;

FOC_TRANS(sublocation,subLocation2,Period) $[V(Period--1,subLocation) and V(Period,subLocation2) ]..


  -[    SP_SUPPLY(sublocation,Period)$V(Period--1,subLocation)
     -  (1-LossRate(sublocation,subLocation2))* SP_RENTED(subLocation2,Period)$V(Period,subLocation2) ]
   =n= - shipcost*Distance(sublocation,subLocation2) ;

* constraints
   SUPPLY(sublocation,Period)$V(Period--1,subLocation) ..     SUM(subLocation2, TRANS(sublocation,subLocation2,Period)
                                                                                          $[V(Period--1,subLocation) and V(Period,subLocation2) ]  )
                                                                               -BEEA(Period,sublocation)=E=0 ;

   RENTED(subLocation2,Period)$V(Period,subLocation2)..
               BEE(Period,subLocation2)$V(Period,subLocation2)
                     - SUM(sublocation$V(Period--1,subLocation) ,
                                  (1-LossRate(sublocation,subLocation2))*TRANS(sublocation,subLocation2,Period)$[V(Period--1,subLocation) and V(Period,subLocation2) ]) =E=0;

   BEG(Period,subLocation)$V(Period--1,subLocation)..
              -{
                +(VV(Period--1,subLocation)*BEE(Period--1,subLocation))
                    $( V(Period--1,subLocation)<=1)
                +(BEE(Period--1,subLocation)+SPLIT(Period--1,subLocation))
                         $( V(Period--1,subLocation)>1)}

             + BEEA(Period,subLocation) =E=0;


   POLQUANT(Period,subLocation)
          $(PollHives(Period,subLocation%t1% ))..
            PollHives(Period,subLocation%t1%)- BEE(Period,subLocation)$V(Period,subLocation) =L=0;

   HONBAL.. -SUM((Period,subLocation),HoneyV(Period,subLocation)*BEE(Period,subLocation)$V(Period,subLocation))/1000 + (HONEYSALES1+HONEYSALES2) =E=0;

   HONBAL1.. HONEYSALES1 =L=  [min( k, (1/k)**(1/epsilon))] *honeyquantity1%t2% ;
   HONBAL2..  HONEYSALES1*HONEYSALES2=E=0;


   MGMT2(Period,subLocation)
          $(V(Period,subLocation)>1
      )..
         -((VV(Period,subLocation)-1)*BEE(Period,subLocation)$V(Period,subLocation))+ SPLIT(Period,subLocation)=L= 0 ;


option reslim=1000000000;


MODEL TRANSPORT_MPEC /FOC_Bee.Bee ,FOC_BEEA.BeeA, FOC_SPLIT.Split, FOC_HONEYSALES1.HoneySales1,
              FOC_TRANS.Trans,   FOC_HONEYSALES2.HoneySales2,
               Supply.SP_SUPPLY, Rented.SP_RENTED, Beg.SP_BEG, PolQuant.SP_POLQUANT,
               Honbal.SP_HONBAL, Mgmt2.SP_MGMT2, Honbal1.SP_HONbal1, Honbal2.SP_HONbal2

 objeq ,PoolPrice_constraint
        VregionBal
        HoneyRegionBal
VtolUpper
VtolLower
HtolUpper
HtolLower

/ ;


option Savepoint=0;
*TRANSPORT_MPEC.optfile=1;

SOLVE TRANSPORT_MPEC USING MPEC min obj;

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*                MPEC iteration                            *
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*iterate the model to make sure it converge

*$ontext
parameter error1 store the honey of V, error2  store sse of honey;
set iter/ iter1*iter50/;

error1 = sum((period, sublocation), power( V(Period,subLocation)- VV.l(Period,subLocation),2)) ;
error2 = sum((period, sublocation), power( honey(Period,subLocation)- HoneyV.l(Period,subLocation),2) );
display error1, error2;

parameter track(period, location, iter) track the difference;
loop(iter$((error1> 0.00001 or error2>0.01 ) and not ( TRANSPORT_MPEC.modelStat=4 or TRANSPORT_MPEC.modelStat=5)  ),
      V(period, sublocation)$ ( TRANSPORT_MPEC.modelStat=2 or TRANSPORT_MPEC.modelStat=7 )= VV.l(period, sublocation);
      honey(period, sublocation)$ ( TRANSPORT_MPEC.modelStat=2  or TRANSPORT_MPEC.modelStat=7 )= HoneyV.l(period, sublocation);

      SOLVE TRANSPORT_MPEC USING MPEC min obj;
      error1 = sum((period, sublocation), power( V(Period,subLocation)- VV.l(Period,subLocation),2))      ;
      error2 = sum((period, sublocation), power( honey(Period,subLocation)- HoneyV.l(Period,subLocation),2) );
     display error1 , error2;
);

*$offtext

*fast report
parameter
BEEL(Period,Location)
BEEAL(Period,location)
SPLITL(Period,Location)
HONEYSALESL
TRANSL(location,Location2,Period)
INIHIVESL(location)
Honeyprice
modelstat;

BEEL(Period,subLocation)$( BEE.L(Period,subLocation)>0.1)              = BEE.L(Period,subLocation)                 ;
BEEAL(Period,sublocation)$(BEEA.L(Period,sublocation)>0.1)              = BEEA.L(Period,sublocation)                 ;
SPLITL(Period,subLocation) $ (SPLIT.L(Period,subLocation)>0.1)          = SPLIT.L(Period,subLocation)                 ;
HONEYSALESL$(HONEYSALES1.L+HONEYSALES2.L>0.1)                          = HONEYSALES1.L+HONEYSALES2.L                           ;
TRANSL(sublocation,subLocation2,Period)$(TRANS.L(sublocation,subLocation2,Period)>0.1)= TRANS.L(sublocation,subLocation2,Period)        ;
Honeyprice= [(HONEYSALES2.L$(HONEYSALES2.l>0)/honeyquantity1%t2%)**(1./epsilon) ]* honeyprice1%t2% + ([min( k, (1/k)**(1/epsilon))]* honeyprice1%t2% )$(HONEYSALES1.l>0);

modelstat=   TRANSPORT_MPEC.modelstat   ;
display Beel, beeal, splitl, honeysalesl,  transl,PollPrice.l, honeyprice, VV.l, honeyV.l;


execute_unload 'MPEC_%year%_%Vbound%.gdx' VV.l honeyV.l PoliCost.l  obj.l modelstat


