all:
	make compile
	make test
compile:
	gem build egison.gemspec
	gem install egison-*.gem

test:
	bundle exec rspec spec
