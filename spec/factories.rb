include ActionDispatch::TestProcess # For image upload helpers
FactoryGirl.define do
  factory :recommendation do
    
  end
  # For factory :job see spec/factories/job.rb
  # For factory :worker see spec/factories/worker.rb

  factory :notification do
    header { Faker::Lorem.words(4).join(" ") }
    description { Faker::Lorem.sentence }
  end

  factory :review do
    rating { rand(1..5) }
    feedback { Faker::Lorem.paragraph }
  end

  factory :job_worker do
    job
    worker

    trait :new do
      state :new
    end
    trait :shortlisted do
      state :shortlisted
    end
    trait :interested do
      state :interested
    end
    trait :declined do
      state :declined
    end
    trait :hired do
      state :hired
    end
    trait :not_interested do
      state :not_interested
    end
  end

  factory :payment_audit do
    farmer
    job
    action "MyString"
    message "MyString"
    success false
  end

  factory :certificate do
    title { Faker::Lorem.word }
    issue_date { rand(4.years.ago..1.year.ago) }
    worker
  end

  factory :education do
    school { Faker::University.name }
    start_date { rand(4.years.ago..1.year.ago) }
    end_date { rand(start_date..Time.now) }
    worker
  end

  factory :previous_employer do
    business_name { Faker::Company.name }
    contact_name { Faker::Name.name }
    contact_email { Faker::Internet.email }
    contact_phone { Faker::PhoneNumber.phone_number }

    job_title { Faker::Name.title }
    job_description { Faker::Lorem.paragraph }
    start_date { rand(4.years.ago..1.year.ago) }
    end_date { rand(start_date..Time.now) }

    worker
  end

  factory :unavailability do
    start_date { Time.now }
    end_date { rand(100.days).seconds.from_now }
    worker
  end

  factory :admin do
    sequence(:email){ |n| "admin-email-#{n}@example.com" }
    password "password"
  end

  factory :job_category do
    sequence(:title) { |n| "Category #{n}" }
  end

  factory :skill do
    sequence(:title) { |n| "Skill #{n}" }
  end

  factory :farmer do
    first_name {  Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email){ |n| "farmer-email-#{SecureRandom.hex(3)}@example.com" }
    password "password"

    trait :with_location do
      transient do
        location nil
      end

      after(:create) do |farmer, evaluator|
        farmer.location = evaluator.location || Location.all.try(:sample) || FactoryGirl.create(:location)
      end
    end

    trait :with_job do
      after(:create) do |farmer|
        FactoryGirl.create(:job, farmer: farmer)
      end
    end

    trait :with_notifications do
      after(:create) do |farmer|
        farmer.notifications << FactoryGirl.create_list(:notification, 5)
      end
    end

    trait :with_reviews do
      after(:create) do |farmer|
        job = FactoryGirl.create(:job, farmer: farmer, published: true)
        workers = FactoryGirl.create_list(:worker, 10)
        workers.each do |worker|
          job_worker = FactoryGirl.create(:job_worker, job_id: job.id, worker: worker)
          job_worker.hire!
          if rand(2) > 0
            FactoryGirl.create(:review, reviewer: farmer, reviewee: worker)
          else
            FactoryGirl.create(:review, reviewer: worker, reviewee: farmer)
          end
        end
      end
    end
  end

  factory :location do
    state { Faker::Address.state }
    sequence(:region){ |n| "region-#{n}" }
  end
end
