users = Mash.new(DataBag.load("user_data/accounts"))
groups = Mash.new(DataBag.load("user_data/groups"))

groups.each do |group_key, config|
  group group_key do
    group_name group_key.to_s
    gid config[:gid]
    action [:create, :manage]
  end
end

if node[:active_users]
  node[:active_users].each do |username|
    config = users[username]
    user username do
      comment config[:comment]
      uid config[:uid]
      gid config[:groups].first
      home "/home/#{username}"
      shell "/bin/bash"
      password config[:password]
      supports :manage_home => true
      action [:create, :manage]
    end  
  end
end

node[:active_groups].each do |group_name, config|
  
  users = users.find_all { |username, u_config| u_config["groups"].include?(group_name) }

  users.each do |u, config|
    user u do
      comment config[:comment]
      uid config[:uid]
      gid config[:groups].first
      home "/home/#{u}"
      shell "/bin/bash"
      password config[:password]
      supports :manage_home => true
      action [:create, :manage]
    end

    config[:groups].each do |g|
      group g do
        group_name g.to_s
        gid groups[g][:gid]
        members [ u ]
        append true
        action [:modify]
      end
    end    
    
    remote_file "/home/#{u}/.profile" do
      source "users/#{u}/.profile"
      mode 0750
      owner u
      group config[:groups].first.to_s
    end
    
    directory "/home/#{u}/.ssh" do
      action :create
      owner u
      group config[:groups].first.to_s
      mode 0700
    end
    
    add_keys u do
      conf config
    end
  end
end

# Remove initial setup user and group.
user  "ubuntu" do
  action :remove
end

group "ubuntu" do
  action :remove
end

directory "/u" do
  action :create
  owner "root"
  group "admin"
  mode 0775
end
