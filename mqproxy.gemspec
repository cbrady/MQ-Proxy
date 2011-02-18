Gem::Specification.new do |s|
  s.name = %q{mqproxy}
  s.version = '1.0'
  s.author = "Christopher Brady"
  s.date = %{2011-02-18}
  s.homepage = %q{http://github.com/cbrady/MQ-Proxy}
  s.description = %q{A wrapper for the MapQuest API, provides ability to get route and to geocode an address}
  s.summary = %q{A wrapper for the MapQuest API, provides ability to get route and to geocode an address}
  s.require_paths = ['lib']
  s.files = ['lib/mqproxy.rb','MIT-LICENSE','Rakefile','README','test/mqproxy_test.rb','test/test_helper.rb']
  s.test_files = ['test/mqproxy_test.rb']
  s.rubygems_version = %q{1.3.1}
  s.add_dependency('json')
end