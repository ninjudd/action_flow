Gem::Specification.new do |s|
  s.name = %q{flow}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Justin Balthrop", "Scott Steadman"]
  s.date = %q{2009-11-10}
  s.description = %q{A simple workflow mixin for controllers that makes creating flows and wizards dead simple.}
  s.email = %q{code@justinbalthrop.com}
  s.files = ["README.rdoc", "VERSION.yml"] + Dir.glob('{lib,test}/**/*.*')
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ninjudd/flow}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A state-machine inspired mixin for controllers that makes creating flows and wizards dead simple.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end
