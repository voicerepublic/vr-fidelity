ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tag' do

  permit_params :name, :category

  filter :name
  filter :taggings_count, label: 'Occurences'
  filter :category

  config.sort_order = 'taggings_count_desc'

  index do
    selectable_column
    column :name
    column 'Occurences', :taggings_count
    column :category, sortable: :category do |tag|
      tag.category? ? status_tag("yes", :ok) : status_tag("no")
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
