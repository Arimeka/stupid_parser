# coding: utf-8

require 'builder'
require 'csv'

class Saver
  def initialize

    Dir.mkdir("result") unless Dir.exist? "result"
    File.truncate("save_errors.log", 0) if File.exist? "save_errors.log"

    @dir = "#{Time.now.strftime("%Y-%m-%d-%H-%M")}-#{rand 100}"
    Dir.mkdir("result/#{@dir}") unless Dir.exist? "result/#{@dir}"

    raise "Нечего обрабатывать" unless Dir.entries("tmp/parse").size > 2 
  end

  def list
    list = []
    Dir.foreach("tmp/parse") {|x| list << x unless File.directory? "tmp/parse/#{x}" }
    list
  end

  def each
    list = self.list
    list.each do |file|
      CSV.foreach("tmp/parse/#{file}") do |row|
        yield eval(row[0]) # Dirty trick to turn string to hash. Dangerous.
      end
    end
  end

  def save_csv
    Dir.foreach("tmp/parse") do |x| 
      FileUtils.cp "tmp/parse/#{x}", "result/#{@dir}/result.csv" unless File.directory? "tmp/parse/#{x}" 
    end    
  end

  def save_xml
    begin 
      File.open("result/#{@dir}/result.xml", "w") do |file|
        xml = Builder::XmlMarkup.new( :target => file, :indent => 2 )
        xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
        xml.root {
          self.each do |title|
            # Put your xml structure here.
          end
        }
      end
    rescue => ex
      File.open("save_errors.log", "a") do |file|
        file.puts "#{ex.class}: #{ex.message}"
        file.print ex.backtrace.join("\n")
        file.puts
        file.puts "======".center(60, '-')
      end
    end
  end
end