$title simulate the effect of Almond pollination requirement on Bee market

$include c-Sim_No_forage.gms

set iters/ iter1*iter161/;
set iter(iters) ;
iter(iters)=yes;


set comp components in the objective function /percent, cs,ps, wel, shippingC, splitC, feedingC, extractC,
                                         PoliC, total, shadowprice, honey_p, honey_q, honey_rev, poli_rev, under_dem/
    cost_comp(comp) cost component as the subset /shippingC, splitC, feedingC, extractC,PoliC/
    aa before after and diff /before, after, diff/
    bb pollination or honey porpose / all, almond, other/
;

parameter shocks(iters)                                  the shocks to V matrix to test if the model can be survived
          vsave(period, location)                        save the simulated v
          honeysave(period, location)                    save the simulated honey matrix
          PollHivessave(Period,Location,t)               save pollination requirement

          modelstat(iters)                               save the model status
          modelstat1(iters)                              save the model status to decompse the shadow prices
          report_poliprice(allcrop,t, iters)             save the polination price
          report_beel(period, location,t, iters)         save bee solution
          report_beeal(period, location,t, iters)        save beeA solution
          report_splitl(period, location,t, iters)       save split solution
          report_honey(t,iters,*)                        report honey sales    and price
          Decomp(comp,aa, bb,t)                                decomponent the objective function
          report_decomp(comp,bb,t, iters)                     save the decomponented obj
          report_welfare(comp,t, iters)                       save the welfare component ;


parameter report_Bee_hBee(Period,Location,t,iters,bb) report the bee level with honey location seperated;

PollHivessave(Period,Location,t)= PollHives(Period,Location ,t);
Vsave(period, location)= vnew(Period,Location) ;
honeysave(Period,Location)  = honeynew(Period,Location);
honey(Period,Location)=   honeysave(Period,Location);

shocks(iters)= ord(iters)*0.01-0.61 ;
display shocks;
option solprint=off;
option limrow=0;
option limcol=0;

scalar
c1 changes of the almond acres /0/
c2 changes of the almond acres /1/;


$macro honeyp(t) \
           [(HONEYSALES2.L(t)$(HONEYSALES2.l(t)>0)/honeyquantity1(t))**(1./epsilon) ]* honeyprice1(t) \
          + ([min( k, (1/k)**(1/epsilon))]* honeyprice1(t) )$(HONEYSALES1.l(t)>0)


