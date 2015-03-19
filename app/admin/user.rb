ActiveAdmin.register User do

  actions :all, except: [:destroy]

  controller do
    def scoped_collection
      User.nonguests
    end
  end

  scope :paying

  filter :id
  filter :uid
  filter :slug
  filter :firstname
  filter :lastname
  filter :email
  filter :provider
  filter :timezone
  filter :conference
  filter :credits

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
    column :credits
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
      row :credits
      row :summary do
        raw user.summary
      end
      row :about do
        raw user.about
      end
    end

    if user.purchases_count > 0
      panel "Payment History" do
        table do
          tr do
            th 'Purchased At'
            th 'Quantity'
            th 'Price'
          end
          user.purchases.each do |purchase|
            tr do
              td purchase.created_at
              td purchase.quantity
              td number_to_currency(purchase.amount/100, unit: 'EUR')
            end
          end
        end
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
      f.input :summary
      f.input :about
      f.input :avatar, as: :dragonfly
    end
    f.actions
  end

  permit_params :firstname, :lastname, :email, :avatar,
                :retained_avatar, :remove_avatar, :about

end
