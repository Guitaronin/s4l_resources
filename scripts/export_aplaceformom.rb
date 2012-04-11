require 'rubygems'
require 'mongomatic'
require 'fastercsv'
require 'pp'

date_string = Time.now.strftime("%Y%m%d")
output_file = "aplaceformom_#{date_string}.csv"

Mongomatic.db = Mongo::Connection.new.db('seniors_for_living')

class SeniorsFacility < Mongomatic::Base

  def method_missing(method)
    self[method.to_s]
  end
  
  def amenities
    self['amenities'] ? self['amenities'].join(';;') : nil
  end
  
  def alzheimers_care
    !! (self['care_types'] =~ /alzheimer's care/i)
  end
  
  def assisted_living
    !! (self['care_types'] =~ /assisted living/i)
  end
  
  def home_care
    !! (self['care_types'] =~ /home care/i)
  end
  
  def nursing_home
    !! (self['care_types'] =~ /nursing home/i)
  end
  
  def residential_care_home
    !! (self['care_types'] =~ /residential care home/i)
  end
  
  def retirement_community
    !! (self['care_types'] =~ /retirement community/i)
  end
end

headers = ["name",  "provider_id",  "url",  "city", "state", "care_types", "amenities", "image", "description", "alzheimers_care", "assisted_living", "home_care", "nursing_home", "residential_care_home", "retirement_community"]

FasterCSV.open(output_file, "a") do |csv|
  csv << headers
end

apfm_docs = SeniorsFacility.find({'domain' => 'aplaceformom'})

FasterCSV.open(output_file, "a") do |csv|
  apfm_docs.each do |doc|    
    row = []
    headers.each do |h| 
      row << doc.send(h)
    end
    
    csv << row
  end
end
