require 'sassc'

class NanocSassImporter < SassC::Importer
  def initialize(items, filter, options)
    @items = items
    @filter = filter
  end

  def new(options)
    initialize(@items, @filter, options)
    self
  end

  def imports(path, parent_path)
    full_path = File.expand_path(path, File.dirname(parent_path)).sub(/\.s[ac]ss$/, '')
    last_slash_idx = full_path.rindex('/')
    glob = full_path.dup.tap { |x| x[last_slash_idx + 1, 0] = '{,_}' } + '.*'
    item = @items[glob]

    @filter.depend_on([item])

    Import.new(item.identifier.to_s, source: item.raw_content.dup)
  end
end

Class.new(Nanoc::Filter) do
  identifier :sassc

  def run(content, params = {})
    options = params.merge(
      importer: NanocSassImporter.new(@items, self, {}),
      filename: @item.identifier.to_s,
    )

    ::SassC::Engine.new(content.dup, options).render
  end
end
