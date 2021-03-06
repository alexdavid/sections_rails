require "spec_helper"

describe SectionsRails::Section do
  before(:each) { allow(Rails).to receive(:root).and_return('/rails_root/') }
  subject { SectionsRails::Section.new 'folder/section', nil }

  describe 'initialize' do

    context 'with section in folder' do
      its(:filename)            { should == 'section' }
      its(:directory_name)      { should == 'folder' }
    end

    context 'without folder' do
      subject { SectionsRails::Section.new 'section', nil }
      its(:filename)            { should == 'section' }
      its(:directory_name)      { should == '' }
    end
  end

  describe 'path helper methods' do

    context 'section in a folder' do
      its(:folder_filepath) { should == 'app/sections/folder/section' }
      its(:asset_filepath)  { should == 'app/sections/folder/section/section' }
      its(:asset_includepath)  { should == 'folder/section/section' }
      its(:partial_filepath)  { should == 'app/sections/folder/section/_section' }
      it { expect(subject.partial_filepath('foo')).to eq 'app/sections/folder/section/_foo' }
      its(:partial_includepath)  { should == 'folder/section/section' }
      its(:partial_renderpath)  { should == 'folder/section/section' }
      it { expect(subject.partial_renderpath('foo')).to eq 'folder/section/foo' }
    end

    context 'section in root sections directory' do
      subject { SectionsRails::Section.new 'section' }
      its(:folder_filepath) { should == 'app/sections/section' }
      its(:asset_filepath)  { should == 'app/sections/section/section' }
      its(:asset_includepath)  { should == 'section/section' }
      its(:partial_filepath)  { should == 'app/sections/section/_section' }
      its(:partial_includepath)  { should == 'section/section' }
    end
  end

  describe 'find_js_includepath' do

    it 'tries all different JS asset file types for sections' do
      expect(File).to receive(:exists?).with("app/sections/folder/section/section.js").and_return(false)
      expect(File).to receive(:exists?).with("app/sections/folder/section/section.js.coffee").and_return(false)
      expect(File).to receive(:exists?).with("app/sections/folder/section/section.coffee").and_return(false)
      subject.find_js_includepath
    end

    it 'returns nil if there is no known JS asset file' do
      allow(File).to receive(:exists?).and_return(false)
      expect(subject.find_js_includepath).to be_nil
    end

    it 'returns the asset path of the JS asset' do
      allow(File).to receive(:exists?).and_return(true)
      expect(subject.find_js_includepath).to eql 'folder/section/section'
    end

    it 'returns nil if the file exists but the section has JS assets disabled' do
      allow(File).to receive(:exists?).and_return(true)
      section = SectionsRails::Section.new 'folder/section', nil, js: false
      expect(section.find_js_includepath).to be_nil
    end

    it 'returns the custom JS asset path if one is set' do
      allow(File).to receive(:exists?).and_return(true)
      section = SectionsRails::Section.new 'folder/section', nil, js: 'custom'
      expect(section.find_js_includepath).to eql 'custom'
    end
  end


  describe 'find_partial_renderpath' do

    it 'looks for all known types of partials' do
      expect(File).to receive(:exists?).with("app/sections/folder/section/_section.html.erb").and_return(false)
      expect(File).to receive(:exists?).with("app/sections/folder/section/_section.html.haml").and_return(false)
      expect(File).to receive(:exists?).with("app/sections/folder/section/_section.html.slim").and_return(false)
      subject.find_partial_renderpath
    end

    it "returns nil if it doesn't find any assets" do
      allow(File).to receive(:exists?).and_return(false)
      expect(subject.find_partial_renderpath).to be_falsy
    end

    it "returns the path for rendering of the asset if it finds one" do
      allow(File).to receive(:exists?).and_return(true)
      expect(subject.find_partial_renderpath).to eql 'folder/section/section'
    end
  end


  describe 'find_partial_filepath' do

    it 'looks for all known types of partials' do
      expect(File).to receive(:exists?).with("app/sections/folder/section/_section.html.erb").and_return(false)
      expect(File).to receive(:exists?).with("app/sections/folder/section/_section.html.haml").and_return(false)
      expect(File).to receive(:exists?).with("app/sections/folder/section/_section.html.slim").and_return(false)
      subject.find_partial_filepath
    end

    it "returns nil if it doesn't find any assets" do
      allow(File).to receive(:exists?).and_return(false)
      expect(subject.find_partial_filepath).to be_falsy
    end

    it "returns the absolute path to the asset if it finds one" do
      allow(File).to receive(:exists?).and_return(true)
      expect(subject.find_partial_filepath).to eql 'app/sections/folder/section/_section.html.erb'
    end
  end


  describe 'partial_content' do
    it 'returns the content of the partial if one exists' do
      expect(SectionsRails::Section.new('partial_content/erb_partial').partial_content.strip).to eq 'ERB partial content'
      expect(SectionsRails::Section.new('partial_content/haml_partial').partial_content.strip).to eq 'HAML partial content'
    end

    it 'returns nil if no partial exists' do
      expect(SectionsRails::Section.new('partial_content/no_partial').partial_content).to be_nil
    end
  end

  describe 'referenced_sections' do

    it 'returns the sections that are referenced in the section partial' do
      expect(SectionsRails::Section.new('referenced_sections/erb_partial').referenced_sections).to eq ['one', 'two/three']
      expect(SectionsRails::Section.new('referenced_sections/haml_partial').referenced_sections).to eq ['one', 'two/three']
    end

    it 'returns an empty array if there is no partial' do
      expect(SectionsRails::Section.new('referenced_sections/no_partial').referenced_sections).to eql []
    end

    it "returns an empty array if the partial doesn't reference any sections" do
      expect(SectionsRails::Section.new('referenced_sections/no_referenced_sections').referenced_sections).to eql []
    end

    it 'finds sections referenced by referenced sections' do
      expect(SectionsRails::Section.new('referenced_sections/recursive').referenced_sections).to eql ['referenced_sections/recursive/one', 'referenced_sections/recursive/three', 'referenced_sections/recursive/two']
    end

    it 'can handle reference loops' do
      expect(SectionsRails::Section.new('referenced_sections/loop').referenced_sections).to eql ['referenced_sections/loop', 'referenced_sections/loop/one']
    end
  end
end

