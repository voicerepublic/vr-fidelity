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

  filter :name
  filter :slug
  filter :description
  filter :website

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

  index do
    selectable_column
    column :name
    column :slug
    column :featured_from
    column :featured_until
    actions
  end

  show do
    attributes_table do
      row :name
      row :slug
      row :image_alt
      row :logo_alt
      row :website
      row :featured_from
      row :featured_until
      row :description_as_html
    end
    panel 'Devices' do
      table do
        tr do
          th 'Name'
          th 'Type'
          th 'Subtype'
          th 'Identifier'
          th 'State'
          th 'Paired At'
        end
        organization.devices.each do |device|
          tr do
            td link_to(device.name, [:admin, device])
            td device.type
            td device.subtype
            td device.identifier
            td device.state
            td device.paired_at
          end
        end
      end
    end
    panel 'Members' do
      table do
        tr do
          th 'Name'
        end
        organization.users.each do |user|
          td link_to(user.full_name, [:admin, user])
        end
      end
    end
  end
end
