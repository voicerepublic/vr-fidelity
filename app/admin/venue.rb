ActiveAdmin.register Venue do

  menu priority: 12

  actions :all, except: [:destroy]

  filter :id
  filter :name
  filter :slug
  filter :lat
  filter :long

  controller do
    def scoped_collection
      Venue.includes(:talks)
    end
  end

  permit_params :name, :lat, :long, :options, flags: []

  index do
    selectable_column
    column :id
    column :name
    column :lat
    column :long
    column :user
    actions
  end

  show do |v|
    attributes_table do
      row :id
      row :name
      row :lat
      row :long
      row :user
      row :flags do
        badges = Venue::FLAGS.map do |f|
          state = v.flags.include?(f) ? ' active' : ''
          content_tag :span, f.humanize,
                      class: "badge" + state
        end
        raw badges * ' '
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :name
      # f.input :user
      # f.input :slug
      f.input :lat
      f.input :long
      f.input :options, input_html: { rows: 6 },
              hint: "Boolean flags will be set/overriden by the checkboxes below."
      # FIXME selected options are not properly checkmarked
      f.input :flags, as: :check_boxes, collection: Series::FLAGS,
              member_label: :humanize,
              hint: "Please consult the event handbook for details on these options."
    end
    f.actions
  end

end
