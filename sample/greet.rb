require 'egison'

include Egison

class User < Struct.new(:name, :gender, :married, :doctor, :professor)
  def greet
    match(self) do
      with(User.(_name,       _,    _,    _, true)) { "Hello, Prof. #{name}!" }
      with(User.(_name,       _,    _, true))       { "Hello, Dr. #{name}!" }
      with(User.(_name, :female, true))             { "Hello, Mrs. #{name}!" }
      with(User.(_name, :female))                   { "Hello, Ms. #{name}!" }
      with(User.(_name,   :male))                   { "Hello, Mr. #{name}!" }
      with(User.(_name))                            { "Hello, #{name}!" }
    end
  end
end

u1 = User.new("Egi", :male, true, false, false)
p(u1.greet)

u2 = User.new("Nanaka", :girl, false, false, false)
p(u2.greet)

u3 = User.new("Hirai", :male, true, true, false)
p(u3.greet)

u4 = User.new("Hagiya", :male, true, true, true)
p(u4.greet)
