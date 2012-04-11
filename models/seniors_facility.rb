class SeniorsFacility < Mongomatic::Base
  def self.load(data)
    data['created_at'] = Time.now
    data.delete(:query)
    insert(data)
  end
end