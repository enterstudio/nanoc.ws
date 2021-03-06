# frozen_string_literal: true

Class.new(Nanoc::Filter) do
  identifier :add_toc

  def run(content, _params = {})
    content.gsub('{{TOC}}') do
      # Find all top-level sections
      doc = Nokogiri::HTML(content)
      headers = doc.xpath('//h2').map do |header|
        title = header['data-nav-title'] || header.inner_html
        { title: title, id: header['id'] }
      end

      next '' if headers.empty?

      # Build table of contents
      res = +'<ol class="toc">'
      headers.each do |header|
        res << %(<li><a href="##{header[:id]}">#{header[:title]}</a></li>)
      end
      res << '</ol>'

      res
    end
  end
end
