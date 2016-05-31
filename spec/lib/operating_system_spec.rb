require 'spec_helper'

describe ET::OperatingSystem do
  context '10.10' do
    let(:minor) { '10.10' }
    let(:os) { ET::OperatingSystem.new('darwin', minor) }

    it 'has a name' do
      expect(os.name).to eq(:mac)
    end

  end

  context '10.9' do
    let(:minor) { '10.9' }
    let(:os) { ET::OperatingSystem.new('darwin', minor + '.4') }

    it 'has a minor version' do
      expect(os.name).to eq(:mac)
    end
  end
end
