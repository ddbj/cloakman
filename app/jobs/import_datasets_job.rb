class ImportDatasetsJob < ApplicationJob
  ATTRIBUTE_BY_PREFIX = {
    'jga-users-' => :jga_datasets,
    'agd-users-' => :agd_datasets
  }

  queue_as :default

  def perform(dir: 'storage/humandbs', cleanup: true)
    Rails.root.join(dir).glob '*.jsonl' do |path|
      attr = ATTRIBUTE_BY_PREFIX.find {|prefix, _| path.basename.to_s.start_with?(prefix) }&.last

      next unless attr

      path.each_line do |line|
        json = JSON.parse(line, symbolize_names: true)
        user = User.find(json[:username])

        user.public_send "#{attr}=", json[:dataset].uniq.map { JSON.dump(it) }
        user.save! validate: false
      rescue LDAPError::NoSuchObject
        # do nothing
      end

      path.delete if cleanup
    end
  end
end
