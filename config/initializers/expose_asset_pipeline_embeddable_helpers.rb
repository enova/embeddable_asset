require 'embeddable_asset/asset_pipeline_helper'

Rails.application.config.after_initialize do
  if Rails.application.assets
    extend_pipeline_with_embeddable_helpers
  else
    print_failed_initialization_msg
  end
end

def extend_pipeline_with_embeddable_helpers
  Rails.application.assets.context_class.class_eval do
    include AssetPipelineHelper
  end
end

def print_failed_initialization_msg
  puts "\nWARNING: Unable to initialize EmbeddableAsset helpers. "\
       "'Rails.application.assets' is not defined. "\
       "Ensure 'config.assets.compile = true' for your current RAILS_ENV\n\n"
end
