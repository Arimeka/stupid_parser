# coding: utf-8

require "./lib/saver.rb"
require 'rspec'

describe Saver do
  before(:all) do
    CSV.open("tmp/parse/saver_test.csv", "w") do |csv|
      csv << [{:name=>"Angel Links", :ann_id=>"1", :type=>"TV"}]
    end
    @saver = Saver.new    
  end

  it "should open parser file" do    
    @saver.each do |page|
      page.should be_an_instance_of Hash
      #pending "Didn't work"
    end
  end

  after(:all) do
    File.delete("tmp/parse/saver_test.csv")    
  end
end