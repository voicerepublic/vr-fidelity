ActiveAdmin.register User do

  index do
    column :id
    column :firstname
    column :lastname
    column :email
    column 'Venues' do |user|
      user.venues.count
    end
    # column 'Talk Count' do |user|
    #   # TODO link_to user.talks.count, admin_talks # by user
    #   user.talks.count
    # end
    column :sign_in_count
    column :last_sign_in_at do |user|
      span style: 'white-space: pre'  do
        user.last_sign_in_at ?  l(user.last_sign_in_at, format: :iso) : ""
      end
    end
    column :created_at do |user|
      span style: 'white-space: pre'  do
        l user.created_at, format: :iso
      end
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :firstname
      f.input :lastname
      f.input :email
    end
    f.actions
  end

  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

end
