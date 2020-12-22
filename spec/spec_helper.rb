begin
  require "pry-byebug"
rescue LoadError
end

begin
  require "pry-nav"
rescue LoadError
end

require "pp"

#---

require_relative "../support/current_bundle"

SuperDiff::CurrentBundle.instance.assert_appraisal!

#---

begin
  require "active_record"

  active_record_available = true

  ActiveRecord::Base.establish_connection(
    adapter: "sqlite3",
    database: ":memory:",
  )
rescue LoadError
  active_record_available = false
end

Dir.glob(File.expand_path("support/**/*.rb", __dir__)).
  sort.
  reject do |file|
    file.include?("/models/active_record/") && !active_record_available
  end.
  each do |file|
    require file
  end

RSpec.configure do |config|
  config.include(SuperDiff::IntegrationTests, type: :integration)

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.max_formatted_output_length = nil
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if !["true", "1"].include?(ENV["CI"])
    config.default_formatter = "documentation"
  end

  config.filter_run_excluding active_record: true unless active_record_available

  config.order = :random
  Kernel.srand config.seed

  if ENV["CI"] == "true"
    config.color_mode = :on
  end
end

if active_record_available
  require "super_diff/rspec-rails"
else
  require "super_diff/rspec"
end
