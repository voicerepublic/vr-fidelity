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

  factory :social_share do
  end

  factory :user do
  end

  factory :venue do
  end

end
