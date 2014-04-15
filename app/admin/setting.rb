ActiveAdmin.register Setting do
  permit_params %w( key value ).map(&:to_sym)
end
