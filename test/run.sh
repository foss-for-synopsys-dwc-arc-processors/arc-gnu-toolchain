# create the module file that suits your configuration
module load arc64
module load nsim
mkdir -p tmp

runtest dg.exp
runtest execute.exp
