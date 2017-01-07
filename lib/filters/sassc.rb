require 'sassc'

class NanocSassImporter < SassC::Importer
  def initialize(item, items, filter, options)
    super(options)
    @item = item
    @items = items
    @filter = filter
  end

  def new(options)
    initialize(@item, @items, @filter, options)
    self
  end

  def imports(path, parent_path)
    candidates = []

    full_path = File.expand_path(path, File.dirname(parent_path)).sub(/\.s[ac]ss$/, '')
    candidates << full_path

    last_slash_idx = full_path.rindex('/')
    candidates << full_path.dup.tap { |x| x[last_slash_idx + 1, 0] = '_'}

    candidates.concat(candidates.flat_map { |e| [e + '.scss', e + '.sass'] })

    filename = candidates.find { |e| File.file?(e) }

    root = Dir.getwd + '/content'
    unless filename.start_with?(root)
      raise '?!'
    end

    identifier = filename[root.length..-1]

    item = @items[identifier]
    p item

    p "Creating dependency on #{item}…"
    @filter.depend_on([item])
    p "Created dependency on #{item}"

    Import.new(filename)
  end
end

Class.new(Nanoc::Filter) do
  identifier :sassc

  def run(content, params = {})
    options = params.merge(
      importer: NanocSassImporter.new(@item, @items, self, {}),
      filename: @item.raw_filename,
    )

    ::SassC::Engine.new(content.dup, options).render
  end
end
