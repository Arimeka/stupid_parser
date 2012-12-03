# coding: utf-8

require "./lib/grabber.rb"
require 'rspec'

describe Grabber do 
  before(:all) do
    @graber = Grabber.new('http://www.example.com/?p={x}',0,1100) 
    @agent = Mechanize.new 
  end

  it "should delimit pages by 500" do
    @graber.delimit.should == 3
  end

  it "should recive 1 if pages < 500" do
    graber = Grabber.new('http://www.example.com/?p={x}',0,100)
    graber.delimit.should == 1
  end

  it "should iterate all pages" do
    graber = Grabber.new('http://www.example.com/?p={x}',0,1)
    m = []
    graber.each do |x|
      m << x 
    end
    m.should == ['http://www.example.com/?p=0', 'http://www.example.com/?p=1']
  end

  it "should grab page" do
    page = mock(Mechanize, title: "Example Page", body: "This is a body of page\nAnother string\n")
    uri = 'http://www.example.com/{x}'
    Mechanize.any_instance.stub(:get).and_return(page)
    @graber.stub(:save_poster).and_return("foobar")
    @graber.grabe(uri).should == "This is a body of page\nAnother string\n"
  end

  it "should save results" do    
    graber = Grabber.new('http://www.example.com/?p={x}',0,1)
    graber.stub(:grabe).and_return("This is \n the \n body of page.\n")
    graber.grabbing

    Dir.entries("tmp").size.should > 2
    #File.open("tmp/#{Dir.entries("tmp")[2]}", "r") { |file| file.read.should == "\"This is \n the \n body of page.\n\"\n\"This is \n the \n body of page.\n\"\n"}
  end

  describe "change proxy" do
    before(:each) do            
      @graber.send(:change_proxy, @agent)
      #file = mock(File, readlines: ["127.0.0.1:3000\n", "127.0.0.2:2000\n"]) 
      #File.any_instance.stub(:open).and_yield(@file)
      #File.any_instance.stub(:open).and_return(file)
      #File.any_instance.stub(:readlines).and_return(file.readlines)
    end
    
    it "should get valid proxy addres" do
      #@agent.proxy_addr.should == "198.101.240.130"
      pending "I don't know how"
    end

    it "should get valid proxy port" do
      #@agent.proxy_port.should == 3128
      pending "I don't know how"
    end
  end
end