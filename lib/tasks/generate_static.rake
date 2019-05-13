namespace :static do
  # Should be run RAILS_ENV=static rails static:generate2
  desc 'Generate static site in ./out/ directory'
  task :generate => [:stop_rails_server, :stop_static_server, 'assets:clean', 'assets:precompile', :start_rails_server] do
    sleep(5)
    Dir.mkdir 'out' unless File.exist? 'out'
    Dir.chdir 'out' do
      `wget -mnH http://localhost:3000/`
    end
    `rsync -ruv --exclude=.svn/ public/ out/`

    # stop the server when we're done
    Rake::Task['static:stop_rails_server'].reenable
    Rake::Task['static:stop_rails_server'].invoke

    Rake::Task['static:start_static_server'].reenable
    Rake::Task['static:start_static_server'].invoke
  end

  desc 'Start a Rails server in the static Rails.env on port 3000'
  task :start_rails_server do
    `RAILS_ENV=static rails s -p 3000 -d`
    # `rails s -p 3000 -d`
  end

  desc 'Stop Rails server'
  task :stop_rails_server do
    `cat tmp/pids/server.pid | xargs -I {} kill {}`
  end

  desc 'Start a server using heel on port 8000 that will server our static site'
  task :start_static_server, :directory do |t, args|
    directory = args[:directory] || 'out'
    
    Dir.chdir directory do
      # `heel --daemonize --port 8000`
      `heel --port 8000`
    end
  end

  desc 'Stop the static server that is running using heel'
  task :stop_static_server do
    `heel --kill --port 8000`
  end
end