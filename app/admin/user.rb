ActiveAdmin.register User do

  scope :nonguests
  scope :guests

  index do
    selectable_column
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
        l user.last_sign_in_at, format: :iso unless user.last_sign_in_at.nil?
      end
    end
    column :created_at do |user|
      span style: 'white-space: pre'  do
        l user.created_at, format: :iso
      end
    end
    actions
  end

  show do |user|
    attributes_table do
      row :id
      row :slug
      row :firstname
      row :lastname
      row :email
      row :timezone
      row :summary do
        raw user.summary
      end
      row :about do
        raw user.about
      end
    end
    panel "User's Venues" do
      ul do
        user.venues.each do |venue|
          li do
            link_to venue.title, [:admin, venue]
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :firstname
      f.input :lastname
      f.input :email
      f.input :about
      f.input :avatar, as: :dragonfly
    end
    f.actions
  end

  permit_params :firstname, :lastname, :email, :avatar,
                :retained_avatar, :remove_avatar, :about

end
