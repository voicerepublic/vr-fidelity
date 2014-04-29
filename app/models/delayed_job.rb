class Delayed::Job

  scope :failed, -> { where.not(failed_at: nil) }

  scope :audio, -> { where(queue: 'audio') }
  scope :trigger, -> { where(queue: 'trigger') }
  scope :mail, -> { where(queue: 'mail') }

  def display_handler
    case handler
    when /struct:ProcessOverride/
      "Talk.find(#{payload_object.talk_id}).process_override!"
    when /struct:Postprocess/
      "Talk.find(#{payload_object.talk_id}).postprocess!"
    when /struct:Reprocess/
      "Talk.find(#{payload_object.talk_id}).reprocess!"
    when /object:Delayed::PerformableMethod\nobject: !ruby\/ActiveRecord/
      return '(no payload_object)' unless payload_object
      clazz = handler.match(/ActiveRecord:(.+)/).to_a.last
      meth = payload_object.method_name
      oid = payload_object.id
      "#{clazz}.find(#{oid}).#{meth} # PM"
    when /object:Delayed::PerformableMailer/
      handler.match(/email: (.+)/)
    else '?'
    end
  end
  
end
