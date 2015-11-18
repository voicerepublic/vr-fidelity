ActiveAdmin.register Page do

  menu priority: 10

  permit_params :slug, :template, :title_en, :content_en, :title_de, :content_de

  filter :slug
  filter :title_en
  filter :content_en
  filter :title_de
  filter :content_de

  Page::TEMPLATES.each do |template|
    scope template
  end

  form do |f|
    f.inputs do
      f.input :slug if f.object.persisted?
      f.input :template, collection: Page::TEMPLATES
    end
    Page::LANGUAGES.each do |locale, language|
      f.inputs language do
        f.input "title_#{locale}"
        f.input "content_#{locale}"
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :slug
      row :template
      row :title_en
      row :content_en_as_html do |page|
        page.content_en_as_html.html_safe
      end
      row :title_de
      row :content_de_as_html do |page|
        page.content_de_as_html.html_safe
      end
    end
    active_admin_comments
  end

end
