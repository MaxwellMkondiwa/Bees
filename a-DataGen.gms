$include a0-Data


set

        QuarterPeriod( period, quarter)   map the half month periods with quarters
/
        Feb2   .   Q1
        Mar1   .   Q1
        Mar2   .   Q1
        Apr1   .   Q2
        Apr2   .   Q2
        May1   .   Q2
        May2   .   Q2
        Jun1   .   Q2
        Jun2   .   Q2
        Jul1   .   Q3
        Jul2   .   Q3
        Aug1   .   Q3
        Aug2   .   Q3
        Sep1   .   Q3
        Sep2   .   Q3
        Oct1   .   Q4
        Oct2   .   Q4
        Nov1   .   Q4
        Nov2   .   Q4
        Dec1   .   Q4
        Dec2   .   Q4
        Jan1   .   Q1
        Jan2   .   Q1
        Feb1   .   Q1
/

             ;

set Pcrop(allcrop) subset of pollination crops/
Almond
Wmelon
Appl
Avoc
BT
Cran
ChCAE
ChCAL
Cucu
Melo
Pear
Plum
Prun
Squa
chwa
/;

parameter Honey(Period,Location);

Honey(period, Hlocation)
         = sum( (MapCropLocationStates (AllCrop, Hlocation,  states) ,t),
                        HoneyIndex(Period,states) * honeys(states,t) )
           /sum(( MapCropLocationStates (AllCrop, Hlocation,  states),t) , 1$honeys(states,t)) ;

Honey(period, Plocation)
         = sum( (MapCropLocationStates (AllCrop, Plocation,  states) ,t),
                        HoneyIndex(Period,states) * honeys(states,t)
                                  $ MapCropPollSeason(ALLCrop, PLocation, Period)   )
                     /card(t);

Parameter LossRate(location2,Location) fraction of bees lost in transport    ;

LossRate(location,Location2) =Distance(location,Location2)*LossRatePerKmiles;

Parameter PollHives(Period,Location, t) Hives required at each crop for pollination (thousands)  ;
PollHives(Period,Location, t)=   sum(MapCropPollSeason(ALLCrop, Location, Period), PollReq(Allcrop, t)) ;


*^^^^^^^^^^^^^^^^^^^^^  All of the V stuff starts here ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Parameter V(Period,Location)        V matrix counting population changing rate
          V_state(quarter, states)  V data for each state;

V_state(quarter, states)=sum(t,
                          [(- LostColony(states, quarter, t)
                          +RenovatedColony(states, quarter,t)
                          +AddedColony(states, quarter, t)
                          )/ MaxColony(States, Quarter,t)+1])/2;


V(Period,Location) =  sum( (QuarterPeriod( period, quarter), MapCropLocationStates (AllCrop, location,  states)),
                            V_state(quarter, states)**( 1/6))
                         / sum((allcrop,states), 1$ MapCropLocationStates (AllCrop, location,  states));

V(Period,PLocation)$(not sum(allcrop, MapCropPollSeason(allCrop, PLocation, Period)))=0;


set locationstates(location, states);
option locationstates<  MapCropLocationStates;


*execute_unload 'rawdata.gdx' V honey
*execute 'gdxxrw.exe rawdata.gdx par=V rng=Vraw!A1 par=honey rng=HoneyRaw!A1'


set winter2(period)/  Oct2, Nov1, Nov2 ,  Dec1  ,   Dec2  ,   Jan1 ,  Jan2, Feb1 /;

V(Period,Location)$(V(Period,Location)>1 and winter2(period))= 0.97;
V(Period,Location)$(V(Period,Location) and V(Period,Location)<1 and not winter2(period))= 1.01;

parameter feedingcost(period,location);
feedingcost(period,location)$V(Period,Location) =
    sum(MapCropLocationStates(AllCrop, location,states),  FeedingCost1(Period, states))
    /  sum(MapCropLocationStates(AllCrop, location,states),  1$FeedingCost1(Period, states)) ;



display V, honey;
parameter nperiods(allcrop) count the periods of crops pollination;

