ActiveAdmin.register Setting do

  menu parent: "Admin"

  permit_params %w( key value ).map(&:to_sym)

end
