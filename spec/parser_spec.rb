# coding: utf-8

require "./lib/parser.rb"
require 'rspec'

describe Parser do
  before(:all) do
    @parser = Parser.new
    @agent = Mechanize.new
    @parse = Nokogiri::HTML("
      <html>
        <head>
          <link rel=\"canonical\" href=\"http://www.animenewsnetwork.com/encyclopedia/anime.php?id=1\">
        </head>
        <body>
          <h1>Foobar</h1>
        </body>
      </html>
                            ")
    CSV.open("tmp/parser_test.csv", "w") do |csv|
      csv << ["First\nPage"]
      csv << ["Second\nPage"]
    end
  end

  it "should get file list" do    
    @parser.list.size.should > 0
  end

  it "file list shoud not contain '.' and '..'" do
    @parser.list.each do |file|
      file.should_not == "."
      file.should_not == ".."
    end
  end

  it "should can parse files" do
    @parser.each do |parse|
      parse.should be_an_instance_of Nokogiri::HTML::Document
    end
  end

  it "should get result" do
    @parser.get_result(@parse).should be_an_instance_of Hash
  end

  it "should save intermediate result" do
    @parser.stub(:get_result).and_return(@parser.get_result(@parse))
    @parser.save_result
    Dir.entries("tmp/parse").size.should > 2
  end

  after(:all) do
    Dir.foreach("tmp/parse") {|x| File.delete("tmp/parse/#{x}") unless File.directory? "tmp/parse/#{x}" } 
    File.delete("tmp/parser_test.csv")   
  end
end