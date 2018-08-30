module Prawn
  module Markup
    module Processor::Headings
      def self.prepended(base)
        base.known_elements.push('h1', 'h2', 'h3', 'h4', 'h5', 'h6')
      end

      (1..6).each do |i|
        define_method("start_h#{i}") do
          start_heading(i)
        end

        define_method("end_h#{i}") do
          end_heading(i)
        end
      end

      def start_heading(level)
        if current_table
          add_cell_text_node(current_cell)
        elsif current_list
          add_cell_text_node(current_list_item)
        else
          add_current_text(false)
          pdf.move_down(heading_options(level)[:margin_top] || 0)
        end
      end

      def end_heading(level)
        options = heading_options(level)
        if current_table
          add_cell_text_node(current_cell, options)
        elsif current_list
          add_cell_text_node(current_list_item, options)
        else
          add_current_text(false, options)
          pdf.move_down(options[:margin_bottom] || 0)
        end
      end

      private

      def heading_options(level)
        @heading_options ||= {}
        @heading_options[level] ||= default_options_with_size(level)
      end

      def default_options_with_size(level)
        default = text_options.dup
        default[:size] ||= pdf.font_size
        default[:size] *= 2.5 - level * 0.25
        HashMerger.deep(default, options[:"heading#{level}"] || {})
      end

    end
  end
end
