describe ET::Formatter do
  let(:sample_lessons_file) { project_root.join("spec/data/lessons_20.json") }

  let(:sample_lessons) do
    JSON.parse(File.read(sample_lessons_file), symbolize_names: true)[:lessons]
  end

  let(:table) { ET::Formatter.new(sample_lessons, :slug, :title, :type).build_table }

  describe "#build_table" do
    it "limits the column width to the window" do
      expect_any_instance_of(ET::Formatter).to receive(:window_width).
        and_return(80)

      max_width = table.map { |t| t.size }.max
      expect(max_width).to eq(80)
    end
  end
end
