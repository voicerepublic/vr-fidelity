ActiveAdmin.register User do

  menu priority: 10

  controller { helper ApplicationHelper }

  actions :all, except: [:destroy]

  action_item only: :show do
    link_to t('.tweetplan'), tweetplan_admin_user_path(user)
  end

  member_action :tweetplan, method: :get do
    @talks = resource.talks.prelive_or_live.ordered
  end

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
  scope :featured

  filter :id
  filter :uid
  filter :slug
  filter :firstname
  filter :lastname
  filter :email
  filter :featured_from
  filter :featured_until
  filter :paying
  filter :provider
  filter :timezone
  filter :credits
  filter :referrer
  filter :contact_email

  index do
    selectable_column
    column :id
    column :firstname
    column :lastname
    column :email
    column :featured_from, sortable: :featured_from do |talk|
      span style: 'white-space: pre' do
        l talk.featured_from, format: :iso unless talk.featured_from.nil?
      end
    end
    column :featured_until, sortable: :featured_until do |talk|
      span style: 'white-space: pre' do
        l talk.featured_until, format: :iso unless talk.featured_until.nil?
      end
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
      row :tag_list
      row :email
      row :featured_from
      row :featured_until
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
      row :penalty
      row :contact_email
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

    panel "User's Venues" do
      ul do
        user.venues.each do |venue|
          li do
            link_to venue.name, [:admin, venue]
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
      f.input :tag_list, input_html: { value: f.object.tag_list * ', ' }, label: "Tags"
      f.input :featured_from, as: :string,
              input_html: {
                class: 'picker',
                value: f.object.featured_from &&
                f.object.featured_from.strftime("%Y-%m-%d %H:%M:%S")
              }
      f.input :featured_until, as: :string,
              input_html: {
                class: 'picker',
                value: f.object.featured_until &&
                f.object.featured_until.strftime("%Y-%m-%d %H:%M:%S")
              }
      f.input :paying
      f.input :summary
      f.input :about
      f.input :penalty, hint: "1 = no penalty, 0 = max penalty (I know, it's confusing.) Applies to this user and all future series of this user."
      #f.input :avatar, as: :dragonfly
      f.input :image_alt
      f.input :contact_email
    end
    f.actions
  end

  csv do
    column :id
    column :slug
    column :firstname
    column :lastname
    column :email
    column :tag_list
    column :paying
    column :featured_from
    column :featured_until
    column :penalty
    column :credits
    column :sign_in_count
    column :last_request_at
    column :contact_email
  end

  permit_params :firstname, :lastname, :email, :avatar,
                :retained_avatar, :remove_avatar, :about,
                :paying, :featured_from, :featured_until,
                :tag_list, :penalty, :image_alt, :summary,
                :contact_email

end
