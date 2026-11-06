class BackupDatabaseJob < ApplicationJob
  RETENTION = 30.days

  queue_as :default

  def perform(dir: 'storage/backups')
    dir = Rails.root.join(dir)

    FileUtils.mkdir_p dir, mode: 0o700

    dump dir.join("#{database}-#{Time.current.strftime('%Y%m%d%H%M%S')}.dump")

    # Also covers temporary files left behind when the job is killed mid-dump.
    dir.glob('*.{dump,tmp}').select { it.mtime < RETENTION.ago }.each(&:delete)
  end

  private

  def dump(path)
    tmp = path.sub_ext('.tmp')

    # Dumps contain API tokens. Create the file first so pg_dump never writes them with a wider mode.
    tmp.open File::WRONLY | File::CREAT | File::EXCL, 0o600, &:close

    system env, 'pg_dump', '--format=custom', "--file=#{tmp}", database, exception: true

    tmp.rename path
  ensure
    tmp.delete if tmp.exist?
  end

  def env
    {
      'PGHOST'     => config[:host],
      'PGPORT'     => config[:port]&.to_s,
      'PGUSER'     => config[:username],
      'PGPASSWORD' => config[:password]
    }.compact
  end

  def database
    config.fetch(:database)
  end

  def config
    ApplicationRecord.connection_db_config.configuration_hash
  end
end
