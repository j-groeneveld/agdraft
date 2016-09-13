FactoryGirl.define do
  factory :worker do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    nationality { Faker::Address.country }
    sequence(:email){ |n| "worker-email-#{n}@example.com" }
    password "password"

    trait :with_job_categories do
      transient do
        job_categories nil
      end

      after(:create) do |worker, evaluator|
        worker.job_categories << (evaluator.job_categories || JobCategory.all.sample(10) || FactoryGirl.create_list(:job_category, 10))
      end
    end

    trait :with_skills do
      transient do
        skills nil
      end

      after(:create) do |worker, evaluator|
        worker.skills << (evaluator.skills || Skill.all.sample(10) || FactoryGirl.create_list(:skill, 10))
      end
    end

    trait :with_locations do
      transient do
        locations nil
      end

      after(:create) do |worker, evaluator|
        worker.locations << (evaluator.locations || Location.all.sample(3) || FactoryGirl.create_list(:location, 3))
      end
    end

    trait :with_unavailabilities do
      transient do
        start_date nil
        end_date nil
      end

      after(:create) do |worker, evaluator|
        # Create a singluar unavailability or create multiple
        if (start_date = evaluator.start_date) && (end_date = evaluator.end_date)
          FactoryGirl.create(:unavailability, worker: worker, start_date: start_date, end_date: end_date)
        else
          5.times do
            FactoryGirl.create(:unavailability, worker: worker)
          end
        end
      end
    end

    trait :with_previous_employers do
      after(:create) do |worker|
        5.times do
          FactoryGirl.create(:previous_employer, worker: worker)
        end
      end
    end

    trait :with_certificates do
      after(:create) do |worker|
        5.times do
          FactoryGirl.create(:certificate, worker: worker)
        end
      end
    end

    trait :with_educations do
      after(:create) do |worker|
        5.times do
          FactoryGirl.create(:education, worker: worker)
        end
      end
    end
  end
end