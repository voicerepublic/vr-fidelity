ActiveAdmin.register User do

  menu priority: 10

  controller { helper ApplicationHelper }

  actions :all, except: [:destroy]

  action_item only: :show do
    link_to t('.grant'), credits_admin_user_path(user)
  end

  member_action :credits, method: [:get, :post] do
    if params[:grant] && qty = params[:grant][:quantity]
      transaction = Transaction.create(source: current_admin_user,
                                       details: params[:grant] )
      transaction.delay(queue: 'trigger').process!
      redirect_to [:admin, resource], notice: t('.granted_x_credits', count: qty.to_i)
    end
  end

  scope :paying

  User::FORMATS.each do |key, value|
    scope value, key
  end

  filter :id
  filter :uid
  filter :slug
  filter :firstname
  filter :lastname
  filter :email
  # filter :format, as: :select, collection: User::FORMATS.invert
  filter :paying
  filter :provider
  filter :timezone
  filter :conference
  filter :credits
  filter :referrer

  index do
    selectable_column
    column :id
    column :firstname
    column :lastname
    column :email
    column :format do |user|
      User::FORMATS[user.format.try(:to_sym)]
    end
    column :paying
    column 'Series' do |user|
      user.series.count
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
    actions do |user|
      link_to "&#10148; Public".html_safe, public_url(user), target: '_blank'
    end
  end

  show do |user|
    attributes_table do
      row :id
      row :slug
      row :firstname
      row :lastname
      row :email
      row :format do
        User::FORMATS[user.format.try(:to_sym)]
      end
      row :paying
      row :timezone
      row :credits
      row :summary do
        raw user.summary
      end
      row :about do
        raw user.about
      end
      row :referrer
    end

    panel "Transaction History" do
      render partial: 'transaction_history'
    end

    panel "User's Series" do
      ul do
        user.series.each do |series|
          li do
            link_to series.title, [:admin, series]
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
      f.input :format, as: :select, collection: User::FORMATS.invert
      f.input :paying
      f.input :summary
      f.input :about
      f.input :avatar, as: :dragonfly
    end
    f.actions
  end

  permit_params :firstname, :lastname, :email, :avatar,
                :retained_avatar, :remove_avatar, :about,
                :paying, :format

end
