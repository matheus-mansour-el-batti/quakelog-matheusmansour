require_relative "quakelog.rb"

file_path = "qgames.log"
quake_log = QuakeLog.new

puts "Counting kills..."
quake_log.count_kills(file_path)
puts "Finished counting kills..."

puts "Counting kill means..."
quake_log.count_kill_means(file_path)
puts "Finished counting kill means..."