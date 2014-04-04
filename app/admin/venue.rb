ActiveAdmin.register Venue do
  permit_params :id, :title, :teaser, :description, :user, :options

  index do
    column :id
    column :title, sortable: :title do |venue|
      truncate venue.title
    end
    column :teaser, sortable: :teaser do |venue|
      truncate venue.teaser
    end
    column :description, sortable: :description do |venue|
      truncate venue.description
    end
    column :user
    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :teaser, input_html: { rows: 1 }
      f.input :description
      #f.input :user
      f.input :options, input_html: { rows: 6 },
      :hint => "<b>These options are supported:</b><br/>
                no_auto_postprocessing: true/false<br/>
                no_auto_end_talk: true/false<br/>
                no_email: true/false<br/>
                suppress_chat: true/false<br/>
                <b>Example configuration:</b>
                <pre>
                no_auto_postprocessing: true
                no_auto_end_talk: true
                no_email: true
                suppress_chat: true
                </pre>".html_safe
      f.input :image, as: :dragonfly
    end
    f.actions
  end

  permit_params :title, :teaser, :description, :options, :image,
                :retained_image, :remove_image
 
end
