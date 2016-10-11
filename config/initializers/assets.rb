# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w( jquery.minicolors.css )
Rails.application.config.assets.precompile += %w( jquery.minicolors.js )
Rails.application.config.assets.precompile += %w( bootstrap.js )
Rails.application.config.assets.precompile += %w( bootstrap.css )
Rails.application.config.assets.precompile += %w( bootstrap-responsive.css )
Rails.application.config.assets.precompile += %w( select2.js )
Rails.application.config.assets.precompile += %w( select2.css )
Rails.application.config.assets.precompile += %w( lodash.js )
Rails.application.config.assets.precompile += %w( three.js )

Rails.application.config.assets.precompile += %w( cameraDolly.js )
Rails.application.config.assets.precompile += %w( meshControl.js )
Rails.application.config.assets.precompile += %w( utils.js )
Rails.application.config.assets.precompile += %w( viewer.js )


Rails.application.config.assets.precompile += %w( jquery.reel-min.js )
Rails.application.config.assets.precompile += %w( util.css )


Rails.application.config.assets.precompile += %w( star.png )
Rails.application.config.assets.precompile += %w( blank.png )
