apt Mash.new
rubygems[:mirror] = Mash.new
rubygems[:mirror][:base_path] = "/u/mirrors/gems"
rubygems[:mirror][:aliases] = ['gems','gems.37signals.com']