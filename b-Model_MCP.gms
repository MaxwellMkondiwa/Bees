$title MCPmodel
$ontext
This model is used to give initial values that MPEC model  needed
setglobal is used to switch the calibration years
use joint2016 to solve 2016 model
use joint2015 to solve 2015 model
$offtext

$setglobal joint2015

$ifthen setglobal joint2015
$setglobal t1 ,'2015'
$setglobal t2 ('2015')
$elseif setglobal joint2016
$setglobal t1 ,'2016'
$setglobal t2 ('2016')
$endif

set sublocation(location) subset of locations (used to create small model);
sublocation(location)=yes;

option Savepoint=1;
Option Solslack=0;
option reslim=1000000000;

alias (sublocation, sublocation2)
option limrow=0;
option limcol=0;

Scalar  PoliCost extra feeding cost during polination    /15.34/    ;

*as MPC model is a linear model, we used steps to piecewise the demand function
set allsteps /1*54/;
set steps(allsteps);
    steps(allsteps)=yes;

PARAMETER
          QINC(allSTEPS)           Seperable quantity increments
         /
             1   .10,     2  .15,     3  .20,     4  .25,      5  .30,      6  .35,      7  .40,      8  .45,
             9   .50,    10  .55,    11  .60,    12  .65,     13  .70,     14  .75,     15  .775,    16  .80,
            17   .82,    18  .84,    19  .86,    20  .88,     21  .90,     22  .91,     23  .92,     24  .93,
            25   .94,    26  .95,    27  .96,    28  .97,     29  .98,     30  .99,     31 1.00,     32 1.01,
            33  1.02,    34 1.03,    35 1.04,    36 1.05,     37 1.06,     38 1.07,     39 1.08,     40 1.09,
            41  1.10,    42 1.12,    43 1.14,    44 1.16,     45 1.18,     46 1.20,     47 1.25,     48 1.30,
            49  1.35,    50 1.40,    51 1.5,     52 2.00,     53 2.50,     54 4.00
         /
;

*#############################################################
*         MCP Model
*#############################################################
VARIABLES
         Obj       social welfare ($thousands)

;


POSITIVE variable
         TRANS(location,Location2,Period)     shipment quantities  (thousands of hives)
         BEE(Period,Location)                 hives in each location during each time period after shipping (thousands of hives)
         BEEA(Period,location)                hives in each location at start of each time period prior to shipping  (thousands of hives)
         HONEYSALES                           yearly honey sales   (thousand of lbs)
         HONEYGRID( allsteps)                 Honey grid
         SPLIT(Period,Location)               Number of hives created through splits   (thousands of hives)



negative variable
         SP_SUPPLY(location,Period)         shadow price of equation  quantities shipped limited to supplies
         SP_RENTED(Location,Period)         shadow price of equation   quantities rented limited to quantities shipped minus loss
         SP_BEG(Period,Location)            shadow price of equation   quantity at beginning of time period is equal to q at end of last period
         SP_HONBAL                          shadow price of equation   Honey quantity supplied greater than or equal to quantity demanded    (million of lbs of honey)
         SP_HONGRIDBAL


         SP_POLQUANT(Period,Location)       shadow price of equation   setting quantities demanded at pollination location
         SP_MGMT2(Period,Location)          shadow price of equation   can only split to the extent that population is available
         SP_HONGRIDBAL2


EQUATIONS
*         ObjEq                                     objective function
         SUPPLY(location,Period)           quantities shipped limited to supplies
         RENTED(Location,Period)           quantities rented limited to quantities shipped minus loss
         BEG(Period,Location)              quantity at beginning of time period is equal to q at end of last period
         POLQUANT(Period,Location)         setting quantities demanded at pollination location
         HONBAL                            Honey quantity supplied greater than or equal to quantity demanded    (million of lbs of honey)
         MGMT2(Period,Location)            can only split to the extent that population is available
         HONGRIDBAL                        the grid balance
         HONGRIDBAL2                       sum grid=1

         FOC_BEE(Period,Location)             FOC_    hives in each location during each time period after shipping (thousands of hives)
         FOC_BEEA(Period,location)            FOC_    hives in each location at start of each time period prior to shipping  (thousands of hives)
         FOC_SPLIT(Period,Location)           FOC_    Number of hives created through splits   (thousands of hives)
         FOC_HONEYSALES                       FOC_    yearly honey sales   (thousand of lbs)
         FOC_HONEYGRID( allsteps)             FOC_    Honey grid
         FOC_TRANS(location,Location2,Period) FOC_    shipment quantities  (thousands of hives)
  ;


