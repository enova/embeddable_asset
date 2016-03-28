namespace :assets do
  desc 'precompile assets while embedding assets designated with ENV["EMBED_ASSETS"]=yes'
  task 'precompile:embed' => :environment do
    compile_assets_as(embed: 'yes')
  end

  desc 'precompile assets without embedding assets'
  task 'precompile:unembed' => :environment do
    compile_assets_as(embed: nil)
  end

  desc 'completely remove compiled assets'
  task 'remove' => :environment do
    if Rake::Task.task_defined?('assets:clobber')
      Rake::Task['assets:clobber'].execute
    else
      Rake::Task['assets:clean'].execute
    end
  end

  def compile_assets_as(options={})
    ENV['EMBED_ASSETS'] = options[:embed]
    Rake::Task['assets:remove'].execute
    Rake::Task['tmp:cache:clear'].execute
    Rake::Task['assets:precompile'].execute
  end
end
