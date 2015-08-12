FactoryGirl.define do

  sequence(:email) { |n| "admin#{n}@example.com" }

  factory :admin_user do
    email
    password 'supersecret'
  end

  factory :delayed_job, class: Delayed::Job do
    handler 'hello'
  end

  factory :setting do
  end

  factory :metric do
  end

  # TODO delete me, as soon as metrics are established
  factory :social_share do
  end

  factory :user do
  end

  factory :series do
  end

  sequence(:uri) { |n| "uri-#{n}" }

  # FIXME
  # factory :talk do
  #   uri
  #   series
  #   title 'some title'
  #   starts_at { Time.now }
  #   tag_list 'some, tags'
  # end

end
