ActiveAdmin.register Venue do

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
    column :featured_from, sortable: :featured_from do |venue|
      l venue.featured_from, format: :iso unless venue.featured_from.nil?
    end
    column :user
    actions
  end

  form do |f|
    f.inputs do
      f.input :featured_from # FIXME use a proper datepicker
      f.input :title
      f.input :teaser # FIXME teaser should be a string rather than a text
      f.input :description
      f.input :user # FIXME use a proper name
    end
    f.actions
  end
  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  
end
