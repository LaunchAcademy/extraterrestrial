module OutputCatcher
  def capture_output(&block)
    original_stdout = $stdout
    $stdout = fake_stdout = StringIO.new
    original_stderr = $stderr
    $stderr = fake_stderr = StringIO.new

    begin
      yield
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end

    [fake_stdout.string, fake_stderr.string]
  end
end
