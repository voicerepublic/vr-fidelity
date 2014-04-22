# this will be serialized to the db and resurected by the main app
class ProcessOverride < Struct.new(:talk_id)
  def perform
  end
end
