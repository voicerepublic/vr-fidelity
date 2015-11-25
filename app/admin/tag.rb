ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tag' do

  menu priority: 20

  permit_params :name, :promoted

  filter :name
  filter :taggings_count, label: 'Occurences'
  filter :promoted

  config.sort_order = 'taggings_count_desc'

  index do
    selectable_column
    column :name
    column 'Occurences', :taggings_count
    column :promoted, sortable: :promoted do |tag|
      tag.promoted? ? status_tag("yes", :ok) : status_tag("no")
    end
    actions
  end

  # after update redirect to index
  controller do
    def update
      update! do |format|
        format.html { redirect_to admin_tags_path }
      end
    end
  end

  # TODO NTH on show list entities tagged with

end
