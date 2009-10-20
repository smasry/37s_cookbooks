require_recipe "aws"

directory "/u/apps" do
  owner "app"
  group "app"
  mode 0755
  recursive true
end

gem_package "rack" do
  version "1.0.0"
end

if node[:active_applications]

  node[:active_applications].each do |app, conf|

    directory "/u/apps/#{app}/shared/config" do
      recursive true
    end
    
    if node[:applications][app]
      if node[:applications][app][:gems]
        node[:applications][app][:gems].each do |g|
          if g.is_a? Array
            gem_package g.first do
              version g.last
            end
          else
            gem_package g
          end
        end
      end
    
      if node[:applications][app][:packages]
        node[:applications][app][:packages].each do |package_name|
          package package_name
        end      
      end
    
      if node[:applications][app][:symlinks]
        node[:applications][app][:symlinks].each do |target, source|
          link target do
            to source
          end
        end
      end
      
      if node[:applications][app][:aws]
        
        s3_bucket = node[:applications][app][:aws][:s3] ? node[:applications][app][:aws][:s3][:bucket] : "#{app}_#{conf[:env]}"
        
        template "/u/apps/#{app}/shared/config/s3.yml" do
          source "s3.yml.erb"
          mode "0640"
          cookbook "aws"
          variables node[:applications][app][:aws].merge(:s3_bucket => s3_bucket)
          owner "root"
          group "app"
        end
        
      end
      
    end
  end
else
  Chef::Log.info "Add an :active_applications attribute to configure this node's apps"
end