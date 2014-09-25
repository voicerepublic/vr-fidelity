# this will be serialized to the db and resurected by the main app
class GenerateFlyer < Struct.new(:opts)
  def perform
  end
end
