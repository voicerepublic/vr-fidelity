class Delayed::Job

  scope :queued, -> { where(attempts: 0) }
  
  scope :failed, -> { where.not(failed_at: nil) }

  scope :audio, -> { where(queue: 'audio') }
  scope :trigger, -> { where(queue: 'trigger') }
  scope :mail, -> { where(queue: 'mail') }
  scope :ci, -> { where(queue: 'ci') }

  def display_handler
    case handler
    when /struct:Assimilate/
      ref = payload_object.opts['ref']
      user = payload_object.opts['pusher']['name']
      "#{user}: #{ref}"
    when /struct:ProcessOverride/
      "Talk.find(#{payload_object.opts.try(:[], :id)}).process_override!"
    when /struct:Postprocess/
      "Talk.find(#{payload_object.opts.try(:[], :id)}).postprocess!"
    when /struct:Reprocess/
      "Talk.find(#{payload_object.opts.try(:[], :id)}).reprocess!"
    when /object:Delayed::PerformableMethod\nobject: !ruby\/ActiveRecord/
      begin
        clazz = handler.match(/ActiveRecord:(.+)/).to_a.last
        meth = payload_object.method_name
        oid = payload_object.id
        "#{clazz}.find(#{oid}).#{meth} # PM"
      rescue Exception => e
        return e.message
      end
    when /object:Delayed::PerformableMailer/
      handler.match(/email: (.+)/)
    else '?'
    end
  end

end

