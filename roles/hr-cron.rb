name "hr-cron"
description "HR Cron/utility server"
recipes "cron", "nfs::client", "syslog::client"
default_attributes :active_groups => {:app => {:enabled => true}},
                   :active_sudo_groups => {:app => {:enabled => true}}
