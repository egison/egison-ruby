all:
	gem build egison.gemspec
	gem install egison-*.gem

test:
	bundle exec rspec spec
