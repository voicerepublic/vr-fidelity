ActiveAdmin.register TagBundle do

  menu priority: 21

  TagBundle::GROUPS.each do |group|
    scope group.to_sym
  end

  scope :standalone

  filter :title_en
  filter :title_de
  filter :group
  filter :promoted

  permit_params :title_en, :title_de,
                :content_en, :content_de,
                :group, :promoted, :tag_list

  index do
    selectable_column
    column :title_en
    column :title_de
    column :group
    column :promoted
    column :tag_list
    actions
  end

  form do |f|
    f.inputs do
      f.input :group, collection: TagBundle::GROUPS
      f.input :promoted, label: 'Promoted (Promoted categories are listed on the home page.)'
      f.input :tag_list, input_html: { value: f.object.tag_list * ', ' }, label: "Tags"
      f.input :title_en
      f.input :description_en, hint: 'Descriptions are customer facing texts. So choose you language wisely. ;)'
      f.input :title_de
      f.input :description_de
    end
    f.actions
  end

  # after update redirect to index
  controller do
    def update
      update! do |format|
        format.html { redirect_to admin_tag_bundles_path }
      end
    end
  end

end
