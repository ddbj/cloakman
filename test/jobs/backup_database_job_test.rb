require 'test_helper'

class BackupDatabaseJobTest < ActiveJob::TestCase
  setup do
    @dir = Pathname(Dir.mktmpdir)
  end

  teardown do
    @dir.rmtree
  end

  test 'dumps the primary database to a file only the owner can read' do
    BackupDatabaseJob.perform_now dir: @dir.to_s

    dump = @dir.glob('*.dump').sole

    assert_equal 0o600, dump.stat.mode & 0o777
    assert_includes IO.popen(['pg_restore', '--list', dump.to_s], &:read), 'TABLE public api_keys'
    assert_empty @dir.glob('*.tmp')
  end

  test 'removes dumps past the retention period' do
    expired     = @dir.join('expired.dump').tap { it.write '' }
    expired_tmp = @dir.join('expired.tmp').tap { it.write '' }
    recent      = @dir.join('recent.dump').tap { it.write '' }

    age expired,     BackupDatabaseJob::RETENTION + 1.day
    age expired_tmp, BackupDatabaseJob::RETENTION + 1.day
    age recent,      BackupDatabaseJob::RETENTION - 1.day

    BackupDatabaseJob.perform_now dir: @dir.to_s

    assert_not expired.exist?
    assert_not expired_tmp.exist?
    assert recent.exist?
  end

  test 'keeps existing dumps and leaves no temporary file when pg_dump fails' do
    existing = @dir.join('existing.dump').tap { it.write '' }

    age existing, BackupDatabaseJob::RETENTION + 1.day

    with_pg_dump_failure do
      assert_raises RuntimeError do
        BackupDatabaseJob.perform_now dir: @dir.to_s
      end
    end

    assert existing.exist?
    assert_empty @dir.glob('*.tmp')
  end

  private

  def age(path, duration)
    time = duration.ago.to_time

    path.utime time, time
  end

  def with_pg_dump_failure
    Dir.mktmpdir do |bin|
      pg_dump = Pathname(bin).join('pg_dump')
      pg_dump.write "#!/bin/sh\nexit 1\n"
      pg_dump.chmod 0o755

      path        = ENV['PATH']
      ENV['PATH'] = "#{bin}:#{path}"

      yield
    ensure
      ENV['PATH'] = path
    end
  end
end