scalar k we want the starting point of integration be no less than 1 over k times of optimal Q or P /10/   ;

$macro cs                                                 \
          [  sum(steps$(qinc(steps)>  [max( 1/k, k**epsilon)]) ,              \
                 (    epsilon/(1.+epsilon)*qinc(steps)**(1+(1./epsilon))      \
                         * honeyquantity1 *honeyprice1                          \
                    -   epsilon/(1.+epsilon)                                    \
                        *[max( 1/k, k**epsilon)]**(1+(1./epsilon))               \
                        * honeyquantity1  *honeyprice1                               \
                +  [max( 1/k, k**(epsilon))]                                       \
                    *[min( k, (1/k)**(1/epsilon))]  * honeyquantity1 *honeyprice1     \
                       )*HONEYGRID( steps)  )             \
             +sum(steps$(qinc(steps) le  [max( 1/k, k**epsilon)]) ,   \
                 (  qinc(steps)                                             \
                    *[min( k, (1/k)**(1/epsilon))] * honeyquantity1  *honeyprice1   \
                       )*HONEYGRID( steps) )  ]           \


*reduced cost  *add constraints


FOC_BEE(Period,subLocation)$V(Period,subLocation)..
  -  [ +SP_RENTED(subLocation,Period)$V(Period,subLocation)

     -SP_BEG(period++1,subLocation)*V(Period,subLocation)$( V(Period,subLocation)<=1)
     -SP_BEG(period++1,subLocation)                      $( V(Period,subLocation)>1)

     -SP_POLQUANT(Period,subLocation)$(PollHives(Period,subLocation%t1%))

     -SP_HONBAL*Honey(Period,subLocation)/1000
     -(V(Period,subLocation)-1)*SP_MGMT2(Period,subLocation)$(V(Period,subLocation)>1   )
$ifthen setglobal proportion
     + sum(MapLocationStates(sublocation,  states),SP_BEEUPPER(Period,states)$beedist(Period, states))
     - sum(states1, beedist(Period, states1)*1.2*SP_BEEUPPER(Period,states1))
     - sum(MapLocationStates(sublocation,  states),SP_BEELOWER(Period,states)$beedist(Period, states))
     + sum(states1, beedist(Period, states1)*0.8*SP_BEELOWER(Period,states1))
$endif
]
=n=
 [  - FeedingCost(Period, sublocation)
   -  sum(  MapCropPollSeason(ALLCrop, subLocation, Period) ,  PoliCost/nperiods(allcrop))] ;


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


FOC_HONEYSALES..
    -[    +SP_HONBAL
        -SP_HONGRIDBAL/honeyquantity1%t2%  ]
       =n=    -1000*HoneyExtractCost     ;

FOC_HONEYGRID( steps) ..


    -[    +SP_HONGRIDBAL*qinc(steps)
        +SP_HONGRIDBAL2  ]
     =n=

     [         (    epsilon/(1.+epsilon)*qinc(steps)**(1+(1./epsilon))
                         * honeyquantity1%t2% *honeyprice1%t2%
                    -   epsilon/(1.+epsilon)
                        *[max( 1/k, k**epsilon)]**(1+(1./epsilon))
                        * honeyquantity1%t2%  *honeyprice1%t2%
                +  [max( 1/k, k**(epsilon))]
                    *[min( k, (1/k)**(1/epsilon))]  * honeyquantity1%t2% *honeyprice1%t2%
                       )$(qinc(steps)>  [max( 1/k, k**epsilon)])
             +
                 (  qinc(steps)
                    *[min( k, (1/k)**(1/epsilon))] * honeyquantity1%t2%  *honeyprice1%t2%
                       )$(qinc(steps) le  [max( 1/k, k**epsilon)])   ]*1000
;

FOC_TRANS(sublocation,subLocation2,Period) $[V(Period--1,subLocation) and V(Period,subLocation2) ]..


  -[    SP_SUPPLY(sublocation,Period)$V(Period--1,subLocation)
     -  (1-LossRate(sublocation,subLocation2))* SP_RENTED(subLocation2,Period)$V(Period,subLocation2) ]
   =n= - shipcost*Distance(sublocation,subLocation2) ;

