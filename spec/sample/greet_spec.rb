require 'spec_helper'
require 'egison'

include Egison

class User < Struct.new(:name, :gender, :married, :doctor, :professor)
  def greet
    match(self) do
      with(_[_name,       _,    _,    _, true]) { "Hello, Prof. #{name}!" }
      with(_[_name,       _,    _, true,    _]) { "Hello, Dr. #{name}!" }
      with(_[_name,   :male,    _,    _,    _]) { "Hello, Mr. #{name}!" }
      with(_[_name, :female, true,    _,    _]) { "Hello, Mrs. #{name}!" }
      with(_[_name, :female,    _,    _,    _]) { "Hello, Ms. #{name}!" }
      with(_[_name,       _,    _,    _,    _]) { "Hello, #{name}!" }
    end
  end
end

describe "sample" do
  describe "greet.rb" do
    it %q{User.new("Egi", :male, true, false, false).greet} do
      expect(User.new("Egi", :male, true, false, false).greet).to eq \
        "Hello, Mr. Egi!"
    end
    it %q{User.new("Nanaka", :girl, false, false, false).greet} do
      expect(User.new("Nanaka", :girl, false, false, false).greet).to eq \
        "Hello, Nanaka!"
    end
    it %q{User.new("Hirai", :male, true, true, false).greet} do
      expect(User.new("Hirai", :male, true, true, false).greet).to eq \
        "Hello, Dr. Hirai!"
    end
    it %q{User.new("Hagiya", :male, true, true, true).greet} do
      expect(User.new("Hagiya", :male, true, true, true).greet).to eq \
        "Hello, Prof. Hagiya!"
    end
  end
end

