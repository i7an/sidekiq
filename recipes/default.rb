#
# Cookbook Name:: sidekiq
# Recipe:: default
#

# for now
worker_count = 1
app = 'backend'
env = 'production'
user = 'root'
group = 'root'

template "/etc/monit/conf.d/sidekiq_#{app}.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "monitrc.conf.erb"
  variables(num_workers: worker_count,
            app_name: app,
            rails_env: env
  )
end

template "/usr/local/bin/sidekiq" do
  owner 'root'
  group 'root'
  mode 0755
  source "sidekiq.erb"
end

worker_count.times do |count|
  template "/usr/local/#{app}/shared/config/sidekiq_#{count}.yml" do
    owner user
    group group
    mode 0644
    source "sidekiq.yml.erb"
    variables(require: "/usr/local/#{app}/current")
  end
end

execute "ensure-sidekiq-is-setup-with-monit" do
  command %Q{
        monit reload 
      }
end

execute "restart-sidekiq" do
  command %Q{
        echo "sleep 20 && monit -g #{app}_sidekiq restart all" | at now 
      }
end