#include "__CUTTLEC_MODULE_NAME__.hpp"

__CUTTLEC_EXTFUNS__
using simulator = module___CUTTLEC_MODULE_NAME__<extfuns>;

#ifdef SIM_MINIMAL
template simulator::state_t cuttlesim::init_and_run<simulator>(unsigned long long int);
#else
int main(int argc, char **argv) { return cuttlesim::main<simulator>(argc, argv); }
#endif