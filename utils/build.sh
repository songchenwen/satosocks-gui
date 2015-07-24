#!/bin/bash

NW_VERSION=v0.12.2
if [ $# == 0 ]; then
  echo 'usage: build.sh version'
  exit 1
fi
pushd `dirname $0`
cd ..
mkdir -p dist
cd dist
rm -rf app
mkdir app
pushd app && \
cp ../../*.js . && \
cp -r ../../css . && \
cp -r ../../img . && \
cp ../../*.json . && \
cp ../../*.htm* . && \
cp ../../*.png . && \
cp -r ../../fonts . && \
cp -r ../../node_modules . || \
exit 1
rm ../app.nw
zip -r ../app.nw * && \
popd && \
rm -rf app || \
exit 1
for platform in win-ia32 osx-x64
do
  if [ -f shadowsocks-gui-$1-$platform.tar.xz ]; then
    continue
  fi
  if [ ! -f nwjs-$NW_VERSION-$platform.zip ] || [ -f nwjs-$NW_VERSION-$platform.zip.aria2 ] ; then
    if [ ! -f nwjs-$NW_VERSION-$platform.tar.gz ] || [ -f nwjs-$NW_VERSION-$platform.tar.gz.aria2 ] ; then
      aria2c http://dl.nwjs.io/$NW_VERSION/nwjs-$NW_VERSION-$platform.zip || \
      aria2c http://dl.nwjs.io/$NW_VERSION/nwjs-$NW_VERSION-$platform.tar.gz || \
      exit 1
    fi
  fi
  mkdir -p shadowsocks-gui-$1-$platform && \
  pushd shadowsocks-gui-$1-$platform && \
  unzip ../nwjs-$NW_VERSION-$platform.zip || \
  tar xf ../nwjs-$NW_VERSION-$platform.tar.gz || \
  exit 1
  if [ -d nwjs-$NW_VERSION-$platform ]; then
    mv nwjs-$NW_VERSION-$platform/* ./ && \
    rm -r nwjs-$NW_VERSION-$platform || \
    exit 1
  fi
  if [ $platform == win-ia32 ]; then
      cat nw.exe ../app.nw > shadowsocks.exe && \
      rm -f nwsnapshot.exe && \
      rm ffmpegsumo.dll && \
      rm libEGL.dll && \
      rm libGLESv2.dll && \
      rm nw.exe || \
      exit 1
  fi
  if [ $platform == osx-x64 ]; then
      rm -f nwsnapshot && \
      cp ../app.nw nwjs.app/Contents/Resources/ && \
      cp ../../utils/Info.plist nwjs.app/Contents/ && \
      cp ../../utils/*.icns nwjs.app/Contents/Resources/ && \
      /usr/libexec/PlistBuddy -c "Set CFBundleVersion $1" nwjs.app/Contents/Info.plist  && \
      /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $1" nwjs.app/Contents/Info.plist  && \
      mv nwjs.app shadowsocks.app || \
      exit 1
  fi
  if [ $platform == linux-x64 ]; then
      rm -f nwsnapshot && \
      cp ../app.nw . && \
      cp ../../utils/linux/start.sh . && \
      rm libffmpegsumo.so || \
      exit 1
  fi
  popd
done
popd
