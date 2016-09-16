#! /usr/bin/ruby

# CrashlyticsのBeta配信などに表示するReleaseNoteを生成する

if ENV['BUILD_NUMBER'] then
    puts "Build: #{ENV['JOB_BASE_NAME']} - #{ENV['BUILD_NUMBER']}\n"
    puts "#{ENV['CHANGE_TITLE']}" if ENV['CHANGE_TITLE']
    puts "#{ENV['BUILD_URL']}\n"
end

def change_log()
    git_log = ""

    # name-revを調べる
    name_rev = `git name-rev --name-only --refs origin/master HEAD`.chomp

    # undefined なら origin/master に取り込まれていないブランチ
    if name_rev == "undefined" then
        git_log = `git log --oneline HEAD...origin/master --no-merges`
    end

    # origin/master なら masterと同等
    if name_rev == "origin/master" then
        git_log = `git log --oneline HEAD...origin/master^1`
    end

    # origin/master~X なら masterより古いので本流の一つ前のコミットと比較
    if match = name_rev.match(/^origin\/master~\d+/) then
        git_log = `git log --oneline HEAD...#{match}^1`
    end
    
    return git_log
end

puts "==============================\n"
puts "Changes"
puts "\n"
puts change_log
