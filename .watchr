# Look for argument
notify=ARGV[1]

# Check for notify
if notify =~ /libnotify/i
    # Require library
    require 'libnotify'
    # Set flag
    @libnotify=true
    # Get current directory
    pwd=Dir.pwd
    # Set icon paths
    @icon={}
    @icon[:fail]=File.join(pwd,'.autotest_images/fail.png')
    @icon[:pass]=File.join(pwd,'.autotest_images/pass.png')
    @icon[:pending]=File.join(pwd,'.autotest_images/pending.png')
end

def run_spec_and_notify(file)
    # Set Default icon
    icon=@icon[:pass]
    # Get results from rspec
    results=`bundle exec rspec #{file}`
    # Extract info from results
    examples=results.match(/([0-9]+)\sexamples?/)[1].to_i
    failures=results.match(/([0-9]+)\sfailures?/)[1].to_i
    pending=results.match(/([0-9]+)\spending/)[1].to_i if results =~ /pending/
    # Look for failures or pending and set icon
    if failures > 0
	icon=@icon[:fail]
    elsif not pending.nil? and pending > 0
	icon=@icon[:pending]
    end
    # Notify
    Libnotify.show do |notify|
	notify.summary=file
	notify.body=results.gsub(/\e[^\s]*/,'')
	notify.timeout=5
	notify.icon_path=icon
    end
    # Print results to terminal too
    puts(results)
end

def run_spec(file)
    unless File.exist?(file)
	puts "#{file} does not exist"
	return
    end

    puts "Running #{file}"
    # Check if we want graphical notification
    if @libnotify
	run_spec_and_notify(file)
    else
	system "bundle exec rspec #{file}"
    end
    puts
end

watch("spec/.*/*_spec.rb") do |match|
    run_spec match[0]
end

watch("app/(.*/.*).rb") do |match|
    run_spec %{spec/#{match[1]}_spec.rb}
end