ActiveAdmin.register_page 'Statistics' do

  menu priority: 22

  # make it render partial app/views/admin/statistics/_index
  content do
    render 'index'
  end

end
