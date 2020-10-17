#!/bin/bash

if [ -z "$1" ]; then
        echo "Correct usage is $0 <Version> [SONATYPE | BINTRAY]"
        exit -1
fi


if [ -z "$2" ]; then
        SONATYPE=0
        BINTRAY=1
else
        if [[] $2  = "BINTRAY" ]; then
                SONATYPE=0
                BINTRAY=1
        elif [[ $2  = "SONATYPE" ]]; then
                SONATYPE=1
                BINTRAY=0
        else
               echo "Correct usage is $0 <Version> [SONATYPE | BINTRAY]"
                exit -1
        fi
fi


VERSION=$1
VERSION_CODE=${VERSION//./}
VERSION_CODE=${VERSION_CODE//+/}

gsed -i  "s/^\( *versionName *\).*$/\1'$VERSION'/" flauto_engine/android/FlautoEngine/build.gradle
gsed -i  "s/^\( *versionCode *\).*$/\11$VERSION_CODE/" flauto_engine/android/FlautoEngine/build.gradle
gsed -i  "s/^\( *implementation 'xyz.canardoux:FlautoEngine:\).*$/\1$VERSION'/" flutter_sound/android/build.gradle

git add .
git commit -m "pod_flauto_engine_android.sh : Version $VERSION"
git push
git tag -f flauto_engine_$1
git push --tag -f

cd flauto_engine/android/FlautoEngine

if [ $BINTRAY .eq 1 ]; then

        #./gradlew clean
        #./gradlew assemble
        #if [ $? -ne 0 ]; then
        #    echo "Error"
        #    exit -1
        #fi

        ./gradlew clean build publishReleasePublicationToSonatypeRepository
        if [ $? -ne 0 ]; then
            echo "Error"
            exit -1
        fi

        #./gradlew closeAndReleaseRepository
        #if [ $? -ne 0 ]; then
        #    echo "Error"
        #    exit -1
        #fi

else
        ./gradlew clean build bintrayUpload
        if [ $? -ne 0 ]; then
            echo "Error"
            exit -1
        fi

fi

if [ $BINTRAY .eq 1 ]; then
        echo 'E.O.J'
        echo 'Do not forget to go to "https://oss.sonatype.org/#view-repositories;public~browsestorage" and close/publish your new version'
else
        echo 'E.O.J'
        echo 'Do not forget to go to "https://bintray.com/larpoux/CanardouxMaven/xyz.canardoux.FlautoEngine" and close/publish your new version'
fi