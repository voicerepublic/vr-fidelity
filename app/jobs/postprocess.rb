# this will be serialized to the db and resurected by the main app
class Postprocess < Struct.new(:opts)
  def perform
  end
end
