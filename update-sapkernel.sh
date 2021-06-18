#!/bin/bash

umask 022
#read -p 'SAP System ID? : ' SID
#if [[ -z "$SID" ]]; then
#	echo "Please enter SAP System ID and SAP Kernel version e.g."
#	echo "/sapkernel-update.sh ECD 781"
#	exit 1
#fi

#read -p 'Kernel version? [781|753]: ' KERNEL_VER


echo "SID: ECD"
SID=ECD
export sidadm=${SID,,}adm;
echo "SAP Kernel version: 781"
KERNEL_VER=781
echo "Current SAP kernel patch level is:"
echo "`su ${sidadm} -c "disp+work -V | grep level"`"

case ${KERNEL_VER} in
        753)
                export SAP_EXE=SAPEXE_700-70000596.SAR
                export SAP_EXEDB=SAPEXEDB_700-70000595.SAR
                export DBATOOLS=DBATL740O11_36-80002605.SAR
		export DW=dw_1018-70004402.sar
		export DWUTILS=dw_utils_720-80002573.sar
		export R3TRANS=R3trans_722-80002573.SAR
		export TP=tp_722-80002573.sar
		export DBSLIB=lib_dbsl_721-80002605.sar
        ;;
        781)
                export SAP_EXE=SAPEXE_19-70005283.SAR
                export SAP_EXEDB=SAPEXEDB_19-70005282.SAR
#                export DBATOOLS=DBATL740O11_43-80002605.SAR
		export DW=dw_31-70005283.sar
		export DWUTILS=dw_utils_25-70005283.sar
		export R3TRANS=R3trans_29-70005283.SAR
		export TP=tp_29-70005283.sar
		export DBSLIB=lib_dbsl_29-70005282.sar
        ;;
        *)
                echo "Please specify SAP Kernel version!"
                exit;
        ;;
esac

export media=/media/Kernel${KERNEL_VER}Patch
#export sidadm=${SID,,}adm;
export SAPSYSTEMNAME=${SID}

echo " "
echo "SAP Kernel is now being updated...."
echo " "
echo "----------------------------------------------------- "
echo "SAP SID               : " $SAPSYSTEMNAME
echo "SAP Kernel Release    : " $KERNEL_VER
[[ ! -z "$SAP_EXE" ]] && echo "Target SAP_EXE        : " $SAP_EXE
[[ ! -z "$SAP_EXEDB" ]] && echo "Target SAP_EXEDB      : " $SAP_EXEDB
#[[ ! -z "$DBATOOLS" ]] && echo "Target DBA Tools      : " $DBATOOLS
[[ ! -z "$DW" ]] && echo "Target DW 	    : " $DW
[[ ! -z "$DWUTILS" ]] && echo "Target DWUTILS 	    : " $DWUTILS
[[ ! -z "$R3TRANS" ]] && echo "Target R3TRANS 	    : " $R3TRANS
[[ ! -z "$TP" ]] && echo "Target TP 	    : " $TP
[[ ! -z "$DBSLIB" ]] && echo "Target DBSLIB 	    : " $DBSLIB
echo "----------------------------------------------------- "
echo " "

# Create Backup
echo "Backing up old kernel to : /sapmnt/"${SAPSYSTEMNAME}"/exe/uc/linuxx86_64.bak."$(date '+%Y%m%d')
echo " "
cp -rp /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64 /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64.bak.$(date '+%Y%m%d')

# Extract new files
echo "Extracting new kernel media.. hold on..."
su ${sidadm} -c 'cp -rp /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR2'
[[ ! -z "$SAP_EXE" ]] && su ${sidadm} -c '/sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR2 -xvf $media/$SAP_EXE -R /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/'
[[ ! -z "$SAP_EXEDB" ]] && su ${sidadm} -c '/sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR -xvf $media/$SAP_EXEDB -R /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/'
#[[ ! -z "$DBATOOLS" ]] && su ${sidadm} -c '/sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR -xvf $media/$DBATOOLS -R /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/'
[[ ! -z "$DW" ]] && su ${sidadm} -c '/sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR -xvf $media/$DW -R /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/'
[[ ! -z "$DWUTILS" ]] && su ${sidadm} -c '/sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR -xvf $media/$DWUTILS -R /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/'
[[ ! -z "$R3TRANS" ]] && su ${sidadm} -c '/sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR -xvf $media/$R3TRANS -R /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/'
[[ ! -z "$TP" ]] && su ${sidadm} -c '/sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR -xvf $media/$TP -R /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/'
[[ ! -z "$DBSLIB" ]] && su ${sidadm} -c '/sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR -xvf $media/$DBSLIB -R /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/'

# Run saproot.sh SID
echo "Configuring kernel permissions with saproot.sh..."
cd /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/
/sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/saproot.sh $SAPSYSTEMNAME

# Fix BRTOOLS Permissions
#echo "Configuring DBA Tools permissions..."
#cd /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/
#chown oracle:oinstall brarchive brspace brrestore brrecover brconnect brbackup
#chown ${sidadm}:sapsys brtools
#chmod 6774 brrestore brconnect brspace brbackup brrecover brarchive

# Housekeep downloaded kernel .sar
echo "Cleaning up..."
rm -rf /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/SAPCAR2

# Check versions
echo " "
echo " "
echo "SAP Kernel update is complete. Verification below...."
echo "----------------------------------------------------- "
echo "New SAP Kernel version"
echo " "
#cat /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/sapmanifest.mf | grep kernel
echo "`su ${sidadm} -c "disp+work -V | grep level"`"
echo "----------------------------------------------------- "
echo " "
#echo "New DBA Tools version"
#echo " "
#cat /sapmnt/$SAPSYSTEMNAME/exe/uc/linuxx86_64/dbatoolsora.mf | grep dba