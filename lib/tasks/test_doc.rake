# Generate rspec test documentation
# WARNING: rspec will use spork if available and will therefore use spork config such as color even if you specify --no-color
namespace :test_doc do
    task :html do
	# Variables
	file='doc/rspec_test_documentation.html'
	# Info
	puts()
	puts("Generating HTML documentation of rspec tests in #{file}")
	# Run rspec
	sh "rspec spec --format html --color -o #{file}"
	# Info
	puts("Done")
    end

    task :text do
	# Variables
	file='doc/rspec_test_documentation.txt'
	# Info
	puts()
	puts("Generating text documentation of rspec tests in #{file}")
	# Run rspec
	sh "rspec spec --format documentation --no-color -o #{file}"
	# Info
	puts("Done")
    end
end
