$title simulate the effect of Almond pollination requirement on Bee market with forage scarcity adjustment

$ontext
   setglobal betavalue x
   x = beta*1000 in the model
$offtext
*$setglobal betavalue 00

$include c-Sim_forage
beta=%betavalue%/1000;


set iters used for almonad acrage scenarios /iter1*iter51/;
set iter(iters) ;
iter(iters)=yes;

set comp components in the objective function /percent, cs,ps,wel, shippingC, splitC, feedingC, extractC,
                                           PoliC, total, shadowprice, honey_p, honey_q, honey_rev, poli_rev, under_dem/
    cost_comp(comp) cost component as the subset /shippingC, splitC, feedingC, extractC,PoliC/

    aa before after and diff /before, after, diff/
    bb pollination or honey porpose /all, almond, other/;

parameter r_fratio(period, Flocation, iters)
          beebase_save(period, Flocation,subt)            save beebase
          shocks(iters)                                   the shocks to V matrix to test if the model can be survived
          vsave(period, location)                         save the simulated v
          honeysave(period, location)                     save the simulated honey matrix
          PollHivessave(Period,Location,subt)             save pollination requirement

          modelstat1(iters, *)                                save the model status to decompse the shadow prices
          report_poliprice(allcrop,subt, iters)               save the polination price
          report_beel(period, location,subt, iters)           save bee solution
          report_beeal(period, location,subt, iters)          save beeA solution
          report_splitl(period, location,subt, iters)         save split solution
          report_honey(subt,iters,*)                          report honey sales    and price
          Decomp(comp,aa, bb,subt)                            decomponent the objective function
          report_decomp(comp,bb,subt, iters)                  save the decomponented obj


          report_V(period, location, iters)                     report the V matrix after adjustment
          report_honeyV(period, location, iters)                report the honey matrix after adjustment

          report_welfare(comp,subt, iters)                    save the welfare component
          report_Bee_hBee(Period,Location,subt,iters,bb)      report the bee level with honey location seperated
          report_polihives(period, location,subt, iters)      report pollination hives
   ;

PollHivessave(Period,Location,subt)= PollHives(Period,Location,subt);
Vsave(period, location)= vnew(Period,Location) ;
honeysave(Period,Location)  = honeynew(Period,Location);
honey(Period,Location)=   honeysave(Period,Location);
beebase_save(period, Flocation,subt)= beebase(period, Flocation,subt);

shocks(iters)= ord(iters)*0.02-0.52 ;


display shocks, beebase;
option solprint=off;
option limrow=0;
option limcol=0;
option dnlp=ipopt;
option nlp=conopt;


set iterinfes iterate the model when model status is not optimal / iter1*iter10/;

$macro honeyp(subt) \
           [(HONEYSALES2.L(subt)$(HONEYSALES2.l(subt)>0)/honeyquantity1(subt))**(1./epsilon) ]* honeyprice1(subt) \
          + ([min( k, (1/k)**(1/epsilon))]* honeyprice1(subt) )$(HONEYSALES1.l(subt)>0)


