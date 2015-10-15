ActiveAdmin.register Series do

  menu priority: 14

  actions :all, except: [:destroy]

  filter :id
  filter :uri
  filter :slug
  filter :title
  filter :teaser
  filter :description

  controller do
    helper ApplicationHelper
    def scoped_collection
      Series.includes(:user)
    end
  end

  permit_params :title, :teaser, :description, :image,
                :retained_image, :remove_image

  index do
    selectable_column
    column :id
    column :title, sortable: :title do |series|
      truncate series.title
    end
    column :teaser, sortable: :teaser do |series|
      truncate series.teaser
    end
    column :description, sortable: :description do |series|
      truncate series.description
    end
    column :user
    actions do |venue|
      link_to "&#10148; Public".html_safe, public_url(venue), target: '_blank'
    end
  end

  show do |v|
    attributes_table do
      row :id
      row :uri
      row :slug
      row :user
      row :title
      row :teaser
      row :description do
        raw v.description
      end
      row :created_at
      row :updated_at
    end
    panel "Talks in this Series" do
      ul do
        v.talks.each do |talk|
          li do
            link_to talk.title, [:admin, talk]
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :teaser, input_html: { rows: 1 }
      f.input :description
      #f.input :user
      f.input :image, as: :dragonfly
    end
    f.actions
  end

end
