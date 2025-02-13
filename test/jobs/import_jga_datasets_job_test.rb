require "test_helper"

class ImportJGADatasetsJobTest < ActiveJob::TestCase
  include TestHelper

  setup do
    reset_data
  end

  test "perform" do
    FactoryBot.create :user, username: "alice"

    ImportJGADatasetsJob.perform_now dir: "test/fixtures/files/jga_datasets", cleanup: false

    user = User.find("alice")

    assert_equal 2, user.jga_datasets.size

    first, second = user.jga_datasets.map { JSON.parse(it, symbolize_names: true) }

    assert_equal "JGAD000001",           first[:id]
    assert_equal "2025-01-01T00:00:00Z", first[:expires_at]

    assert_equal "JGAD000002",           second[:id]
    assert_equal "2025-01-02T00:00:00Z", second[:expires_at]
  end
end