loop(iter,
         Decomp(comp,aa,bb,subt)=0;
         PollHives(Period,Location,subt)= PollHivessave(Period,Location,subt);
         PollHives(Period,Location,subt)$sum(MapCropPollSeason('almond', Location, Period), PollReq('almond',subt))
                 =   sum(MapCropPollSeason('almond', Location, Period), PollReq('almond',subt)*(1+shocks(iter))) ;


         V(period, location)= Vsave(period, location);
         honey(Period,Location)= honeysave(Period,Location);
         beebase(period, Flocation,subt)= beebase_save(period, Flocation,subt);
         beebase(period, Flocation,subt)$sum((MapCropPollSeason('almond', subLocation, Period),mapforage(Flocation,sublocation)), PollReq('almond',subt))
                 =   sum((MapCropPollSeason('almond', subLocation, Period),mapforage(Flocation,sublocation)), PollReq('almond',subt)*(1+shocks(iter))) ;


         SOLVE TRANSPORT USING dNLP MINIMIZING Obj;
         beesave(period,Flocation,t)= beeF.l(period, Flocation, t);
         r_fratio(period, Flocation, iter)= fratiofunction(BEEF.l(Period,FLocation,subt1),BEEBase(Period,FLocation,subt1));
         modelstat1(iter, 'calibration')=  TRANSPORT.modelStat;
         report_V(period, location, iter)                                                   = V(period, location)*sum(mapforage(Flocation,location), r_fratio(period, Flocation, iter));
         report_honeyV(period, location, iter)                                              = honey(period, location);

         if(not (TRANSPORT.modelStat=5 or TRANSPORT.modelStat=6),

         SOLVE TRANSPORT_sp USING NLP MINIMIZING Obj;

         loop(iterinfes$( not TRANSPORT_sp.modelStat=2) ,
             SOLVE TRANSPORT_sp USING NLP MINIMIZING Obj;    );

         report_poliprice(allcrop,subt, iter)                                                    = -sum(MapCropPollSeason(ALLCrop, subLocation, Period), 1*POLQUANT.m(Period,subLocation,subt))  ;
         modelstat1(iter, 'before')=  TRANSPORT_sp.modelStat;
$ondotl
         report_BEEL(Period,subLocation,subt,iter)$( BEE.L(Period,subLocation,subt)>0.1)         = BEE(Period,subLocation,subt)                 ;
         report_BEEAL(Period,sublocation,subt,iter)$(BEEA.L(Period,sublocation,subt)>0.1)        = BEEA(Period,sublocation,subt)                 ;
         report_SPLITL(Period,subLocation,subt,iter) $ (SPLIT.L(Period,subLocation,subt)>0.1)    = SPLIT(Period,subLocation,subt)                 ;

         report_Honey(subt,iter, 'price')                                                        = honeyp(subt);
         report_HONEY(subt,iter, 'sales')$(HONEYSALES1(subt)+ HONEYSALES2(subt)>0.1)             = HONEYSALES1(subt)+ HONEYSALES2(subt)                   ;
         report_HONEY(subt,iter, 'sales1')$(HONEYSALES1(subt)+ HONEYSALES2(subt)>0.1)            = HONEYSALES1(subt)                  ;
         report_HONEY(subt,iter, 'sales2')$(HONEYSALES1(subt)+ HONEYSALES2(subt)>0.1)            = HONEYSALES2(subt)                   ;
         report_Honey(subt,iter, 'produced')                                                     = SUM((Period,subLocation),Honey(Period,subLocation)*BEE(Period,subLocation,subt))/1000;

         report_Bee_hBee(Period,subLocation,subt,iter,'all')     = report_beel(Period,subLocation,subt,iter);
         report_welfare('under_dem',subt, iter)                  = cs(subt)  ;
         report_welfare('honey_p',subt, iter)                    = honeyp(subt);
         report_welfare('honey_q',subt, iter)$(HONEYSALES1(subt)+ HONEYSALES2(subt)>0.1)
                                                                 = 1000*(HONEYSALES1(subt)+ HONEYSALES2(subt)) ;
         report_welfare('honey_rev',subt, iter)                  = report_welfare('honey_p',subt, iter)*report_welfare('honey_q',subt, iter)    ;
         report_welfare('poli_rev',subt, iter)                   = -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,subt)*POLQUANT.m(Period,subLocation,subt))  ;
         report_welfare('shippingC',subt,iter)                   =shippingC(subt);
         report_welfare('splitC',subt,   iter)                   =splitC(subt);
         report_welfare('feedingC',subt, iter)                   =feedingC(subt);
         report_welfare('ExtractC',subt,iter)                    =ExtractC(subt);
         report_welfare('PoliC',subt,iter)                       =PoliC(subt);
         report_welfare('cs',subt, iter)                         = report_welfare('under_dem',subt, iter) -   report_welfare('honey_rev',subt, iter);
         report_welfare('ps',subt, iter)                         = report_welfare('honey_rev',subt, iter) + report_welfare('poli_rev',subt, iter)
                                                                         -sum(cost_comp,  report_welfare(cost_comp,subt, iter))    ;



         Decomp('honey_p','before','all',subt)        = honeyp(subt);
         Decomp('honey_q','before','all',subt)$(HONEYSALES1(subt)+ HONEYSALES2(subt)>0.1)
                                                      = 1000*(HONEYSALES1(subt)+ HONEYSALES2(subt))                   ;

         Decomp('cs','before','all',subt)             =cs(subt) - Decomp('honey_p','before','all',subt)*Decomp('honey_q','before','all',subt) ;

         Decomp('shippingC','before','all',subt)      =shippingC(subt);
         Decomp('splitC','before','all',subt)         =splitC(subt);
         Decomp('feedingC','before','all',subt)       =feedingC(subt);

         Decomp('ExtractC','before','all',subt)       =ExtractC(subt);
         Decomp('PoliC','before','all',subt)          =PoliC(subt);

         Decomp('ps','before','all',subt)             =  Decomp('honey_p','before','all',subt)*Decomp('honey_q','before','all',subt)
