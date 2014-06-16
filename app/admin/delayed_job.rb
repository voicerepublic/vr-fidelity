# the require is needed since we're monkey patching delayed job
# with ap/model/delayed_job, but since it undermines rails' autoload
# we'll have to restart the server after editing ap/model/delayed_job
require Rails.root.join 'app', 'models', 'delayed_job'

ActiveAdmin.register Delayed::Job, as: "Job" do
  actions :all, :except => [:edit, :new]

  show do |job|
    attributes_table do
      row :created_at
      row :failed_at
      row :run_at
      row :attempts
      row :queue
      row :locked_at
      row :locked_by
      row :last_error do
        pre do
          job.last_error
        end
      end
      row :handler do
        pre do
          job.handler
        end
      end
    end
    active_admin_comments
  end

  index do
    selectable_column
    column :created_at
    column :failed_at
    column :run_at
    column :attempts
    column :queue
    column :handler do |job|
      job.display_handler
    end
    column :locked_at
    column :locked_by
    column :last_error do |job|
      job.last_error.try(:split, "\n").try(:first)
    end

    actions
  end

  scope :all
  scope :failed
  scope :audio
  scope :trigger
  scope :mail
  scope :ci

end
