require "rails_helper"

# This file will be included in the nested "dummy" projects under spec/dummy_* in
# order to test this Gem in realistic app environments

RSpec.shared_examples 'Embeddable Rake Tasks' do
  OPTIONAL_WHITESPACE       = '\s?'
  WILDCARD                  = '.*?'
  PROP_DELIMETER            = ';'
  EMBEDDED_DATA_URL_PREFIX  = 'url(data:'

  def precompile_assets!(embed:)
    action = embed ? 'embed' : 'unembed'
    `rake assets:precompile:#{action}`
  end

  def regex_range(leading: '', start:, stop:)
    escaped_leading = Regexp.quote(leading)
    escaped_start   = Regexp.quote(start)
    escaped_stop    = Regexp.quote(stop)

    raw_regex_range = "#{escaped_leading}"\
                      "#{OPTIONAL_WHITESPACE}"\
                      "#{escaped_start}"\
                      "#{WILDCARD}"\
                      "#{escaped_stop}"

    Regexp.new(raw_regex_range, Regexp::MULTILINE | Regexp::IGNORECASE)
  end

  def get_css_rules(selector)
    selector_regexp = regex_range(leading: selector, start: '{', stop: '}')
    application_css.match(selector_regexp).try(:[], 0)
  end

  def get_css_property(selector, property)
    rules = get_css_rules(selector)
    return unless rules
    property_regex = regex_range(start: property, stop: PROP_DELIMETER)
    rules.match(property_regex).try(:[], 0)
  end

  def get_css_property_value(selector, property)
    property = get_css_property(selector, property)
    return unless property
    property.partition(/:/).last.chomp(PROP_DELIMETER).strip
  end

  def embedded_data_url?(url)
    url.start_with?(EMBEDDED_DATA_URL_PREFIX)
  end

  def asset_regex(asset)
    parts     = asset.partition('.')
    name      = parts.first
    extension = parts.second + parts.last
    regex_range(start: name, stop: extension)
  end

  def application_asset(extension)
    search_path = Rails.root.join('public', 'assets', "application*.#{extension}")
    file_path = Dir.glob(search_path).first
    File.read(file_path) if file_path
  end

  def application_css
    application_asset('css')
  end

  def application_js
    application_asset('js')
  end

  after do
    `rake assets:remove`
    `rake tmp:cache:clear`
  end

  shared_examples_for 'embedded css asset' do |selector:, property:, asset:|
    it "embedds asset: '#{asset}', via selector: '#{selector}', in property: #{property}" do
      prop_url = get_css_property_value(selector, property)
      expect(embedded_data_url?(prop_url)).to be true
      expect(prop_url).not_to match(asset_regex(asset))
    end
  end

  shared_examples_for 'unembedded css asset' do |selector:, property:, asset:|
    it "does not embed asset: '#{asset}', via selector: '#{selector}', in property: #{property}" do
      prop_url = get_css_property_value(selector, property)
      expect(embedded_data_url?(prop_url)).to be false
      expect(prop_url).to match(asset_regex(asset))
    end
  end

  shared_examples_for 'precompiled assets' do |embed:|
    action = embed ? 'embedded' : 'unembedded'

    it 'compiles JavaScript and CSS' do
      expect(application_css).to include('h2')
      expect(application_js).to include('doAwesomeStuff')
    end

    context 'pipeline assets not using embeddable gem' do
      it_behaves_like 'unembedded css asset',
        selector: 'h2',
        property: 'background-image',
        asset:    'duck.jpg'
    end

    context '#embeddable-asset' do
      it_behaves_like "#{action} css asset",
        selector: '@font-face',
        property: 'src',
        asset:    'chopin_script.ttf'
    end

    context '#embeddable-image' do
      it_behaves_like "#{action} css asset",
        selector: 'html',
        property: 'background-image',
        asset:    'dog.jpg'
    end
  end

  describe 'rake assets:precompile:embed' do
    before { precompile_assets!(embed: true) }
    it_behaves_like 'precompiled assets', embed: true

    context 'recompiling with unembedded assets' do
      before { precompile_assets!(embed: false) }
      it_behaves_like 'precompiled assets', embed: false
    end
  end

  describe 'rake assets:precompile:unembed' do
    before { precompile_assets!(embed: false) }
    it_behaves_like 'precompiled assets', embed: false

    context 'recompiling with embedded assets' do
      before { precompile_assets!(embed: true) }
      it_behaves_like 'precompiled assets', embed: true
    end
  end
end
