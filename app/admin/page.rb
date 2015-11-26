ActiveAdmin.register Page do

  menu priority: 10

  permit_params :slug, :type, title: Page::LANGUAGES.keys,
                content: (Page::LANGUAGES.keys.inject({}) { |r, l|
                            r.merge l => Page::PERMITTED_FIELDS })

  filter :slug

  Page::TYPES.each do |type|
    scope type
  end

  index do
    selectable_column
    column :id
    column :type
    column :slug
    column :title_en
    # TODO display green and red dots for nonempty and empty fields
    actions
  end

  form do |f|
    f.inputs 'Metadata ' + f.object.type do
      if f.object.persisted?
        f.input :slug
      else
        f.input :type, collection: Page::TYPES
      end
      Page::LANGUAGES.each do |locale, language|
        f.input "title-#{locale}", as: :serialized_string
      end
    end
    if f.object.persisted?
      Page::LANGUAGES.each do |locale, language|
        f.inputs language do
          f.object.content_fields.each do |field, type|
            f.input "content-#{locale}-#{field}", as: "serialized_#{type}"
          end
        end
      end
    end
    f.actions
  end

  show title: :slug do
    attributes_table do
      row :slug
      row :type
      row :title_en
      #row :content_en_as_html do |page|
      #  page.content_en_as_html.html_safe
      #end
      #row :title_de
      #row :content_de_as_html do |page|
      #  page.content_de_as_html.html_safe
      #end
    end
    active_admin_comments
  end

  # after update redirect to index
  controller do
    def create
      create! do |format|
        format.html { redirect_to edit_admin_page_path(resource) }
      end
    end
  end

end