loop(iter,
         Decomp(comp,aa,bb,t)=0;
         PollHives(Period,Location,t)= PollHivessave(Period,Location,t);
         PollHives(Period,Location,t)$sum(MapCropPollSeason('almond', Location, Period), PollReq('almond',t))
                 =   sum(MapCropPollSeason('almond', Location, Period), PollReq('almond',t)*(1+shocks(iter))) ;

         SOLVE TRANSPORT_ind USING NLP MINIMIZING Obj;
         modelstat(iter) =TRANSPORT_ind.modelStat;

if( TRANSPORT_ind.modelStat=2,
         report_poliprice(allcrop,t, iter)                                              = -sum(MapCropPollSeason(ALLCrop, subLocation, Period), 1*POLQUANT.m(Period,subLocation,t))  ;

$ondotl
         report_BEEL(Period,subLocation,t,iter)$( BEE.L(Period,subLocation,t)>0.1)      = BEE(Period,subLocation,t)                 ;
         report_BEEAL(Period,sublocation,t,iter)$(BEEA.L(Period,sublocation,t)>0.1)     = BEEA(Period,sublocation,t)                 ;
         report_SPLITL(Period,subLocation,t,iter) $ (SPLIT.L(Period,subLocation,t)>0.1) = SPLIT(Period,subLocation,t)                 ;

         report_Honey(t,iter, 'price')                                                  = honeyp(t);
         report_HONEY(t,iter, 'sales')$(HONEYSALES1(t)+ HONEYSALES2(t)>0.1)             = HONEYSALES1(t)+ HONEYSALES2(t)                   ;
         report_HONEY(t,iter, 'sales1')$(HONEYSALES1(t)+ HONEYSALES2(t)>0.1)            = HONEYSALES1(t)                  ;
         report_HONEY(t,iter, 'sales2')$(HONEYSALES1(t)+ HONEYSALES2(t)>0.1)            = HONEYSALES2(t)                   ;
         report_Honey(t,iter, 'produced')                                               = SUM((Period,subLocation),Honey(Period,subLocation)*BEE(Period,subLocation,t))/1000;

         report_Bee_hBee(Period,subLocation,t,iter,'all')        = report_beel(Period,subLocation,t,iter);
         report_welfare('under_dem',t, iter)                     = cs(t)  ;
         report_welfare('honey_p',t, iter)                       = honeyp(t);
         report_welfare('honey_q',t, iter)$(HONEYSALES1(t)+ HONEYSALES2(t)>0.1)
                                                                 = 1000*(HONEYSALES1(t)+ HONEYSALES2(t)) ;
         report_welfare('honey_rev',t, iter)                     = report_welfare('honey_p',t, iter)*report_welfare('honey_q',t, iter)    ;
         report_welfare('poli_rev',t, iter)                      = -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,t)*POLQUANT.m(Period,subLocation,t))  ;
         report_welfare('shippingC',t,iter)                      = shippingC(t);
         report_welfare('splitC',t,   iter)                      = splitC(t);
         report_welfare('feedingC',t, iter)                      = feedingC(t);
         report_welfare('ExtractC',t,iter)                       = ExtractC(t);
         report_welfare('PoliC',t,iter)                          = PoliC(t);
         report_welfare('cs',t, iter)                            = report_welfare('under_dem',t, iter) -   report_welfare('honey_rev',t, iter);
         report_welfare('ps',t, iter)                            = report_welfare('honey_rev',t, iter) + report_welfare('poli_rev',t, iter)
                                                                         -sum(cost_comp,  report_welfare(cost_comp,t, iter))    ;



         Decomp('honey_p','before','all',t)              = honeyp(t);
         Decomp('honey_q','before','all',t)$(HONEYSALES1(t)+ HONEYSALES2(t)>0.1)
                                                         = 1000*(HONEYSALES1(t)+ HONEYSALES2(t))                   ;

         Decomp('cs','before','all',t)             =cs(t) - Decomp('honey_p','before','all',t)*Decomp('honey_q','before','all',t) ;

         Decomp('shippingC','before','all',t)      = shippingC(t);
         Decomp('splitC','before','all',t)         = splitC(t);
         Decomp('feedingC','before','all',t)       = feedingC(t);
         Decomp('ExtractC','before','all',t)       = ExtractC(t);
         Decomp('PoliC','before','all',t)          = PoliC(t);

         Decomp('ps','before','all',t)             = Decomp('honey_p','before','all',t)*Decomp('honey_q','before','all',t)
* polination reveunue
                                                     -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,t)*POLQUANT.m(Period,subLocation,t))
*all cost
                                                     - sum(cost_comp,Decomp(cost_comp,'before','all',t) )         ;

         Decomp('wel', 'before', 'all',t)         = cs(t)-  sum(cost_comp,Decomp(cost_comp,'before','all',t) )               ;
         Decomp('honey_rev','before','all',t)     = Decomp('honey_p','before','all',t)*Decomp('honey_q','before','all',t);
         Decomp('under_dem', 'before', 'all',t)   = cs(t);
         Decomp('poli_rev', 'before', 'all',t)    = -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,t)*POLQUANT.m(Period,subLocation,t));
         Decomp('poli_rev', 'before', 'almond',t) = -sum(MapCropPollSeason('almond',subLocation, Period), PollHives(Period,subLocation,t)*POLQUANT.m(Period,subLocation,t));
         Decomp('poli_rev', 'before', 'other',t)  = -sum(MapCropPollSeason(Allcrop,subLocation, Period)$(not sameas(allcrop, 'almond')), PollHives(Period,subLocation,t)*POLQUANT.m(Period,subLocation,t));

$offdotl

