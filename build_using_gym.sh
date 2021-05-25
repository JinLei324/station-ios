#!/bin/bash

#计时
SECONDS=0

#假设脚本放置在与项目相同的路径下
project_path=$(pwd)
#取当前时间字符串添加到文件结尾
now=$(date +"%Y_%m_%d_%H_%M_%S")

#项目名
projectName="LonelyStation"
#指定项目的scheme名称
scheme="LonelyStation"
#指定要打包的配置名
configuration="Adhoc"
#指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
export_method='ad-hoc'

#指定项目地址
workspace_path="$project_path/$projectName.xcworkspace"
#指定输出路径
output_path="$(pwd)/ipa"
#指定输出归档文件地址
archive_path="$output_path/${projectName}_${now}.xcarchive"
#指定输出ipa地址
ipa_path="$output_path/${projectName}.ipa"
#指定输出ipa名称
ipa_name="${projectName}.ipa"
#获取执行命令时的commit message
commit_msg="$1"

#导出ipa配置文件的目录
exportOptionsPlist="$project_path/ExportOptions.plist"



#输出设定的变量值
echo "===workspace path: ${workspace_path}==="
echo "===archive path: ${archive_path}==="
echo "===ipa path: ${ipa_path}==="
echo "===export method: ${export_method}==="
echo "===commit msg: $1==="

# 移除原来的path
rm -rf ${output_path}
rm -rf "build"

#清空build文件
xcodebuild clean -workspace ${workspace_path} -scheme ${scheme} -configuration Release 

# 先清空前一次build
xcodebuild archive -workspace ${workspace_path} -scheme ${scheme} -configuration Release -archivePath "${archive_path}"

# 判断编译状态
if [ ! -f "${archive_path}" ]; then
	echo "编译成功"
else
	echo "编译失败"

	# 显示消耗时间
	displayUsedTime
	exit 1
fi

xcodebuild -exportArchive -archivePath "${archive_path}" -exportPath "${output_path}"  -exportOptionsPlist "${exportOptionsPlist}"

#上传到fir
fir publish ${ipa_path}
#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="
