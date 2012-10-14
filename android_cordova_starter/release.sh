#!/bin/bash
#do not set ANTHOME var if ant is installed on machine
#ANTHOME=$HOME/apache-ant-1.8.3/bin/
REPODIR=$HOME/Dropbox/Programming/git/apps-mobile
DESTDIR=$HOME/Dropbox/Programming/release-apps/android

#komma separierte projekt namen, um mehrere projekte zu releasen
#z.B.:
#for i in {"projekt1","projekt2","projekt3"}; do

for i in "android_cordova_starter"; do

PROJECTDIR=${REPODIR}/$i
#ubuntu
#PROJECTNAME=`grep -e "name=\"[A-Za-z]*\"" ${PROJECTDIR}/build.xml| grep -oE "name=\"[A-Za-z]*\""| grep -oE "\"[A-Za-z]*\""| grep -oE "[A-Za-z]*"`
#mac
PROJECTNAME=`cat ./build.xml | grep -oE "name=\"[A-Za-z_]*\"" | grep -oE \""[A-Za-z_]*\"" | grep -oE "[A-Za-z_][A-Za-z_]*"`

#ubuntu
#VERSIONNAME=`grep -e "android:versionName=\"[0-9](\.[0-9])?" ${PROJECTDIR}/AndroidManifest.xml | grep -oE "[0-9]\.[0-9]"`
#mac
VERSIONNAME=`cat ${PROJECTDIR}/AndroidManifest.xml | grep -oE "android:versionName=\"[0-9](\.[0-9])?" | grep -oE "[0-9]\.[0-9]"`

#ubuntu
#VERSIONCODE=`grep -e "android:versionCode=\"[0-9]*" ${PROJECTDIR}/AndroidManifest.xml | grep -oE "[0-9]*"`
#mac
VERSIONCODE=`cat ${PROJECTDIR}/AndroidManifest.xml | grep -oE "android:versionCode=\"[0-9]*" | grep -oE "[0-9]([0-9]*)?"`

echo ----------------------------------------------------------------------------------------------------------------------------
echo VERSION Name ${VERSIONNAME} Code ${VERSIONCODE} Project ${PROJECTNAME} in Directory ${PROJECTDIR}
echo ----------------------------------------------------------------------------------------------------------------------------

VERSIONSTRING=${VERSIONCODE}-${VERSIONNAME}
OUTPUTNAME=${PROJECTNAME}-${VERSIONSTRING}
APKNAME=${OUTPUTNAME}.apk
#echo Erstelle APK: ${APKNAME} in ${RELEASEDIR}
RELEASEDIR=${DESTDIR}/${VERSIONSTRING}
RETRACEDIR=${RELEASEDIR}/proguard

#create release dirs
echo "mkdir -p ${RELEASEDIR}"
mkdir -p ${RELEASEDIR}

#create retrace dirs
echo "mkdir -p ${RETRACEDIR}"
mkdir -p ${RETRACEDIR}

#remove old proguard files
echo "rm -rf ${PROJECTDIR}/bin/proguard/*"
rm -rf ${PROJECTDIR}/bin/proguard/*

echo "${ANTHOME}ant clean release -f ${PROJECTDIR}/build.xml"
${ANTHOME}ant clean release -f ${PROJECTDIR}/build.xml

#copy APK to release dir
echo "rm -f ${RELEASEDIR}/${APKNAME}"
rm -f ${RELEASEDIR}/${APKNAME}
echo "cp ${PROJECTDIR}/bin/${PROJECTNAME}-release.apk ${RELEASEDIR}/${APKNAME}"
cp ${PROJECTDIR}/bin/${PROJECTNAME}-release.apk ${RELEASEDIR}/${APKNAME}

#create proguard retrace zip file
echo "rm -f ${RETRACEDIR}/retrace-${OUTPUTNAME}.tar.gz"
rm -f ${RETRACEDIR}/retrace-${OUTPUTNAME}.tar.gz
echo "tar cvzf ${RETRACEDIR}/${OUTPUTNAME}.tar.gz -C ${PROJECTDIR}/bin proguard"
tar cvzf ${RETRACEDIR}/retrace-${OUTPUTNAME}.tar.gz -C ${PROJECTDIR}/bin proguard

echo 
echo 
	
	FLAG="CREATED"
	APATH=${RELEASEDIR}/${APKNAME}
	if [ -f $APATH ]; then
		FLAG="CREATED"
	else
		FLAG="NOT CREATED"
	fi;
	echo ${FLAG}: APK ${APKNAME} in ${RELEASEDIR}
echo ____________________________________________________________________________________________________________________________

echo 
echo 

done