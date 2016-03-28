module AssetPipelineHelper
  def embed_assets?
    ENV['EMBED_ASSETS'] == 'yes'
  end

  def embeddable_asset(asset_name)
    if embed_assets?
      data_uri = asset_data_uri(asset_name)
      "url(#{data_uri})"
    else
      path = asset_path(asset_name)
      "url(#{path}#iefix)"
    end
  end
  alias_method :embeddable_image, :embeddable_asset
end