* constraints
   SUPPLY(sublocation,Period)$V(Period--1,subLocation) ..     SUM(subLocation2, TRANS(sublocation,subLocation2,Period)
                                                                                          $[V(Period--1,subLocation) and V(Period,subLocation2) ]  )
                                                                               -BEEA(Period,sublocation)=E=0.00001 ;

   RENTED(subLocation2,Period)$V(Period,subLocation2)..
               BEE(Period,subLocation2)$V(Period,subLocation2)
                     - SUM(sublocation$V(Period--1,subLocation) ,
                                  (1-LossRate(sublocation,subLocation2))*TRANS(sublocation,subLocation2,Period)$[V(Period--1,subLocation) and V(Period,subLocation2) ]) =E=0.00001;

   BEG(Period,subLocation)$V(Period--1,subLocation)..
              -{
                +(V(Period--1,subLocation)*BEE(Period--1,subLocation))
                    $( V(Period--1,subLocation)<=1)
                +(BEE(Period--1,subLocation)+SPLIT(Period--1,subLocation))
                         $( V(Period--1,subLocation)>1)}

             + BEEA(Period,subLocation) =E=0.00001;


   POLQUANT(Period,subLocation)
          $(PollHives(Period,subLocation%t1%))..
            PollHives(Period,subLocation%t1%)- BEE(Period,subLocation)$V(Period,subLocation) =L=0;

   HONBAL.. -SUM((Period,subLocation),Honey(Period,subLocation)*BEE(Period,subLocation)$V(Period,subLocation))/1000 + HONEYSALES =E=0;

   HONGRIDBAL.. -HONEYSALES/honeyquantity1%t2% + sum(steps, qinc(steps)* HONEYGRID( steps)) =E=0 ;

   HONGRIDBAL2.. sum(steps,  HONEYGRID( steps))=L=1;

   MGMT2(Period,subLocation)
          $(V(Period,subLocation)>1
      )..
         -((V(Period,subLocation)-1)*BEE(Period,subLocation)$V(Period,subLocation))+ SPLIT(Period,subLocation)=L= 0 ;



MODEL TRANSPORT_MCP_oneyear /FOC_Bee.Bee ,FOC_BEEA.BeeA, FOC_SPLIT.Split, FOC_HONEYSALES.HoneySales,
               FOC_HONEYGRID.Honeygrid, FOC_TRANS.Trans,
               Supply.SP_SUPPLY, Rented.SP_RENTED, Beg.SP_BEG, PolQuant.SP_POLQUANT,
               Honbal.SP_HONBAL, Mgmt2.SP_MGMT2, Hongridbal.SP_HONGRIDBAL, Hongridbal2.SP_HONGRIDBAL2

/ ;


SOLVE TRANSPORT_MCP_oneyear USING MCP;

parameter
BEEL(Period,Location)
BEEAL(Period,location)
SPLITL(Period,Location)
HONEYSALESL
HONEYGRIDL( allsteps)
TRANSL(location,Location2,Period)
INIHIVESL(location)
PollPrice(allcrop)
Honeyprice;

BEEL(Period,subLocation)$( BEE.L(Period,subLocation)>0.1)              = BEE.L(Period,subLocation)                 ;
BEEAL(Period,sublocation)$(BEEA.L(Period,sublocation)>0.1)              = BEEA.L(Period,sublocation)                 ;
SPLITL(Period,subLocation) $ (SPLIT.L(Period,subLocation)>0.1)          = SPLIT.L(Period,subLocation)                 ;
HONEYSALESL$(HONEYSALES.L>0.1)                                          = HONEYSALES.L                             ;
HONEYGRIDL( allsteps)                   = HONEYGRID.L( allsteps)                    ;
TRANSL(sublocation,subLocation2,Period)$(TRANS.L(sublocation,subLocation2,Period)>0.1)= TRANS.L(sublocation,subLocation2,Period)        ;


PollPrice(allcrop) = -sum(MapCropPollSeason(ALLCrop, subLocation, Period), 1*POLQUANT.m(Period,subLocation))  ;
Honeyprice= [sum(allsteps, HONEYGRIDL( allsteps)*QINC(allSTEPS))**(1./epsilon) ]* honeyprice1%t2%;
display Beel, beeal, splitl, honeysalesl, honeygridl, transl,PollPrice, honeyprice, honey, v;

