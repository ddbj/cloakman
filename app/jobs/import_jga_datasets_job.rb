class ImportJGADatasetsJob < ApplicationJob
  queue_as :default

  def perform(dir: "storage/humansdb", cleanup: true)
    Rails.root.join(dir).glob "*.jsonl" do |path|
      path.each_line do |line|
        json = JSON.parse(line, symbolize_names: true)
        user = User.find(json[:username])

        user.update! jga_datasets: json[:dataset].uniq.map { JSON.dump(it) }
      rescue LDAPError::NoSuchObject
        # do nothing
      end

      path.delete if cleanup
    end
  end
end
