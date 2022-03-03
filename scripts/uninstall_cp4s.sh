# This tool will delete resoruces from the cluster before uninstalling
# the cloud pak for security operator

# You will need to be logged into your cluster before running this tool

# you will also need to have cloudctl availble and logged in

export CP4S_DIR=./cp4s_install &&
mkdir $CP4S_DIR && cd $CP4S_DIR
cloudctl case launch -t 1 --case ibm-cp-security --namespace cp4s  --inventory ibmSecurityOperatorSetup --action uninstall
cloudctl case launch -t 1 --case ibm-cp-security --inventory ibmSecurityOperatorSetup --action uninstall --args "--deleteCrd"
cloudctl case launch -t 1 --case ibm-cp-security --namespace ibm-common-services  --inventory ibmSecurityOperatorSetup --action uninstall-foundationalservices --args "--inputDir ./cp4s_install/"
