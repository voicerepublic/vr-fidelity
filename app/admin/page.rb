ActiveAdmin.register Page do

  menu priority: 10

  permit_params :slug, :type, :initial_title, sections_attributes: [ :id, :content ]

  filter :slug
  filter :content

  Page::TYPES.each do |type|
    scope type.to_sym
  end

  index do
    selectable_column
    column :id
    column :type
    column :slug
    column 'Title (English)', :title
    # TODO display green and red dots for nonempty and empty fields
    actions
  end

  form do |f|
    f.inputs 'Metadata' do
      if f.object.persisted?
        f.input :type, input_html: {disabled: true}
        f.input :slug
      else
        f.input :type, collection: Page::TYPES
        f.input :initial_title
      end
    end
    if f.object.persisted?
      f.inputs "Content" do
        f.semantic_fields_for :sections do |sf|
          sf.input :content, sf.object.input_options
        end
      end
    end
    f.actions
  end

  controller do
    # after create redirect to edit
    def create
      create! do |format|
        format.html { redirect_to edit_admin_page_path(resource) }
      end
    end
    # after update redirect to index
    def update
      update! do |format|
        format.html { redirect_to admin_pages_path }
      end
    end
  end

  # the sidebar displays the english markdown content
  sidebar :help, only: :edit do
    page = Page.find_by(slug: 'markdown')
    page && page.section('main')
  end

end
