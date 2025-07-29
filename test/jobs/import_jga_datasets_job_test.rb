require 'test_helper'

class ImportJGADatasetsJobTest < ActiveJob::TestCase
  test 'perform' do
    FactoryBot.create :user, id: 'alice'

    ImportJGADatasetsJob.perform_now dir: 'test/fixtures/files/jga_datasets', cleanup: false

    user = User.find('alice')

    assert_equal 2, user.jga_datasets.size

    first, second = user.jga_datasets.map { JSON.parse(it, symbolize_names: true) }

    assert_equal({id: 'JGAD000001', expires_at: '2025-01-01T00:00:00Z'}, first)
    assert_equal({id: 'JGAD000002', expires_at: '2025-01-02T00:00:00Z'}, second)
  end
end
