# coding: utf-8

require './lib/grabber'
require './lib/parser'
require './lib/saver'

if ARGV[0] =~ /(.+)({x})(.*)/
  uri = ARGV[0]
else
  raise 'Invalid uri.'
end
if (ARGV[1] =~ /\d/) == 0 &&
   (ARGV[2] =~ /\d/) == 0
  start = ARGV[1]
  stop = ARGV[2]
else
  raise "Start and stop should be numbers."
end
if ARGV[3] == 'xml' ||
   ARGV[3] == 'csv' ||
   ARGV[3] == 'all'
  save = ARGV[3]
else
  raise "Don't know how to save."
end

grabber = Grabber.new(uri, start, stop)
grabber.grabbing
parser = Parser.new
parser.save_result
saver = Saver.new
case save
  when 'xml'
    saver.save_xml
  when 'csv'
    saver.save_csv
  when 'all'
    saver.save_csv
    saver.save_xml
end
puts "Parsing took #{grabber.timer} sec."
puts "Saved #{grabber.count} pages."