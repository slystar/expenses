namespace :sly do
    task :prep_test_db => :environment do
	Rake::Task["db:test:prepare"].invoke
    end
end
