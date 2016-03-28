require 'spec_helper'

describe EmbeddableAsset do
  it 'has a version number' do
    expect(EmbeddableAsset::VERSION).not_to be nil
  end
end
