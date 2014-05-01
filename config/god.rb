rails_env = ENV['RAILS_ENV']
rails_root = ENV['RAILS_ROOT']

God.watch do |w|
  w.name          = "discovery_server"
  w.group         = 'worker'
  w.interval      = 30.seconds
  w.env           = { 'RAILS_ENV' => rails_env, 'TERM_CHILD' => 1 }
  w.dir           = rails_root
  w.start         = "bundle exec rake discovery:start"
  w.start_grace   = 10.seconds
  w.log           = File.join(rails_root, 'log', 'discovery_server.log')

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 200.megabytes
      c.times = 2
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end

God.watch do |w|
  w.name          = "merge_daemon"
  w.group         = 'worker'
  w.interval      = 30.seconds
  w.env           = { 'RAILS_ENV' => rails_env, 'TERM_CHILD' => 1 }
  w.dir           = rails_root
  w.start         = "bundle exec rake merge_daemon:start"
  w.start_grace   = 10.seconds
  w.log           = File.join(rails_root, 'log', 'merge_daemon.log')

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 200.megabytes
      c.times = 2
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end

God.watch do |w|
  w.name          = "job_worker"
  w.group         = 'worker'
  w.interval      = 30.seconds
  w.env           = { 'RAILS_ENV' => rails_env, 'TERM_CHILD' => 1 }
  w.dir           = rails_root
  w.start         = "bundle exec rake jobs:work"
  w.start_grace   = 10.seconds
  w.log           = File.join(rails_root, 'log', 'job_worker.log')

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 200.megabytes
      c.times = 2
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end
