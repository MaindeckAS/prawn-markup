require 'spec_helper'
require 'pdf_helpers'

RSpec.describe Prawn::Markup::Processor::Tables do
  include_context 'pdf_helpers'

  let(:first_col_left) { left + table_padding }
  let(:first_row_top) { top - table_padding - 2 }
  let(:second_row_top) { first_row_top - line - 2 * table_padding - 1 }

  it 'creates a simple table' do
    processor.parse('<table><tr><td>hello</td><td>world</td></tr></table>')
    expect(text.strings).to eq(%w[hello world])
    expect(left_positions).to eq([first_col_left, 310])
  end

  it 'creates a simple table with tbody and thead' do
    processor.parse('<table><thead></thead><tbody><tr><td>hello</td><td>world</td></tr></tbody></table>')
    expect(text.strings).to eq(%w[hello world])
    expect(left_positions).to eq([first_col_left, 310])
  end

  it 'creates a table with header' do
    processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr>' \
                    '<tr><td>hello</td><td>world</td></tr></table>')
    expect(text.strings).to eq(['Col One', 'Col Two', 'hello', 'world'])
    expect(left_positions)
      .to eq([first_col_left, 311, first_col_left, 311])
    expect(top_positions)
      .to eq([first_row_top, first_row_top, second_row_top, second_row_top].map(&:round))
  end

  it 'horizontal rules in tables are ignored' do
    processor.parse('<table><tr><td>hello <hr/> world</td></tr></table>')
    expect(text.strings).to eq(['hello  world'])
  end

  it 'creates nested tables' do
    processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr><tr><td>' \
                    '<table><tr><td>hello</td><td>world</td></tr>' \
                    '<tr><td>hello</td><td>world</td></tr></table>' \
                    '</td><td>two</td></tr></table>')
    expect(text.strings).to eq(['Col One', 'Col Two', 'hello', 'world', 'hello', 'world', 'two'])
    first_sub_col_left = first_col_left + table_padding
    expect(left_positions)
      .to eq([first_col_left, 320, first_sub_col_left, 81, first_sub_col_left, 81, 320])
  end

  it 'creates nested tables with widths' do
    processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr><tr><td>' \
                    '<table><tr><td style="width: 4cm;">hello</td><td>world</td></tr>' \
                    '<tr><td>hello</td><td>world</td></tr></table>' \
                    '</td><td>two</td></tr></table>')
    expect(text.strings).to eq(['Col One', 'Col Two', 'hello', 'world', 'hello', 'world', 'two'])
    first_sub_col_left = first_col_left + table_padding
    expect(left_positions)
      .to eq([first_col_left, 345, first_sub_col_left, 159, first_sub_col_left, 159, 345])
  end

  it 'creates lists inside tables' do
    processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr><tr><td>' \
                    "\n<ul>\n\t<li>first</li>\n\t<li>second</li>\n</ul>" \
                    '</td><td>two</td></tr></table>')
    bullet_left = first_col_left + bullet_margin + bullet_padding
    desc_left = first_col_left + bullet_margin + content_margin + bullet_width
    list_top = second_row_top - list_vertical_margin
    expect(text.strings).to eq(['Col One', 'Col Two', bullet, 'first', bullet, 'second', 'two'])
    expect(left_positions)
      .to eq([first_col_left, 316, bullet_left, desc_left, bullet_left, desc_left, 316])
    expect(top_positions)
      .to eq([first_row_top, first_row_top,
              list_top, list_top,
              list_top - line, list_top - line,
              second_row_top].map(&:round))
  end

  it 'creates lists with sublists inside tables' do
    processor.parse(
      '<table><tr><th>Col One</th><th>Col Two</th></tr><tr><td>' \
      "\n<ul>\n\t<li>first</li>\n\t<li>second<ol><li>sub 1</li><li>sub 2</li></ol></li>\n<li>third</li>\n</ul>" \
      '</td><td>two</td></tr></table>'
    )
    bullet_left = first_col_left + bullet_margin + bullet_padding
    desc_left = first_col_left + bullet_margin + content_margin + bullet_width
    list_top = second_row_top - list_vertical_margin
    sub_bullet_left = desc_left + bullet_margin + bullet_padding
    sub_desc_left = desc_left + bullet_margin + content_margin + ordinal_width
    expect(text.strings).to eq(['Col One', 'Col Two',
                                bullet, 'first', bullet, 'second',
                                '1.', 'sub 1', '2.', 'sub 2',
                                bullet, 'third',
                                'two'])
    expect(left_positions)
      .to eq([first_col_left, 322,
              bullet_left, desc_left, bullet_left, desc_left,
              sub_bullet_left, sub_desc_left, sub_bullet_left, sub_desc_left,
              bullet_left, desc_left,
              322].map(&:round))
    expect(top_positions)
      .to eq([first_row_top, first_row_top,
              list_top, list_top,
              list_top - line, list_top - line,
              list_top - 2 * line, list_top - 2 * line,
              list_top - 3 * line, list_top - 3 * line,
              list_top - 4 * line, list_top - 4 * line,
              second_row_top].map(&:round))
  end

  it 'creates images inside tables' do
    processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr><tr><td>' \
                    "<img src=\"#{encode_image('logo.png')}\">" \
                    '</td><td>two</td></tr></table>')

    expect(text.strings).to eq(['Col One', 'Col Two', 'two'])
    expect(left_positions).to eq([first_col_left, 328, 328])
    expect(images.size).to eq(1)
    expect(images.first.hash[:Width]).to eq(100)
  end

  it 'creates images with text inside tables' do
    processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr><tr><td>' \
                    "Here comes an image: <img src=\"#{encode_image('logo.png')}\"> That was nice, not?" \
                    '</td><td>two</td></tr></table>')

    expect(text.strings).to eq(['Col One', 'Col Two', 'Here comes an image:', 'That was nice, not?', 'two'])
    expect(left_positions).to eq([first_col_left, 334, first_col_left, first_col_left, 334])
    expect(images.size).to eq(1)
    expect(images.first.hash[:Width]).to eq(100)
  end

  it 'uses column widths' do
    processor.parse(
      '<table><tr><td style="width: 3cm;">Col One</td><td>Col Two</td><td style="width: 40%;">Col Three</td></tr>' \
      '<tr><td>hello world has very much text hello world has very much text' \
      ' hello world has very much text hello world has very much text' \
      ' hello world has very much text</td><td>Two</td><td>Three</td></tr></table>'
    )

    second_left = first_col_left + 3.cm
    third_left = first_col_left + 0.6 * content_width
    expect(left_positions)
      .to eq([first_col_left, second_left, third_left,
              # each line in cell 2/1 creates an own string
              first_col_left, first_col_left, first_col_left, first_col_left, first_col_left,
              first_col_left, first_col_left, first_col_left, first_col_left, first_col_left,
              first_col_left, first_col_left, first_col_left, first_col_left, first_col_left,
              second_left, third_left].map(&:round))
  end

  it 'limits images to column width' do
    processor.parse(
      '<table><tr><th style="width: 2cm;">Col One</th><th>Col Two</th></tr><tr><td>' \
      "<img src=\"#{encode_image('logo.png')}\">" \
      '</td><td>two</td></tr></table>'
    )
    expect(text.strings).to eq(['Col One', 'Col Two', 'two'])
    expect(left_positions).to eq([first_col_left, first_col_left + 2.cm,
                                  first_col_left + 2.cm].map(&:round))
    expect(images.size).to eq(1)
  end

  it 'limits images to maximum column width if none given' do
    processor.parse(
      '<table><tr><th>Col One</th><th>Col Two</th></tr><tr><td>' \
      "<img src=\"#{encode_image('logo.png')}\" style=\"width: 2000px;\">" \
      '</td><td>two</td></tr></table>'
    )

    expect(text.strings).to eq(['Col One', 'Col Two', 'two'])
    expect(left_positions).to eq([first_col_left, 529, 529].map(&:round))
    expect(images.size).to eq(1)
  end

  it 'uses equal widths for large contents if none are given' do
    processor.parse('<table><tr><td>Col One</td><td>Col Two</td></tr>' \
      '<tr><td>hello world has very much text hello world has very much text' \
      ' hello world has very much text hello world has very much text' \
      ' hello world has very much text</td><td>' \
      '<table><tr><td>hey ho, i use space</td><td>space i use, too</td></tr>' \
      '<tr><td>my fellow on the right is empty. at least, i am very contentfull. ' \
      'so long that i am surely wrapped to multiple lines.</td><td></td></tr>' \
      '</table></td></tr></table>')

    expect(left_positions[0..1])
      .to eq([first_col_left, first_col_left + 0.5 * content_width].map(&:round))
  end

  it 'grow widths proportionally to total width' do
    processor.parse(
      '<table><tr><td style="width: 2cm;">Col One</td><td style="width: 25%;">Col Two</td></tr>' \
      '<tr><td>One</td><td>Two</td></tr></table>'
    )

    expect(left_positions).to eq([first_col_left, 201].map(&:round) * 2)
  end

  it 'reduce widths proportionally to total_width' do
    processor.parse(
      '<table><tr><td style="width: 12cm;">Col One</td><td style="width: 50%;">Col Two</td><td>Col Three</td></tr>' \
      '<tr><td>One</td><td>Two</td><td>Three</td></tr></table>'
    )

    expect(left_positions[0..2]).to eq([first_col_left, 329, 557].map(&:round))
  end

  it 'renders placeholder if subtable cannot be fitted' do
    cell = "<td>#{'bla blablablabla bla blabla' * 10}</td>"
    html = "<table><tr>#{cell * 3}<td><table><tr>#{cell * 6}</tr></table></td>#{cell * 3}</tr></table>"
    processor.parse(html)

    expect(text.strings).to include('bla')
    expect(text.strings).to include('[nested')
  end

  it 'does nothing for empty table' do
    processor.parse('<table></table>')

    expect(text.strings).to be_empty
    expect(PDF::Inspector::Graphics::Line.analyze(pdf).points.size).to eq(0)
  end

  it 'does nothing for table with empty rows' do
    processor.parse('<table><tr></tr><tr></tr></table>')

    expect(text.strings).to be_empty
    expect(PDF::Inspector::Graphics::Line.analyze(pdf).points.size).to eq(0)
  end

  it 'renders empty table with empty cells' do
    processor.parse('<table><tr><td> </td><td> </td></tr></table>')

    expect(text.strings).to be_empty
    expect(PDF::Inspector::Graphics::Line.analyze(pdf).points.size).to eq(16)
  end

  context 'options' do
    context 'for text' do
      let(:leading) { 5 }
      let(:font_size) { 15 }
      let(:options) { { text: { size: font_size, style: :bold, leading: leading } } }

      it 'are used in cells and headers' do
        processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr>' \
                        '<tr><td>hello</td><td>world</td></tr></table>')
        expect(text.strings).to eq(['Col One', 'Col Two', 'hello', 'world'])
        expect(text.font_settings).to eq([{ name: :'Helvetica-Bold', size: 15 }] * 4)
      end

      it 'adds some vertical spacing after table' do
        processor.parse('<table><tr><td>hello</td><td>world</td></tr></table><p>more here</p>')
        expect(text.strings).to eq(['hello', 'world', 'more here'])
        expect(left_positions).to eq([first_col_left, 310, left])
        # fix off by ones
        expect(top_positions).to eq([first_row_top - 1, first_row_top - 1,
                                     first_row_top + 1 - line - table_padding - leading].map(&:round))
      end
    end

    context 'for cells' do
      let(:options) do
        {
          text: { size: 15, style: :bold },
          table: { cell: { font: 'Courier', size: 14, text_color: 'FF0000', border_width: 1, padding: 2 } }
        }
      end

      it 'are used in cells and headers' do
        processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr>' \
                        '<tr><td>hello</td><td>world</td></tr></table>')
        expect(text.strings).to eq(['Col One', 'Col Two', 'hello', 'world'])
        expect(text.font_settings).to eq([{ name: :'Courier-Bold', size: 14 }] * 4)
      end
    end

    context 'for header' do
      let(:options) do
        {
          text: { size: 15, style: :italic },
          table: {
            cell: { font: 'Courier', size: 14, text_color: 'FF0000' },
            header: { font_style: :bold, size: 16, align: :center }
          }
        }
      end

      it 'are used only for headers' do
        processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr>' \
                        '<tr><td>hello</td><td>world</td></tr></table>')
        expect(text.strings).to eq(['Col One', 'Col Two', 'hello', 'world'])
        expect(text.font_settings).to eq(
          [{ name: :'Courier-Bold', size: 16 }] * 2 +
          [{ name: :'Courier-Oblique', size: 14 }] * 2
        )
      end
    end
  end

  context 'with impossible options' do
    let(:font_size) { 40 }
    let(:options) do
      {
        text: { size: font_size },
        table: { cell: { padding: 200 } }
      }
    end

    it 'renders placeholder' do
      processor.parse('<table><tr><th>Col One</th><th>Col Two</th></tr>' \
                        '<tr><td>hello</td><td>world</td></tr></table>')
      expect(text.strings).to eq(['[table content too large]'])
    end
  end

end