* polination reveunue
                                                          -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,subt)*POLQUANT.m(Period,subLocation,subt))
*all cost
                                                          - sum(cost_comp,Decomp(cost_comp,'before','all',subt) )         ;

         Decomp('wel', 'before', 'all',subt)             =   cs(subt)-  sum(cost_comp,Decomp(cost_comp,'before','all',subt) )               ;
         Decomp('honey_rev','before','all',subt)         =   Decomp('honey_p','before','all',subt)*Decomp('honey_q','before','all',subt);
         Decomp('under_dem', 'before', 'all',subt)       =   cs(subt);
         Decomp('poli_rev', 'before', 'all',subt)        =  -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,subt)*POLQUANT.m(Period,subLocation,subt));
         Decomp('poli_rev', 'before', 'almond',subt)     =  -sum(MapCropPollSeason('almond',subLocation, Period), PollHives(Period,subLocation,subt)*POLQUANT.m(Period,subLocation,subt));
         Decomp('poli_rev', 'before', 'other',subt)      =  -sum(MapCropPollSeason(Allcrop,subLocation, Period)$(not sameas(allcrop, 'almond')), PollHives(Period,subLocation,subt)*POLQUANT.m(Period,subLocation,subt));

$offdotl

* resolve the model

         PollHives(Period,Location,subt)= PollHivessave(Period,Location,subt);
         PollHives(Period,Location,subt)$sum(MapCropPollSeason('almond', Location, Period), PollReq('almond',subt))
                 = 1+  sum(MapCropPollSeason('almond', Location, Period), PollReq('almond',subt)*(1+shocks(iter))) ;

         SOLVE TRANSPORT_sp USING NLP MINIMIZING Obj;

         loop(iterinfes$( not TRANSPORT_sp.modelStat=2) ,
             SOLVE TRANSPORT_sp USING NLP MINIMIZING Obj;    );
         modelstat1(iter, 'after')=  TRANSPORT_sp.modelStat;
         report_polihives(period, location,subt, iter)= PollHives(Period,Location,subt);

$ondotl
         Decomp('honey_p','after','all',subt)        =   honeyp(subt);
         Decomp('honey_q','after','all',subt)$(HONEYSALES1(subt)+ HONEYSALES2(subt)>0.1)
                                                     = 1000*(HONEYSALES1(subt)+ HONEYSALES2(subt)  )                 ;

         Decomp('cs','after','all',subt)             =cs(subt) - Decomp('honey_p','after','all',subt)*Decomp('honey_q','after','all',subt);


         Decomp('shippingC','after','all',subt)      =shippingC(subt);
         Decomp('splitC','after','all',subt)         =splitC(subt);
         Decomp('feedingC','after','all',subt)       =feedingC(subt);
         Decomp('ExtractC','after','all',subt)       =ExtractC(subt);
         Decomp('PoliC','after','all',subt)          =PoliC(subt);

         Decomp('ps','after','all',subt)           =  Decomp('honey_p','after','all',subt)*Decomp('honey_q','after','all',subt)
