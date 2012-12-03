# coding: utf-8

require 'mechanize'
require 'csv'

class Grabber
  def initialize(uri,start,stop)
    @uri, @start, @stop = uri, start.to_i, stop.to_i

    Dir.mkdir("tmp") unless Dir.exist? "tmp"
    Dir.foreach("tmp") {|x| File.delete("tmp/#{x}") unless File.directory? "tmp/#{x}" }
    File.truncate("grabe_errors.log", 0) if File.exist? "grabe_errors.log"
    @n, @d = 0, 0

    @start_time = Time.now
    @count = 0

    @result = []

    raise "Start should be smaller than end." if @start > @stop
  end

  def delimit
    (@stop / 500.0).ceil
  end 

  def timer
    Time.now - @start_time
  end

  def count
    @count
  end    

  def each
    @start.upto(@stop) do |x|
      yield "#{@uri[/(.+)({x})(.*)/,1]}#{x}#{@uri[/(.+)({x})(.*)/,3]}"
    end
  end 

  def grabe(uri)
    agent = Mechanize.new
    change_proxy(agent)
    agent.read_timeout = 10
    agent.open_timeout = 10
    begin
      agent.get(uri).body
    rescue Timeout::Error, Net::HTTP::Persistent::Error, Net::HTTPServiceUnavailable
      sleep(1)
      grabe(uri)
    end   
  end

  def save_result(pages)
    CSV.open("tmp/#{Time.now.strftime("%Y%jT%H%MZ")}-#{rand 100}.csv", "w") do |csv|
      pages.each do |page|
        begin 
          csv << [page.value]
          @count += 1
        rescue => ex
          File.open("grabe_errors.log", "a") do |file|
            file.puts pages.index page
            file.puts "#{ex.class}: #{ex.message}"
            file.print ex.backtrace.join("\n")
            file.puts
            file.puts "======".center(60, '-')
          end
        end
      end
    end
    @result = []
  end

  def grabbing
    @d = delimit
    self.each do |page|
      sleep(2) if Thread.list.size > 40
      save_result @result if @result.size > (@stop/@d.to_f).ceil
      @result << Thread.new do
        grabe page
      end
    end
    save_result @result
  end

  def change_proxy(agent)
    proxy = File.open("proxy_list.txt", "r") { |file| file.readlines[@n] }
    if proxy
      agent.set_proxy(proxy.split(':')[0], proxy.split(':')[1].to_i) 
      @n += 1
    else
      @n = 0
      change_proxy(agent)
    end
  end    
end