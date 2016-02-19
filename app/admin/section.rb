# TODO introduce a mode, which can be automatic or manual
# by default mode is set to automatic, then content is overwritten with content from sections.yml
# on editing mode is set to manual
ActiveAdmin.register Section do

  menu priority: 22

  permit_params :content

  actions :index, :edit, :update, :destroy

  index do
    # selectable_column
    column :locale
    column :key
    column :content # TODO truncate content
    column :updated_at
    actions
  end

  filter :locale, as: :select, collection: Section.locales
  filter :key
  filter :content
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :locale, input_html: { readonly: true }
      f.input :key, input_html: { readonly: true }
      f.input :content
    end
    f.actions
  end

end
