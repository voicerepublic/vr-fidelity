ActiveAdmin.register Section do

  menu priority: 22

  permit_params :content

  #actions :all, except: [:show, :new, :create, :destroy]
  actions :index, :edit, :update

  index do
    # selectable_column
    column :locale
    column :key
    column :content
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
