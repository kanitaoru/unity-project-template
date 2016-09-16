#! /usr/bin/ruby

require 'yaml'

# 環境指定 BuildConfigsに対応するyamlファイルがあればOK
ENVIRONMENT = ARGV[0]

puts "====== build_ios ======"

GIT_ROOT = `git rev-parse --show-toplevel`.chomp
CONFIG_PATH = "#{GIT_ROOT}/BuildFiles/Configs/#{ENVIRONMENT}.yaml"
yaml = YAML.load_file(CONFIG_PATH)

PRODUCT_NAME = yaml['product_name']
XCODE_PROJECT_ROOT = "#{GIT_ROOT}/Build/iOS/#{PRODUCT_NAME}"
XCODE_PROJECT_BUILD_PATH = "#{XCODE_PROJECT_ROOT}/build"
XCODE_PROJECT_PATH = "Build/iOS/#{PRODUCT_NAME}/Unity-iPhone.xcodeproj"
CONFIGURATION = "Release build"
# 署名
IDENTITY = "iPhone Developer"
# アプリに含むProvisioningProfile 通称でもOKなはず 用意できたら変える
PROVISIONING_PROFILE = yaml['provisioning_profile']
PROVISIONING_PATH = "#{GIT_ROOT}/ProvisioningProfile/#{PROVISIONING_PROFILE}"

# コマンド実行に失敗したら終了する
def sh(*args)
  puts *args
  system *args or fail
end

# Certificateディレクトリ下の証明書をすべて取り込む
sh "find #{GIT_ROOT}/BuildFiles/Certificates/*.p12 | xargs -n1 -ICERTIFICATE_PATH security import CERTIFICATE_PATH -k ~/Library/Keychains/login.keychain -P \"\" -T /usr/bin/codesign"

# ProvisioningProfileを取り込む
install_provisioning = "#{GIT_ROOT}/BuildFiles/install_provisioning.sh"
sh install_provisioning

# XcodeProjectをビルド
xcodeversion = "xcodebuild -version"
sh xcodeversion

xcodebuild = "xcodebuild -project #{XCODE_PROJECT_PATH} -configuration #{CONFIGURATION} CODE_SIGN_IDENTITY='#{IDENTITY}'"
sh xcodebuild

# ipa を作る

# bundleIDの最後が使われる
# もしかしたら xcodebuild で吐き出し名称決められるかもしれないので、できそうならそれを使うように変える
APP_FILE_NAME = yaml['ios']['bundle_identifier'].split('.').last + ".app"
APP_PATH = "#{XCODE_PROJECT_BUILD_PATH}/Release-iphoneos/#{APP_FILE_NAME}"
IPA_FILE_NAME = "#{PRODUCT_NAME}.ipa"
IPA_PATH = "#{GIT_ROOT}/Build/iOS/#{IPA_FILE_NAME}"

# ipa生成
# provisioningが用意できたら --embed PROVISIONING_PATH をつける
puts "=== IPAを生成 ==="
xcrun = "xcrun -sdk iphoneos PackageApplication -v #{APP_PATH} -o #{IPA_PATH} -embed #{PROVISIONING_PATH}"
sh xcrun

puts "#{IPA_PATH}"
