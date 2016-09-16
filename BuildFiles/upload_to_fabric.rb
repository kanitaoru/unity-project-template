#! /usr/bin/ruby

# Fabric にIPA, APKをアップロードする
# UnityプロジェクトにインポートされたFabric設定から一部の設定を読み込むので、FabricSDKがインポートされていることが必須

require 'yaml'
require 'fileutils'
require 'optparse'

def usage()
    puts "usage: upload_to_fabric.rb [--unity-project-path|-u] <path> [--ipa <path>] [--apk <path>] [--group-aliases]"
    puts ""
    puts "--unity-project-path: Unity Project ディレクトリへのパス(必須)"
    puts "--ipa: アップロードしたいIPAファイルへのパス"
    puts "--apk: アップロードしたいAPKファイルへのパス"
    puts "--group-aliases: Fabricで配信対象とするグループ 複数指定はカンマ区切りで"
end

params = ARGV.getopts('', 'unity-project-path:', 'ipa:', 'apk:', 'group-aliases:', 'notifications:false')
fail "Unityプロジェクトへのパスは必須です" if params['unity-project-path'].nil?
fail "IPAかAPKの少なくともどちらかは必要です" if params['ipa'].nil? && params['apk'].nil?

GIT_ROOT=`git rev-parse --show-toplevel`.chomp
UNITY_PROJECT_PATH = params['unity-project-path']

# for IPA
CRASHLYTICS_FRAMEWORK = "#{UNITY_PROJECT_PATH}/Assets/Plugins/iOS/Fabric/Crashlytics.framework"
# for APK
CRASHLYTICS_JAR = "#{GIT_ROOT}/BuildFiles/crashlytics/crashlytics-devtools.jar"

puts "====== upload_to_fabric ======"

# 長いReleaseNoteを投稿する時はファイルに書き出して、そのパスを指定する
RELEASE_NOTE = ENV['RELEASE_NOTE'] || `#{GIT_ROOT}/BuildFiles/create_releasenote.rb`
RELEASE_NOTE_PATH = "#{GIT_ROOT}/Build/release_note.txt"
File.open(RELEASE_NOTE_PATH, "w") do |file|
    file.print(RELEASE_NOTE)
end

# コマンド実行に失敗したら終了する
def sh(*args)
    puts *args
    system *args or fail
end

# Fabric Setting をエディタでAssetに設定したものから読み込む
FABRIC_SETTING_FILE = "#{UNITY_PROJECT_PATH}/Assets/Editor Default Resources/FabricSettings.asset"
setting = YAML.load_file(FABRIC_SETTING_FILE)['MonoBehaviour']

crashlytics_args = {
    'ipa_path'      => params['ipa'],
    'apk_path'      => params['apk'],
    'api_key'       => setting['organization']['ApiKey'],
    'build_secret'  => setting['organization']['BuildSecret'],
    'group_aliases' => params['group-aliases'],
    'notifications' => params['notifications'] == "true" ? "YES" : "NO",
    'release_note_path' => RELEASE_NOTE_PATH
}

puts crashlytics_args

# iOS
def upload_ipa(args)
    options = [
        args['api_key'],
        args['build_secret'],
        "-ipaPath", args['ipa_path'],
        "-groupAliases", args['group_aliases'],
        "-notifications", args['notifications'],
        "-notesPath", args['release_note_path']
    ]
    
    submit = "#{CRASHLYTICS_FRAMEWORK}/submit #{options.join(" ")}"
    puts "----- submit ios -----"
    sh submit
end

def upload_apk(args)
    # copy from https://github.com/fastlane/fastlane/blob/1b40998598d7ab95a6bea2107fa14399c4304559/fastlane/lib/fastlane/helper/crashlytics_helper.rb#L27-L31
    # We have to generate an empty XML file to make the crashlytics CLI happy :)
    require 'tempfile'
    xml = Tempfile.new('xml')
    xml.write('<?xml version="1.0" encoding="utf-8"?><manifest></manifest>')
    xml.close
    # end copy

    options = [
        "-androidRes", ".",
        "-androidManifest", xml.path,
        "-apiKey", args['api_key'],
        "-apiSecret", args['build_secret'],
        "-uploadDist", args['apk_path'],
        "-betaDistributionGroupAliases", args['group_aliases'],
        "-betaDistributionReleaseNotesFilePath", args['release_note_path'],
        "-betaDistributionNotifications", args['notifications']
    ]

    submit_android = "java -jar #{CRASHLYTICS_JAR} #{options.join(" ")}"
    puts "----- submit android -----"
    sh submit_android
end

# Upload

upload_ipa crashlytics_args unless params['ipa'].nil?
upload_apk crashlytics_args unless params['apk'].nil?
