ActiveAdmin.register Membership do

  menu parent: 'Admin'

  permit_params %w( organization_id
                    user_id ).map(&:to_sym)

  form do |f|
    f.inputs do
      f.input :organization, collection: Organization.ordered
      f.input :user, collection: User.ordered
    end
    f.actions
  end

end
