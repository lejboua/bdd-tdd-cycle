FactoryGirl.define do
  factory :movie do
    title "Default Title"
    rating "PG"
    # TODO: it hasn't any director; what's the default behaviour?
    director "Default Director"
    release_date { 1.day.ago }
  end
end
