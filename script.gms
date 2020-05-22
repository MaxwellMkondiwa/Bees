$title script file shows how to run the code

$ontext
 use "*" to comment out undesired code
 Once a-dataGen.gms is ran, and saved as restart file a1, you don't have to rerun it.
$offtext
*##############################
*  To calibrate the model     #
*##############################

* before running MPC and MPEC, please make sure the setglobal are consistent in two file

execute 'gams a-DataGen.gms s= a1'
execute 'gams b-Model_MCP.gms r= a1'
execute 'gams b-Model_MPEC.gms r= a1'

*##############################
*  To simulate the model      #
*##############################

* before running MPC and MPEC, please adjust setglobal to get desired scenarios

* 1. Almond scenario without forage scarcity adjustment
execute 'gams a-DataGen.gms s= a1'
execute 'gams c-Almond.gms r= a1'

* 2. Mortality scenario without forage scarcity adjustment
execute 'gams a-DataGen.gms s= a1'
execute 'gams c-Mortality.gms r= a1'

* 3. Almond scenario with forage scarcity adjustment
execute 'gams a-DataGen.gms s= a1'
execute 'gams c-AlmondForage.gms r= a1'

* 4. Mortality scenario with forage scarcity adjustment
execute 'gams a-DataGen.gms s= a1'
execute 'gams c-MortalityForage.gms r= a1'