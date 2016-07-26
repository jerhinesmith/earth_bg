#!/usr/bin/env ruby

require 'open-uri'

minutes_behind  = ENV.fetch('since', 30)
level           = ENV.fetch('level', 8)
width           = 550
current_time    = Time.now.utc - (60 * minutes_behind)
year            = current_time.year
month           = current_time.month
day             = current_time.day
hour            = current_time.hour
minute          = (current_time.min / 10) * 10
second          = 0
resolution      = `system_profiler SPDisplaysDataType | grep Resolution | egrep -o "[0-9]+\sx\s[0-9]+"`.chomp.gsub(/\s/, '')

base_file_name  = "#{"%02d" % hour}#{"%02d" % minute}#{"%02d" % second}"
tmp_path        = File.join(__dir__, 'tmp')
raw_path        = File.join(__dir__, 'raw.png')
final_path      = File.join(__dir__, 'current.png')

Dir.mkdir tmp_path unless File.exists?(tmp_path)

threads = []

(0...level).each do |y|
  (0...level).each do |x|
    file_name = "#{base_file_name}_#{x}_#{y}.png"
    tile_url  = "http://himawari8-dl.nict.go.jp/himawari8/img/D531106/#{level}d/#{width}/#{year}/#{"%02d" % month}/#{"%02d" % day}/#{file_name}"

    threads << Thread.new do
      open(tile_url) do |f|
        puts tile_url
        File.open(File.join(tmp_path, file_name), "wb") do |file|
         file.puts f.read
        end
      end
    end
  end
end

threads.each(&:join)

`/usr/local/bin/montage #{(0...level).collect{|y| (0...level).collect{|x| File.join(tmp_path, "#{base_file_name}_#{x}_#{y}.png")}}.join(' ')} -geometry '1x1+0+0<' -background none #{raw_path}`

`/usr/local/bin/convert -resize #{resolution} -gravity center -extent #{resolution} #{raw_path} #{final_path}`

`find #{tmp_path}/ -name "*.png" -delete`

`#{File.join(__dir__, 'change_desktop.sh')}`
