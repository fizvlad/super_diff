module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module InspectionTreeBuilders
        class ActiveRecordModel < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            value.is_a?(::ActiveRecord::Base)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text { |object| "#<#{object.class} " }

                when_rendering_to_lines { add_text "{" }
              end

              nested do |object|
                insert_separated_list(
                  ["id"] + (object.attributes.keys.sort - ["id"])
                ) do |name|
                  as_prefix_when_rendering_to_lines { add_text "#{name}: " }

                  add_inspection_of object.read_attribute(name)
                end
              end

              as_lines_when_rendering_to_lines(collection_bookend: :close) do
                when_rendering_to_lines { add_text "}" }

                add_text ">"
              end
            end
          end
        end
      end
    end
  end
end