* polination reveunue
                                                          -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,subt)*POLQUANT.m(Period,subLocation,subt))
*all cost
                                                          - sum(cost_comp,Decomp(cost_comp,'after','all',subt) )               ;

         Decomp('wel', 'after', 'all',subt)              =   cs(subt)-  sum(cost_comp,Decomp(cost_comp,'after','all',subt) )               ;

         Decomp('wel', 'after', 'all',subt)              =   cs(subt)-  sum(cost_comp,Decomp(cost_comp,'after','all',subt) )               ;
         Decomp('honey_rev','after','all',subt)          =   Decomp('honey_p','after','all',subt)*Decomp('honey_q','after','all',subt);
         Decomp('under_dem', 'after', 'all',subt)        =   cs(subt);
         Decomp('poli_rev', 'after', 'all',subt)         =  -sum(MapCropPollSeason(ALLCrop,subLocation, Period), PollHives(Period,subLocation,subt)*POLQUANT.m(Period,subLocation,subt));
         Decomp('poli_rev', 'after', 'almond',subt)      =  -sum(MapCropPollSeason('almond',subLocation, Period), PollHives(Period,subLocation,subt)*POLQUANT.m(Period,subLocation,subt));
         Decomp('poli_rev', 'after', 'other',subt)       =  -sum(MapCropPollSeason(Allcrop,subLocation, Period)$(not sameas(allcrop, 'almond')), PollHives(Period,subLocation,subt)*POLQUANT.m(Period,subLocation,subt));


$offdotl
* calculate the marginal effect and save it
         Decomp(comp,'diff',bb,subt) = (Decomp(comp,'after',bb,subt)- Decomp(comp,'before',bb,subt))/1;
         report_decomp(comp,bb,subt, iter)=Decomp(comp,'diff',bb,subt);
         report_decomp('percent','all',subt, iter)=  shocks(iter);
         report_decomp('shadowprice','all',subt, iter)= report_poliprice('almond',subt, iter);

);
         if( (TRANSPORT.modelStat=5 or TRANSPORT.modelStat=6),
$        if exist TRANSPORT_ind_p.gdx execute_loadpoint 'TRANSPORT_ind_p.gdx'
           );
);




execute_unload "Almond_forage_joint_%yyear1%_%yyear2%_%Vbound%_%betavalue%.gdx" Vnew honeynew   modelstat1 report_poliprice report_decomp     r_fratio    shocks
                                         report_honey  report_beel report_beeal report_splitl   report_honeyV report_V   report_Bee_hBee   report_welfare

execute 'gdxxrw.exe Almond_forage_joint_%yyear1%_%yyear2%_%Vbound%_%betavalue%.gdx par=Vnew rng=V!A1 par=honeynew rng=HoneyRate!A1  par=shocks rng=shocks!A1   par=modelstat1 rng=modelstat1!A1'
execute 'gdxxrw.exe Almond_forage_joint_%yyear1%_%yyear2%_%Vbound%_%betavalue%.gdx par=report_poliprice rng=PollPrice!A1 cdim=2 par=report_decomp rng=decomposition!A1 cdim=2  par=report_honey rng=honeyPQ!A1  par=report_Bee_hBee rng=almond_Bees!A1 cdim=3 par=report_welfare rng=welfare!A1 cdim=2 '
execute 'gdxxrw.exe Almond_forage_joint_%yyear1%_%yyear2%_%Vbound%_%betavalue%.gdx par=report_honeyV rng=honeyV_adj!A1 par=report_V rng=V_adj!A1  par=r_fratio rng=r_fratio!A1'



