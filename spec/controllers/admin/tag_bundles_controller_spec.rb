require 'rails_helper'

RSpec.describe Admin::TagBundlesController, type: :controller do
  login_admin_user

  it 'responds nicely' do
    expect { 
      post :create, tag_bundle: {title_de: "spec title", group: "",
                                 promoted: "0", tag_list: "", title_en: "",
                                 description_en: "desc en",
                                 description_de: "desc de"}
    }.to change(TagBundle, :count).by(1)
    expect(TagBundle.last.description_de).to eq("desc de")
    expect(TagBundle.last.description_en).to eq("desc en")
  end

end
