# this will be serialized to the db and resurected by the main app
class Reprocess < Struct.new(:talk_id)
  def perform
  end
end

