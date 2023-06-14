require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor::Lists do
  include_context 'pdf_helpers'

  let(:bullet_left) { left + bullet_margin + bullet_padding }
  let(:desc_left) { left + bullet_margin + bullet_width + content_margin }
  let(:list_top) { top - line - list_vertical_margin }

  it 'creates an unordered list' do
    processor.parse('hello<ul><li>first</li><li>second</li><li>third</li></ul>world')
    expect(text.strings).to eq(['hello', bullet, 'first', bullet, 'second', bullet, 'third', 'world'])
    expect(left_positions).to eq([left] + [bullet_left, desc_left].map(&:round) * 3 + [left])
    expect(top_positions).to eq([top,
                                 list_top, list_top,
                                 list_top - line, list_top - line,
                                 list_top - 2 * line, list_top - 2 * line,
                                 list_top - 3 * line - list_vertical_margin - leading - p_gap].map(&:round))
  end

  it 'creates an ordered list' do
    processor.parse('<ol><li>first</li><li>second</li><li>third</li></ol>world')
    expect(text.strings).to eq(['1.', 'first', '2.', 'second', '3.', 'third', 'world'])
    desc_left = left + bullet_margin + ordinal_width + content_margin
    expect(left_positions).to eq([bullet_left, desc_left].map(&:round) * 3 + [left])
    list_top = top - list_vertical_margin
    expect(top_positions).to eq([list_top, list_top,
                                 list_top - line, list_top - line,
                                 list_top - 2 * line, list_top - 2 * line,
                                 list_top - 3 * line - list_vertical_margin - p_gap - leading].map(&:round))
  end

  it 'creates a large nested list' do
    processor.parse(
      '<p>hello</p><ul><li>first</li><li>second' \
      '<ol><li>sub 1</li><li>sub 2 has a lot of text spaning more than two lines at least' \
      'or probably even some more and then we go on and on and on and on</li><li>sub 3</li></ol>' \
      '</li><li>third has a lot of text spaning more than two lines at least' \
      'or probably even some more and then we go on and on and on and on</li></ul>world'
    )
    sub_ordinal_left = desc_left + bullet_margin + bullet_padding
    sub_desc_left = desc_left + bullet_margin + ordinal_width + content_margin
    expect(left_positions)
      .to eq([left,
              bullet_left, desc_left,
              bullet_left, desc_left,
              sub_ordinal_left, sub_desc_left,
              sub_ordinal_left, *([sub_desc_left] * 2),
              sub_ordinal_left, sub_desc_left,
              bullet_left, *([desc_left] * 2),
              left].map(&:round))

    ltop = list_top - p_gap
    sub_list_top = ltop - 2 * line
    expect(top_positions)
      .to eq([top,
              ltop, ltop,
              ltop - line, ltop - line,
              sub_list_top, sub_list_top,
              sub_list_top - line, sub_list_top - line,
              sub_list_top - 2 * line,
              sub_list_top - 3 * line, sub_list_top - 3 * line,
              sub_list_top - 4 * line, sub_list_top - 4 * line,
              sub_list_top - 5 * line,
              sub_list_top - 6 * line - list_vertical_margin - leading - p_gap
            ].map(&:round))
  end

  it 'creates a huge nested list' do
    processor.parse(
      '<ol>' +
        ( '<li>' +
          ('Lorem ipsum ' * 20) +
          '<ul>' +
            ('<li>' + ('dolor sit amet ' * 20) + '</li>') * 3  +
          '</ul></li>' ) * 10 +
      '</ol>'
    )
    expect(text.strings.size).to eq(200) # many, not just placeholder
  end

  # regression spec for https://github.com/puzzle/prawn-markup/issues/38
  it 'creates longer list with correct bullet indent' do
    processor.parse('<ol>' + ( '<li>Item</li>' * 11) + '</ol>')
    ltop = top - list_vertical_margin
    expect(top_positions).to eq(11.times.flat_map { |i| [(ltop - i * line).round] * 2 })
  end

  # See https://bugzilla.gnome.org/show_bug.cgi?id=759987
  # Fixed with newer version
  it 'creates a large nested list with direct children sublists (invalid html)' do
    processor.parse(
      '<p>hello</p><ul><li>first</li><li>second</li>' \
      '<ol><li>sub 1</li><li>sub 2 has a lot of text spaning more than two lines at least' \
      'or probably even some more and then we go on and on and on and on</li><li>sub 3</li></ol>' \
      '<li>third has a lot of text spaning more than two lines at least' \
      'or probably even some more and then we go on and on and on and on</li></ul>world'
    )

    ol_desc_left = left + bullet_margin + ordinal_width + content_margin
    sub_ordinal_left = desc_left + bullet_margin + bullet_padding
    sub_desc_left = desc_left + bullet_margin + ordinal_width + content_margin
    expect(left_positions)
      .to eq([left,
              bullet_left, desc_left,
              bullet_left, desc_left,
              sub_ordinal_left, sub_desc_left,
              sub_ordinal_left, sub_desc_left, sub_desc_left,
              sub_ordinal_left, sub_desc_left,
              bullet_left, desc_left, desc_left,
              left].map(&:round))

    ltop = list_top - p_gap
    second_ltop = ltop - 2 * line
    third_ltop = second_ltop - 4 * line
    expect(top_positions)
      .to eq([top,
              ltop, ltop,
              ltop - line, ltop - line,
              second_ltop, second_ltop,
              second_ltop - line, second_ltop - line,
              second_ltop - 2 * line,
              second_ltop - 3 * line, second_ltop - 3 * line,
              third_ltop, third_ltop,
              third_ltop - line,
              third_ltop - 2 * line - list_vertical_margin - leading - p_gap,
            ].map(&:round))
  end

  it 'creates a nested list with inline html' do
    processor.parse(<<~HTML
      <ol>
        <li><strong>All Bold</strong></li>
        <li>
          <strong>More</strong>
          <ul>
            <li><strong>more</strong></li>
          </ul>
        </li>
        <li><strong>more</strong></li>
        <li>
          <strong>more</strong>
          <ul>
            <li>
              <strong>more</strong>
              <ol>
                <li><strong>more</strong></li>
              </ol>
            </li>
          </ul>
        </li>
      </ol>
      HTML
    )
    expect(text.strings).to eq(['1.', 'All Bold', '2.', 'More', '•', 'more', '3.', 'more',
                                '4.', 'more', '•', 'more', '1.', 'more'])
    expect(text.font_settings.map { |h| h[:name] })
      .to eq(%i[Helvetica Helvetica-Bold Helvetica Helvetica-Bold Helvetica Helvetica-Bold
                Helvetica Helvetica-Bold Helvetica Helvetica-Bold Helvetica Helvetica-Bold
                Helvetica Helvetica-Bold])
  end

  it 'creates nested list with image' do
    processor.parse(
      '<p>hello</p><ul><li>first</li><li>second' \
      '<ol><li>sub 1</li><li>' \
      "<img src=\"#{encode_image('logo.png')}\" style=\"width: 1024px;\">" \
      '</li><li>sub 3</li></ol>' \
      '</li><li>third has a lot of text spaning more than two lines at least' \
      'or probably even some more and then we go on and on and on and on</li></ul>world'
    )
    orig_image_dim = [100, 38]
    sub_desc_left = desc_left + bullet_margin + ordinal_width + content_margin
    image_width = content_width - sub_desc_left
    image_height = image_width * orig_image_dim.last / orig_image_dim.first

    expect(images.size).to eq(1)
    ltop = list_top - p_gap
    sub_list_top = ltop - 2 * line
    expect(top_positions)
      .to eq([top,
              ltop, ltop,
              ltop - line, ltop - line,
              sub_list_top, sub_list_top,
              sub_list_top - line,
              sub_list_top - 2 * line - image_height, sub_list_top - 2 * line - image_height,
              sub_list_top - 3 * line - image_height, sub_list_top - 3 * line - image_height,
              sub_list_top - 4 * line - image_height,
              sub_list_top - 5 * line - image_height - list_vertical_margin - leading - p_gap].map(&:round))
  end

  it 'allows invalid nested list' do
    processor.parse('<ul><ul><li>Bla</li></ul></ul>')

    expect(text.strings).to eq(['•', '•', 'Bla'])
  end

  it 'does nothing for empty list' do
    processor.parse('<ul></ul>')

    expect(text.strings).to be_empty
  end

  it 'renders bullet for list with empty items' do
    processor.parse('<ol><li></li></ol>')

    expect(text.strings).to eq(['1.'])
  end

  it 'renders nothing for items without list' do
    processor.parse('<li>Hello</li>rest')

    expect(text.strings).to eq(['Hellorest'])
  end

  context 'with options' do
    let(:font_size) { 10 }
    let(:leading) { 8 }
    let(:list_vertical_margin) { 0 }
    let(:options) do
      {
        text: { leading: leading, size: font_size, margin_bottom: 0 },
        list: { vertical_margin: list_vertical_margin,  bullet: { char: '*' }, content: { margin: 20 } }
      }
    end

    it 'creates an unordered list' do
      processor.parse('<p>hello</p><ul><li>first</li><li>second</li></ul><ul><li>third</li></ul><p>world</p>')
      expect(text.strings).to eq(['hello', '*', 'first', '*', 'second', '*', 'third', 'world'])
      expect(left_positions).to eq([left] + [bullet_left, desc_left + 10].map(&:round) * 3 + [left])
      expect(top_positions).to eq([top,
                                   list_top, list_top,
                                   list_top - line, list_top - line,
                                   list_top - 2 * line, list_top - 2 * line,
                                   list_top - 3 * line - list_vertical_margin
                                  ].map(&:round))
    end

    it 'creates a large nested list' do
      processor.parse(
        '<p>hello</p><ul><li>first</li><li>second' \
        '<ol><li>sub 1</li><li>sub 2 has a lot of text spaning more than two lines at least' \
        'or probably even some more and then we go on and on and on and on</li><li>sub 3</li></ol>' \
        '</li><li>third has a lot of text spaning more than two lines at least' \
        'or probably even some more and then we go on and on and on and on</li></ul>world'
      )
      sub_ordinal_left = desc_left + 10 + bullet_margin + bullet_padding
      sub_desc_left = desc_left + 10 + bullet_margin + 8 + content_margin + 10
      expect(left_positions)
        .to eq([left,
                bullet_left, desc_left + 10,
                bullet_left, desc_left + 10,
                sub_ordinal_left, sub_desc_left,
                sub_ordinal_left, *([sub_desc_left] * 2),
                sub_ordinal_left, sub_desc_left,
                bullet_left, *([desc_left + 10] * 2),
                left].map(&:round))
      ltop = list_top
      sub_list_top = ltop - 2 * line
      expect(top_positions)
        .to eq([top,
                ltop, ltop,
                ltop - line, ltop - line,
                sub_list_top, sub_list_top,
                sub_list_top - line, sub_list_top - line,
                sub_list_top - 2 * line,
                sub_list_top - 3 * line , sub_list_top - 3 * line ,
                sub_list_top - 4 * line, sub_list_top - 4 * line,
                sub_list_top - 5 * line,
                sub_list_top - 6 * line - list_vertical_margin].map(&:round))
    end
  end

  context 'with impossible options' do
    let(:font_size) { 40 }
    let(:options) do
      {
        text: { size: font_size },
        list: { bullet: { margin: 400 }, content: { margin: 500, padding: 200 } }
      }
    end

    it 'renders placeholder' do
      processor.parse('<ul><li>first waytolargeitemwithsolongstrings</li><li>second</li></ul>')
      expect(text.strings).to eq(['[list content too large]'])
    end
  end

end
