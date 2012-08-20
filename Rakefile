require 'puppet'
require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint'
require 'parallel_tests'
require 'parallel_tests/cli'

ENV['RUBYOPT'] = ENV['RUBYOPT'] + ' -W0'
SPECS_PATTERN = '{manifests/spec,modules/*/spec/*}/*_spec.rb'

PuppetLint.configuration.with_filename = true
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send("disable_autoloader_layout")
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send("disable_inherits_across_namespaces")

desc "Run puppet-lint"
task :lint do
  $stderr.puts '---> Running lint checks'
  RakeFileUtils.send(:verbose, true) do
    linter = PuppetLint.new
    matched_files = FileList['**/*.pp']

    if ignore_paths = PuppetLint.configuration.ignore_paths
      matched_files = matched_files.exclude(*ignore_paths)
    end

    matched_files.to_a.each do |puppet_file|
      linter.file = puppet_file
      linter.run
    end

    fail if linter.errors? or linter.warnings?
  end
end

desc "Test sudoers syntax"
task :sudoers do
  $stderr.puts '---> Checking sudoers syntax'
  sh 'visudo -c -f modules/sudo/files/sudoers'
end

desc "Run rspec tests with `rake spec[num_cpus, pattern, rspec_options]`"
task :spec, [:count, :pattern, :options] do |t, args|
  $stderr.puts '---> Running puppet specs (parallel)'
  count, pattern, options = ParallelTests.parse_rake_args(args)

  matched_files = FileList[SPECS_PATTERN]

  if pattern != ''
    matcher = Regexp.new(pattern)
    matched_files.select! { |f| matcher.match(f) }
  end

  cli_args = ['-t', 'rspec', '-n', count, '-o', options]
  cli_args.concat(matched_files)

  ParallelTest::CLI.run(cli_args)
end

desc "Run rspec tests in serial"
RSpec::Core::RakeTask.new(:sspec) do |t|
  t.pattern = SPECS_PATTERN
  t.rspec_opts = '--color'
end

desc "Run all tests"
task :test => [:spec, :sudoers]

task :default => [:lint, :test]
