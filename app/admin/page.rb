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

end
