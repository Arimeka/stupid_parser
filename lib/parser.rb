# coding: utf-8

require 'nokogiri'
require 'csv'

class Parser
  def initialize

    Dir.mkdir("tmp/parse") unless Dir.exist? "tmp/parse"
    Dir.foreach("tmp/parse") {|x| File.delete("tmp/parse/#{x}") unless File.directory? "tmp/parse/#{x}" }
    File.truncate("parse_errors.log", 0) if File.exist? "parse_errors.log"

    raise "Nothing to process." unless Dir.entries("tmp").size > 2 
  end

  def list
    list = []
    Dir.foreach("tmp") {|x| list << x unless File.directory? "tmp/#{x}" }
    list
  end

  def each
    list = self.list
    list.each do |file|
      CSV.foreach("tmp/#{file}") do |row|
        yield Nokogiri::HTML(row[0])        
      end
    end
  end

  def save_result
    begin
      CSV.open("tmp/parse/#{Time.now.strftime("%Y%jT%H%MZ")}-#{rand 100}.csv", "w") do |csv|
        each do |doc|
          csv << [get_result(doc)]
        end
      end
    rescue => ex
      File.open("parse_errors.log", "a") do |file|
        file.puts "#{ex.class}: #{ex.message}"
        file.print ex.backtrace.join("\n")
        file.puts
        file.puts "======".center(60, '-')
      end
    end
  end

  def get_result(doc)
    # Put your parsing here
    # Result in hash
  end
end