* resolve the model

         PollHives(Period,Location,t)= PollHivessave(Period,Location,t);
         PollHives(Period,Location,t)$sum(MapCropPollSeason('almond', Location, Period), PollReq('almond',t))
                 = c2+  sum(MapCropPollSeason('almond', Location, Period), PollReq('almond',t)*(1+shocks(iter))) ;
         SOLVE TRANSPORT_ind USING NLP MINIMIZING Obj;
         modelstat1(iter) =TRANSPORT_ind.modelStat;
$ondotl

         Decomp('honey_p','after','all',t)        =   honeyp(t);
         Decomp('honey_q','after','all',t)$(HONEYSALES1(t)+ HONEYSALES2(t)>0.1)                    = 1000*(HONEYSALES1(t)+ HONEYSALES2(t)  )                 ;

         Decomp('cs','after','all',t)             =cs(t) - Decomp('honey_p','after','all',t)*Decomp('honey_q','after','all',t);


         Decomp('shippingC','after','all',t)      =shippingC(t);
         Decomp('splitC','after','all',t)         =splitC(t);
         Decomp('feedingC','after','all',t)       =feedingC(t);
         Decomp('ExtractC','after','all',t)       =ExtractC(t);
         Decomp('PoliC','after','all',t)          =PoliC(t);

         Decomp('ps','after','all',t)           =  Decomp('honey_p','after','all',t)*Decomp('honey_q','after','all',t)
* polination reveunue
                                                 -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,t)*POLQUANT.m(Period,subLocation,t))
*all cost
                                                 - sum(cost_comp,Decomp(cost_comp,'after','all',t) )               ;

         Decomp('wel', 'after', 'all',t)=      cs(t)-  sum(cost_comp,Decomp(cost_comp,'after','all',t) )               ;

         Decomp('wel', 'after', 'all',t)=      cs(t)-  sum(cost_comp,Decomp(cost_comp,'after','all',t) )               ;
         Decomp('honey_rev','after','all',t)=    Decomp('honey_p','after','all',t)*Decomp('honey_q','after','all',t);
         Decomp('under_dem', 'after', 'all',t)= cs(t);
         Decomp('poli_rev', 'after', 'all',t)=  -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,t)*POLQUANT.m(Period,subLocation,t));
         Decomp('poli_rev', 'after', 'almond',t)=  -sum(MapCropPollSeason('almond',subLocation, Period), PollHives(Period,subLocation,t)*POLQUANT.m(Period,subLocation,t));
         Decomp('poli_rev', 'after', 'other',t)=  -sum(MapCropPollSeason(Allcrop,subLocation, Period)$(not sameas(allcrop, 'almond')), PollHives(Period,subLocation,t)*POLQUANT.m(Period,subLocation,t));


$offdotl
* calculate the marginal effect and save it
         Decomp(comp,'diff',bb,t) = (Decomp(comp,'after',bb,t)- Decomp(comp,'before',bb,t))/(c2-c1);
         report_decomp(comp,bb,t, iter)=Decomp(comp,'diff',bb,t);
         report_decomp('percent','all',t, iter)=  shocks(iter);
         report_decomp('shadowprice','all',t, iter)= report_poliprice('almond',t, iter);

);
);





execute_unload "Almond_joint_%yyear1%_%yyear2%_%Vbound%.gdx" Vnew honeynew  modelstat modelstat1 report_poliprice report_decomp   shocks
                                         report_honey  report_beel report_beeal report_splitl  report_Bee_hBee   report_welfare


execute 'gdxxrw.exe Almond_joint_%yyear1%_%yyear2%_%Vbound%.gdx par=Vnew rng=V!A1 par=honeynew rng=HoneyRate!A1  par=shocks rng=shocks!A1   par=modelstat rng=modelstat!A1  par=modelstat rng=modelstat!A5'
execute 'gdxxrw.exe Almond_joint_%yyear1%_%yyear2%_%Vbound%.gdx par=report_poliprice rng=PollPrice!A1 cdim=2  par=report_decomp rng=decomposition!A1 cdim=2  par=report_honey rng=honeyPQ!A1 cdim=1  par=report_Bee_hBee rng=almond_Bees!A1 cdim=3 par=report_welfare rng=welfare!A1 cdim=2'


