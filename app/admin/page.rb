ActiveAdmin.register Page do

  menu priority: 10

  permit_params :slug, :template, :title_en, :content_en, :title_de, :content_de

  filter :slug
  filter :template, collection: Page::TEMPLATES
  filter :title_en
  filter :content_en
  filter :title_de
  filter :content_de

  form do |f|
    f.inputs do
      f.input :slug, placeholder: 'If left blank will be derived from title (en).'
      f.input :template, collection: Page::TEMPLATES
    end
    f.inputs 'English' do
      f.input :title_en
      f.input :content_en
    end
    f.inputs 'Deutsch' do
      f.input :title_de
      f.input :content_de
    end
    f.actions
  end

end
