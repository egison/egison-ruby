require 'egison'

include Egison

class User < Struct.new(:name, :gender, :married, :doctor)
  def greet
    match(self) do
      with(_[_name, _, _, __("true")]) { "Hello, Dr. #{name}!" }
      with(_[_name, __(":male"), _, _]) { "Hello, Mr. #{name}!" }
      with(_[_name, __(":female"), __("true"), _]) { "Hello, Ms. #{name}!" }
      with(_[_name, __(":female"), _, _]) { "Hello, Mrs. #{name}!" }
      with(_[_name, _, _, _]) { "Hello, #{name}!" }

    end
  end
end

u1 = User.new("Egi", :male, true, false)
p(u1.greet)

u2 = User.new("Egi", :female, true, false)
p(u2.greet)

u3 = User.new("Egi", :female, false, false)
p(u3.greet)

u4 = User.new("Egi", :girl, false, false)
p(u4.greet)

u5 = User.new("Hirai", :male, true, true)
p(u5.greet)
