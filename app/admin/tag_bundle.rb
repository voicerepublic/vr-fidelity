ActiveAdmin.register TagBundle do

  menu priority: 21

  TagBundle::GROUPS.each do |group|
    scope group.to_sym
  end

  scope :standalone

  filter :title_en
  filter :title_de
  filter :group
  filter :promoted

  permit_params :group, :promoted, :tag_list, :icon,
                :title_en, :title_de,
                :description_en, :description_de


  index do
    selectable_column
    column :title_en
    column :title_de
    column :group
    column :promoted
    column :tag_list
    actions
  end

  form do |f|
    f.inputs do
      f.input :group, collection: TagBundle::GROUPS
      f.input :icon, collection: ["arts", "tech", "media", "business",
      "science", "politics"]
      f.input :promoted, label: 'Promoted (Promoted categories are listed on the home page.)'
      f.input :tag_list, input_html: { value: f.object.tag_list * ', ' }, label: "Tags"
      f.input :title_en
      f.input :description_en, hint: 'Descriptions are customer facing texts. So choose you language wisely. ;)'
      f.input :title_de
      f.input :description_de
    end
    f.actions
  end

  # after update redirect to index
  controller do
    def update
      update! do |format|
        format.html { redirect_to admin_tag_bundles_path }
      end
    end
  end

  member_action :download_report, method: :get do
    talks = Talk.tagged_with(TagBundle.find(params[:id]).tags, any: true)

    csv = CSV.generate( encoding: 'Windows-1251', force_quotes: true ) do |csv|
      csv << [ "play_count", "title", "speaker", "link", "series", "user" ]

      talks.each do |talk|
        csv << [ talk.play_count, talk.title, talk.speakers, "https://voicerepublic.com/talks/#{talk.slug}", talk.series.title, talk.user.full_name ]
      end
    end
    # send file to user
    send_data csv.encode('UTF-8'), type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=tag_bundle_report.csv"
  end

  action_item :download_report, only: :show do
    link_to 'Download Report', download_report_admin_tag_bundle_path(tag_bundle), method: 'get'
  end

end
