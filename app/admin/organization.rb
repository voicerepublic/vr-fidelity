ActiveAdmin.register Organization do

  menu parent: 'Admin'

  actions :all, except: [:destroy]

  permit_params %w( name
                    slug
                    image_alt
                    logo_alt
                    description
                    website
                    penalty
                    paying
                    featured_from
                    featured_until
                    promoted ).map(&:to_sym)

  form do |f|
    f.inputs do
      f.input :name
      f.input :slug
      #f.input :credits
      #f.input :image_uid
      #f.input :image_name
      f.input :image_alt
      #f.input :logo_uid
      #f.input :logo_name
      f.input :logo_alt
      f.input :website
      #f.input :penalty
      f.input :featured_from, as: :string
      f.input :featured_until, as: :string

      f.input :description
    end
    f.actions
  end

end
