describe ET::SubmissionFileList do
  let(:file_list) do
    path = File.expand_path(File.join(
      File.dirname(__FILE__), "../data/bloated-challenge"))
    ET::SubmissionFileList.new(path)
  end

  it 'includes a relevant file' do
    expect(file_list).to include('problem.rb')
  end

  it 'ignores a standard file' do
    expect(file_list).to_not include('sample-challenge.md')
  end

  it 'ignores a file included in a glob' do
    expect(file_list).to_not include('node_modules/boo/somefile.js')
  end
end
