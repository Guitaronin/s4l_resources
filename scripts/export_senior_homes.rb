require 'rubygems'
require 'mongomatic'
require 'fastercsv'

DOMAIN      = 'seniorhomes'
date_string = Time.now.strftime("%Y%m%d")
exports_dir = File.join(File.dirname(__FILE__), '..', 'exports')
OUTPUT_FILE = File.join(exports_dir, "#{DOMAIN}_#{date_string}.csv")

Mongomatic.db = Mongo::Connection.new.db('seniors_for_living')

class SeniorsFacility < Mongomatic::Base
  CARE_TYPES = {
    :assisted_living          => "Assisted Living",
    :independent_living       => "Independent Living",
    :retirement_community     => "Retirement Communities",
    :respite_care             => "Respite Care",
    :memory_care              => "Memory Care",
    :continuing_care          => "Continuing Care",
    :nursing_home             => "Nursing Homes",
    :hospice_care             => "Hospice Care",
    :care_home                => "Care Homes",
    :fiftyfive_plus_community => "55+ Communities",
    :adult_day_care           => "Adult Day Care",
    :senior_apartments        => "Senior Apartments",
    :veterans_benefits        => "Veterans Benefits"
  }

  def method_missing(method)
    if self['care_types'] && self['care_types'].any? {|ct| ct == CARE_TYPES[method]}
      true
    else
      false
    end
  end
  
  def name
    self['name']
  end
  
  def url
    self['url']
  end
  
  def address
    self['address']
  end
  
  def city
    self['city_st_zip'].split(',').first
  end
  
  def state
    self['city_st_zip'].scan(/,( [A-Z]{2} )\d/).first
  end
  
  def zip
    self['city_st_zip'].scan(/\d{5}$/).last
  end
  
  def care_types
    self['care_types'] ? self['care_types'].join(';;') : nil
  end
  
  def images
    self['images'] ? self['images'].map {|i| 'http://seniorhomes.com' + i}.join(';;') : nil
  end
  
  def description
    self['description'].sub(/__+/, '')
  end
  
end

headers = ["name", "url", "address", "city", "state", "zip", "care_types", "images", "description", 'assisted_living', 'independent_living', 'retirement_community', 'respite_care', 'memory_care', 'continuing_care', 'nursing_home', 'hospice_care', 'care_home', 'fiftyfive_plus_community', 'adult_day_care', 'senior_apartments', 'veterans_benefits']

sh_docs = SeniorsFacility.find({'domain' => DOMAIN})

FasterCSV.open(OUTPUT_FILE, "a") do |csv|
  csv << headers
  
  sh_docs.each do |doc|    
    row = []
    headers.each do |h| 
      row << doc.send(h)
    end
    
    csv << row
  end
end


# OLD version of export script. I redrafted above to make
# it more consistent with APFM. Will eventually abstract
# and refactor.

# class SeniorHomesExporter
#   MONGO   = Mongo::Connection.new('localhost').db('seniors_for_living')
#   CSV     = 'seniors_homes_com.csv'
#   HEADERS = ['URL', 'Facility', 'City', 'State', 'Zip', 'Care Types', 'Rates']
#   
#   def self.run
#     puts "starting..."
#     collection = MONGO['seniors_facilities'].find
#     total_docs = collection.count
#     
#     puts "adding headers"
#     add_data_to_csv(HEADERS)
#     
#     puts "processing #{total_docs} records"
#     cursor = 0
#     collection.each do |doc|
#       cursor += 1
#       puts "parsing/writing doc #{cursor} of #{total_docs}"
#       
#       row = {
#         :url           => doc['url'],
#         :name          => doc['name'],
#         :address       => doc['address']
#         :city          => doc['city_st_zip'].split(',').first,
#         :state         => doc['city_st_zip'].scan(/,( [A-Z]{2} )\d/).first,
#         :zip           => doc['city_st_zip'].scan(/\d{5}$/).first,
#         :care_types    => doc['care_types'] ? doc['care_types'].join('; ') : nil,
#         :rates         => doc['requirements'] ? doc['requirements'].join('; ') : nil
#       }
#       
#       output = [ row[:url], row[:facility_name], row[:city], row[:state], row[:zip], row[:care_types], row[:rates] ]
#       
#       add_data_to_csv(output)
#       
#     end
#   end
#   
#   def self.add_data_to_csv(data)
#     FasterCSV.open(CSV, "a") do |csv|
#       csv << data
#     end
#   end
#   
# end
# 
# SeniorHomesExporter.run