class Delayed::Job

  scope :queued, -> { where(attempts: 0) }

  scope :failed, -> { where.not(failed_at: nil) }

  scope :audio, -> { where(queue: 'audio') }
  scope :trigger, -> { where(queue: 'trigger') }
  scope :mail, -> { where(queue: 'mail') }

  def display_handler
    case handler

    when /struct:DestroyTalk/
      "Talk.find(#{payload_object.opts.try(:[], :id)}).destroy!"

    when /struct:ArchiveJob/
      "Talk.find(#{payload_object.opts.try(:[], :id)}).archive_from_dump!"

    when /struct:ProcessOverride/
      "Talk.find(#{payload_object.opts.try(:[], :id)}).process_override!"

    # when /struct:Postprocess/
    #   "Talk.find(#{payload_object.opts.try(:[], :id)}).postprocess!"

    # when /struct:Reprocess/
    #   "Talk.find(#{payload_object.opts.try(:[], :id)}).reprocess!"

    when /struct:EndTalk/
      "Talk.find(#{payload_object.opts.try(:[], :id)}).end_talk!"

    when /struct:ProcessSlides/
      "Talk.find(#{payload_object.opts.try(:[], :id)}).process_slides!"

    when /object:Delayed::PerformableMethod/
      begin
        clazz = handler.match(/object: !ruby\/object:(.+)/).to_a.last
        meth = payload_object.method_name
        oid = payload_object.id
        "#{clazz}.find(#{oid}).#{meth}"
      rescue Exception => e
        return e.message
      end

    when /object:Delayed::PerformableMailer/
      handler.match(/email: (.+)/)

    else '?'

    end
  end

end
