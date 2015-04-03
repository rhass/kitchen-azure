require "kitchen/transport/ssh"

class Connection < Kitchen::Transport::Base::Connection
  # Redefine login_command for use with putty
  def login_command
     super

     args = %W[ #{username}@#{hostname} ]

     LoginCommand.new("putty", args)
  end

end

