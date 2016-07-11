ActiveAdmin.register Message do

  menu parent: 'Admin'

  filter :content

  form do |f|
    f.inputs do
      f.input :content
    end
    f.actions
  end

end
