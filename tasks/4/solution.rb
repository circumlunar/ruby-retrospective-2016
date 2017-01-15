RSpec.describe 'Version' do
  describe '#initialize' do
    it 'raises error with a wrong parameter' do
      wrong_version = 'banana'
      expect { Version.new(wrong_version) }
        .to raise_error(
          ArgumentError,
          "Invalid version string \'#{wrong_version}\'"
        )
    end
  end

  describe '#compare' do
    it 'distinguishes lower or equal version' do
      lower_version = Version.new('1.2.3')
      higher_version = Version.new('1.3')
      expect(lower_version < higher_version).to be true
      expect(lower_version <= higher_version).to be true
      expect(lower_version <= Version.new(lower_version)).to be true
    end

    it 'distinguishes higher or equal version' do
      lower_version = Version.new('1.0.2.3')
      higher_version = Version.new('2.3')
      expect(higher_version > lower_version).to be true
      expect(higher_version >= lower_version).to be true
      expect(lower_version >= Version.new(lower_version)).to be true
    end

    it 'distinguishes equal versions' do
      version = Version.new('0.1')
      expect(version == Version.new(version)).to be true
    end

    it 'distinguishes different versions' do
      version = Version.new('1.0.4')
      another_version = Version.new('2.35')
      expect(version != another_version).to be true
      expect(version <=> another_version).to eq -1
    end

    it 'ignores trailing zeros' do
      expect(Version.new('1.2.3') == Version.new('1.2.3.0.0')).to be true
    end

    it 'considers intermediate zeros' do
      expect(Version.new('1.2.0.3') == Version.new('1.2.3')).to be false
    end
  end

  describe '#components' do
    it 'returns version components in the correct order' do
      expect(Version.new('1.2.3.40').components).to eq([1, 2, 3, 40])
    end

    it 'ignores trailing zeros' do
      expect(Version.new('1.2.3.0.0').components).to eq([1, 2, 3])
    end

    it 'keeps intermediate zeros' do
      expect(Version.new('0.1.0.2.3').components).to eq([0, 1, 0, 2, 3])
    end

    it 'fills missing positions with zeros' do
      expect(Version.new('1.2.3').components(6)).to eq([1, 2, 3, 0, 0, 0])
    end

    it 'returns first N components in the correct order' do
      expect(Version.new('1.2.3.4.5.6').components(3)).to eq([1, 2, 3])
    end

    it 'returns copy of the version components' do
      version = Version.new('1.2.3')
      expect(version.components.reverse!).not_to eq(version.components)
    end
  end

  describe '#to_s' do
    it 'represents version from a string' do
      parameter = '4.78.1.2'
      version = Version.new(parameter)
      expect(version.to_s).to eq parameter
    end

    it 'represents version from another instance' do
      parameter = '4.78.1.2'
      version = Version.new(parameter)
      another_version = Version.new(version)
      expect(another_version.to_s).to eq parameter
    end

    it 'represents version from an empty string' do
      version = Version.new('')
      expect(version.to_s).to eq ''
    end

    it 'ignores trailing zeros' do
      version_string = '1.2.3.0.0.0'
      version = Version.new(version_string)
      expect(version.to_s).to eq version_string.chomp('.0.0.0')
    end

    it 'keeps trailing zeros when part of the last component' do
      version_string = '1.20.3.50'
      version = Version.new(version_string)
      expect(version.to_s).to eq version_string
    end

    it 'keeps intermediate zeros' do
      version_string = '1.2.3.0.0.0.6'
      version = Version.new(version_string)
      expect(version.to_s).to eq version_string
    end
  end
end

RSpec.describe 'Version::Range' do
  describe '#include?' do
    it 'works with strings' do
      lower_version = '1.2.30'
      higher_version = '1.30.6'
      middle_version = '1.3'
      range = Version::Range.new(lower_version, higher_version)
      expect((range.include? middle_version)).to be true
    end

    it 'works with version instances' do
      lower_version = Version.new('1.2.3')
      higher_version = Version.new('1.3.6')
      middle_version = Version.new('1.3')
      range = Version::Range.new(lower_version, higher_version)
      expect((range.include? Version.new(middle_version))).to be true
    end

    it 'considers a range with equal bounds empty' do
      range = Version::Range.new('1.2.3', '1.2.3')
      expect((range.include? '1.2.3')).to be false
    end

    it 'detects version is within range' do
      range = Version::Range.new('', '9.19.9')
      expect((range.include? '0.5')).to be true
    end

    it 'detects version is out of range' do
      range = Version::Range.new('', '1.2.3')
      expect((range.include? '9.9.9')).to be false
    end

    it 'includes the lower bound of a range' do
      range = Version::Range.new('0.1', '9.9.9')
      expect((range.include? '0.1')).to be true
    end

    it 'excludes the higher bound of a range' do
      range = Version::Range.new('', '9.9.9')
      expect((range.include? '9.9.9')).to be false
    end
  end

  describe '#to_a' do
    it 'generates all versions within range' do
      range = Version::Range.new('1.1.0', '1.2.2')
      expect(range.to_a).to eq(
        [
          '1.1',   '1.1.1', '1.1.2',
          '1.1.3', '1.1.4', '1.1.5',
          '1.1.6', '1.1.7', '1.1.8',
          '1.1.9', '1.2',   '1.2.1'
        ]
      )
    end

    it 'generates empty array for a range with equal bounds' do
      expect(Version::Range.new('1.1', '1.1').to_a).to eq([])
    end

    it 'includes the lower bound and excludes the higher bound of a range' do
      expect(Version::Range.new('0.1.1', '0.1.2').to_a).to eq(['0.1.1'])
    end

    it 'correctly increments versions' do
      expect(Version::Range.new('0.1.9', '0.2').to_a).to eq(['0.1.9'])
      expect(Version::Range.new('0.9.9', '1').to_a).to eq(['0.9.9'])
    end
  end
end