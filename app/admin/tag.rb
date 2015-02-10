ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tag' do

  permit_params :name#, :category

  filter :name

  # TODO eager load taggings
  # TODO sort by taggings.count by default
  index do
    selectable_column
    column :name
    column :usages do |tag|
      tag.taggings.count
    end
    # TODO column :category
    actions
  end

  # TODO check what happens if we delete tags in BO
  # what happens to the taggings?

  # TODO NTH on show list entities tagged with

end
