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
    column :user
    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :teaser # FIXME teaser should be a string rather than a text
      f.input :description
      f.input :user
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
