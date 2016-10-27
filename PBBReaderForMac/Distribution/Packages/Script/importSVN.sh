#!/bin/sh

#  Script.sh
#  PBBReaderForMac
#
#  Created by pengyucheng on 16/9/5.
#  Copyright © 2016年 recomend. All rights reserved.

###############获取版本号,bundleID
#获取版本号
#方式一
#bundleBuildVersion="`/usr/libexec/PlistBuddy -c \"Print CFBundleVersion\" $INFOPLIST_FILE`"
#echo $bundleBuildVersion
#方法二CFBundleShortVersionString
#http://stackoverflow.com/questions/6851660/version-vs-build-in-xcode
versionNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFOPLIST_FILE")
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
#
#新建导入目录
ProductName="$PRODUCT_NAME.$versionNumber.${buildNumber}"
ProductPath="$TARGET_BUILD_DIR/$PRODUCT_NAME.app"
ImportSVN="ImportSVN"
#上传时，先删除SVN目录
rm -rf ${ImportSVN}
pwd
if [ -d "$ImportSVN" ]; then
echo 'svn目录已存在'
else
echo '新建svn目录'
mkdir $ImportSVN
fi
echo "cp -rf $ProductPath ${ImportSVN}/$ProductName.app"
#压缩
#拷贝
cp -rf $ProductPath ${ImportSVN}/$ProductName.app
cd $ImportSVN
pwd
echo "zip -r $ProductName.app.zip . -i ./*"
#压缩后删除源文件
zip -rm "$ProductName.app.zip" ./*
#*/
cd ../
pwd

echo "import "${ImportSVN}" https:\/\/192.168.85.64/svn/安装包/MAC -m "${ProductName}""
export LC_CTYPE="zh_CN.UTF-8" #设置当前系统的 locale,支持中文路径
#svn import "${ImportSVN}" https:\/\/192.168.85.64/svn/安装包/MAC -m "${ProductName}"




------------------------------
#clone源码
git svn clone https://huoshuguang@192.168.85.6/svn/PBBReader_Mac/trunk/PBBReaderForMac
#提交更新
git svn dcommit
#变基：从服务器拉取本地还没有的改动，并将你所有的工作变基到服务器的内容之上
git svn rebase

#拉取最新
git svn fetch
#根据SVN项目中的svn:ignore设置生成对应git忽略文件.gitnore
git svn create-ignore
git svn show-ignore > .git/info/exclude

#查看内容变化
git diff
git diff --staged
git diff --cached
#强制覆盖服务器端上的分支
git push -u origin master -f

git remote add PBBReader https://git.oschina.net/huosan/PBBReader.git
