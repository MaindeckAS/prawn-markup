module Prawn
  module Markup
    module Processor::Text
      def self.prepended(base)
        base.known_elements.push('p', 'br', 'div', 'b', 'strong', 'i', 'em', 'u', 'a', 'hr')
      end

      def start_br
        append_text("\n")
      end

      def start_p
        handle_text_element
      end

      def end_p
        if inside_container?
          append_new_line
          append_text("\n")
        else
          add_paragraph
        end
      end

      def start_div
        handle_text_element
      end

      def end_div
        handle_text_element
      end

      def start_a
        append_text("<link href=\"#{current_attrs['href']}\">")
      end

      def end_a
        append_text('</link>')
      end

      def start_b
        append_text('<b>')
      end
      alias start_strong start_b

      def end_b
        append_text('</b>')
      end
      alias end_strong end_b

      def start_i
        append_text('<i>')
      end
      alias start_em start_i

      def end_i
        append_text('</i>')
      end
      alias end_em end_i

      def start_hr
        return if inside_container?

        put_bottom_margin(nil)
        add_current_text
        pdf.move_down(hr_vertical_margin_top)
        pdf.stroke_horizontal_rule
        pdf.move_down(hr_vertical_margin_bottom)
      end

      def end_document
        add_current_text
      end

      private

      def handle_text_element
        if inside_container?
          append_new_line
        else
          add_current_text
        end
      end

      def append_new_line
        append_text("\n") if buffered_text? && text_buffer[-1] != "\n"
      end

      def add_paragraph
        text = dump_text
        text.gsub!(/[^\n]/, '') if text.strip.empty?
        unless text.empty?
          add_bottom_margin
          add_formatted_text(text, text_options)
          put_bottom_margin(text_margin_bottom)
        end
      end

      def add_current_text(options = text_options)
        add_bottom_margin
        return unless buffered_text?

        string = dump_text
        string.strip!
        add_formatted_text(string, options)
      end

      def add_bottom_margin
        if @bottom_margin
          pdf.move_down(@bottom_margin)
          @bottom_margin = nil
        end
      end

      def add_formatted_text(string, options = text_options)
        with_font(options) do
          pdf.text(string, options)
        end
      end

      def with_font(options)
        pdf.font(options[:font] || pdf.font.family,
                 size: options[:size],
                 style: options[:style]) do
          return yield
        end
      end

      def hr_vertical_margin_top
        @hr_vertical_margin_top ||=
          (text_options[:size] || pdf.font_size) / 2.0
      end

      def hr_vertical_margin_bottom
        @hr_vertical_margin_bottom ||= with_font(text_options) do
          hr_vertical_margin_top +
            pdf.font.descender +
            text_leading -
            pdf.line_width
        end
      end

      def reset
        super
        text_margin_bottom # pre-calculate
      end

      def text_margin_bottom
        options[:text] ||= {}
        options[:text][:margin_bottom] ||= default_text_margin_bottom
      end

      def default_text_margin_bottom
        with_font(text_options) do
          pdf.font.line_gap +
            pdf.font.descender +
            text_leading
        end
      end

      def text_leading
        text_options[:leading] || pdf.default_leading
      end

      def text_options
        @text_options ||= HashMerger.deep(default_text_options, options[:text] || {})
      end

      def default_text_options
        {
          inline_format: true
        }
      end
    end
  end
end
