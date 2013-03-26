task :reindex=>["environment", "clear_search_indices"]  do
  User.current = User.first #set a user for orchestration

  ignore_list = ["CpConsumerUser", "PulpSyncStatus", "PulpTaskStatus", "Hypervisor", "Pool"]
  ignore_list << "UpstreamErrata" if Katello.config.katello? # upstream errata is exclusive to headpin

  Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
  models = ActiveRecord::Base.subclasses.sort{|a,b| a.name <=> b.name}
  models.each{|mod|
    if !ignore_list.include?(mod.name) && mod.respond_to?(:index)
       print "Re-indexing #{mod}\n"
       mod.index.import(mod.all) if mod.count > 0
    end
  }

  print "Re-indexing Repositories\n"

  #pulp_repos = Resources::Pulp::Repository.all
  #repos = Repository.all
  #repos.each{|r| r.populate_from pulp_repos}

  Repository.enabled.each{|repo|
    repo.index_packages
    repo.index_errata
  }

  print "Re-indexing Pools\n"
  cp_pools = Resources::Candlepin::Pool.all
  if cp_pools
    # Pool objects
    pools = cp_pools.collect{|cp_pool| ::Pool.find_pool(cp_pool['id'], cp_pool)}
    # Index pools
    ::Pool.index_pools(pools) if pools.length > 0
  end

  print "Re-indexing upstream errata\n"
  UpstreamErrata.index_all_errata
end
